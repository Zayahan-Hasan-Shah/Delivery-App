import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/core/constant/event_names.dart';
import 'package:delivery_app/core/utils/app_logger.dart';
import 'package:delivery_app/core/utils/order_color_helper.dart';
import 'package:delivery_app/features/rider/domain/usecases/get_rider_earnings_usecase.dart';
import 'package:delivery_app/features/rider/domain/usecases/get_rider_orders_usecase.dart';
import 'package:delivery_app/features/rider/domain/usecases/update_rider_order_status_usecase.dart';
import 'package:delivery_app/features/rider/presentation/bloc/event/rider_orders_event.dart';
import 'package:delivery_app/features/rider/presentation/bloc/state/rider_orders_state.dart';
import 'package:delivery_app/shared/service/background_delivery_service.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';

class RiderOrdersBloc extends Bloc<RiderOrdersEvent, RiderOrdersState> {
  final GetRiderOrdersUseCase getRiderOrdersUseCase;
  final GetRiderEarningsUseCase getRiderEarningsUseCase;
  final UpdateRiderOrderStatusUseCase updateRiderOrderStatusUseCase;
  final BackgroundDeliveryService backgroundDeliveryService;
  final RealtimeService realtimeService;

  StreamSubscription<UserLocation>? _locationSub;
  StreamSubscription<RealtimeEvent>? _realtimeSub;

  RiderOrdersBloc({
    required this.getRiderOrdersUseCase,
    required this.getRiderEarningsUseCase,
    required this.updateRiderOrderStatusUseCase,
    required this.backgroundDeliveryService,
    required this.realtimeService,
  }) : super(const RiderOrdersState()) {
    on<LoadRiderDashboardEvent>(_onLoadDashboard);
    on<ToggleRiderOnlineShiftEvent>(_onToggleOnline);
    on<SelectRiderOrderOnMapEvent>(_onSelectOrderOnMap);
    on<UpdateRiderOrderStatusEvent>(_onUpdateStatus);
    on<ChangeRiderOrderFilterEvent>(_onChangeFilter);
    on<RiderLiveLocationUpdatedEvent>(_onLocationUpdated);
  }

  Future<void> _onLoadDashboard(
    LoadRiderDashboardEvent event,
    Emitter<RiderOrdersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final orders = await getRiderOrdersUseCase();
      final earnings = await getRiderEarningsUseCase();
      final colorMap = OrderColorHelper.buildColorMap(
        orders.map((o) => o.id).toList(),
      );

      final wasOnline = await backgroundDeliveryService.wasOnlineBeforeRestart();
      final shouldBeOnline = event.initialOnline || wasOnline;

      final activeIds =
          orders.where((o) => o.status.isActive).map((o) => o.id).toList();

      if (shouldBeOnline) {
        await backgroundDeliveryService.startRiderBackgroundShift(
          activeOrderIds: activeIds,
        );
      } else {
        backgroundDeliveryService.updateTrackedOrderIds(activeIds);
      }

      _subscribeToLiveStreams();

      final lastLoc = backgroundDeliveryService.currentRiderLocation;
      emit(state.copyWith(
        isLoading: false,
        isOnline: shouldBeOnline,
        isBackgroundTrackingActive:
            backgroundDeliveryService.isBackgroundShiftRunning,
        allOrders: orders,
        orderColors: colorMap,
        earnings: earnings,
        riderLatitude: lastLoc?.latitude ?? state.riderLatitude,
        riderLongitude: lastLoc?.longitude ?? state.riderLongitude,
      ));
    } catch (e, st) {
      AppLogger.error(
        'Failed to load rider dashboard',
        error: e,
        stackTrace: st,
        tag: 'RiderOrdersBloc',
      );
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load rider orders: $e',
      ));
    }
  }

  void _subscribeToLiveStreams() {
    _locationSub ??=
        backgroundDeliveryService.riderLiveLocationStream.listen((loc) {
      add(RiderLiveLocationUpdatedEvent(
        latitude: loc.latitude,
        longitude: loc.longitude,
      ));
    });

    _realtimeSub ??= realtimeService.eventStream.listen((evt) {
      if (evt.eventName == RealtimeEventNames.riderAssigned ||
          evt.eventName == RealtimeEventNames.orderStatusUpdated) {
        add(LoadRiderDashboardEvent(initialOnline: state.isOnline));
      }
    });
  }

  Future<void> _onToggleOnline(
    ToggleRiderOnlineShiftEvent event,
    Emitter<RiderOrdersState> emit,
  ) async {
    final activeIds = state.activeOrders.map((o) => o.id).toList();
    if (event.isOnline) {
      await backgroundDeliveryService.startRiderBackgroundShift(
        activeOrderIds: activeIds,
      );
    } else {
      await backgroundDeliveryService.stopRiderBackgroundShift();
    }

    emit(state.copyWith(
      isOnline: event.isOnline,
      isBackgroundTrackingActive:
          backgroundDeliveryService.isBackgroundShiftRunning,
    ));
  }

  void _onSelectOrderOnMap(
    SelectRiderOrderOnMapEvent event,
    Emitter<RiderOrdersState> emit,
  ) {
    if (event.orderId == null) {
      emit(state.copyWith(clearSelectedOrder: true));
    } else {
      emit(state.copyWith(selectedOrderId: event.orderId));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateRiderOrderStatusEvent event,
    Emitter<RiderOrdersState> emit,
  ) async {
    try {
      await updateRiderOrderStatusUseCase(
        orderId: event.orderId,
        newStatus: event.newStatus,
      );
      final orders = await getRiderOrdersUseCase();
      final earnings = await getRiderEarningsUseCase();
      final colorMap = OrderColorHelper.buildColorMap(
        orders.map((o) => o.id).toList(),
      );
      backgroundDeliveryService.updateTrackedOrderIds(
        orders.where((o) => o.status.isActive).map((o) => o.id).toList(),
      );
      emit(state.copyWith(
        allOrders: orders,
        orderColors: colorMap,
        earnings: earnings,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update status: $e'));
    }
  }

  void _onChangeFilter(
    ChangeRiderOrderFilterEvent event,
    Emitter<RiderOrdersState> emit,
  ) {
    emit(state.copyWith(activeFilter: event.filter));
  }

  void _onLocationUpdated(
    RiderLiveLocationUpdatedEvent event,
    Emitter<RiderOrdersState> emit,
  ) {
    emit(state.copyWith(
      riderLatitude: event.latitude,
      riderLongitude: event.longitude,
    ));
  }

  @override
  Future<void> close() async {
    await _locationSub?.cancel();
    await _realtimeSub?.cancel();
    return super.close();
  }
}
