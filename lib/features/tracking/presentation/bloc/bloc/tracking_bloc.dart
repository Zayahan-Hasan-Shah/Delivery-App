import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/features/tracking/domain/entities/rider_location_entity.dart';
import 'package:delivery_app/features/tracking/domain/usecases/get_active_tracking_orders_usecase.dart';
import 'package:delivery_app/features/tracking/domain/usecases/get_tracking_data_usecase.dart';
import 'package:delivery_app/features/tracking/domain/usecases/watch_tracking_updates_usecase.dart';
import 'package:delivery_app/features/tracking/presentation/bloc/event/tracking_event.dart';
import 'package:delivery_app/features/tracking/presentation/bloc/state/tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final GetActiveTrackingOrdersUseCase getActiveTrackingOrdersUseCase;
  final GetTrackingDataUseCase getTrackingDataUseCase;
  final WatchTrackingUpdatesUseCase watchTrackingUpdatesUseCase;

  StreamSubscription<RiderLocationEntity>? _locationSub;
  String? _subscribedOrderId;

  TrackingBloc({
    required this.getActiveTrackingOrdersUseCase,
    required this.getTrackingDataUseCase,
    required this.watchTrackingUpdatesUseCase,
  }) : super(const TrackingState()) {
    on<LoadTrackingOrdersEvent>(_onLoadOrders);
    on<SelectTrackingOrderEvent>(_onSelectOrder);
    on<TrackingRiderLocationReceivedEvent>(_onLocationReceived);
  }

  Future<void> _onLoadOrders(
    LoadTrackingOrdersEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final orders = await getActiveTrackingOrdersUseCase();
      if (orders.isEmpty) {
        emit(state.copyWith(isLoading: false, activeOrders: const []));
        return;
      }

      final targetId = event.initialOrderId ?? orders.first.id;
      final data = await getTrackingDataUseCase(targetId);
      _subscribeToOrder(targetId);

      emit(state.copyWith(
        isLoading: false,
        activeOrders: orders,
        trackingData: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load tracking info: $e',
      ));
    }
  }

  Future<void> _onSelectOrder(
    SelectTrackingOrderEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final data = await getTrackingDataUseCase(event.orderId);
      _subscribeToOrder(event.orderId);
      emit(state.copyWith(isLoading: false, trackingData: data));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to select order: $e',
      ));
    }
  }

  void _onLocationReceived(
    TrackingRiderLocationReceivedEvent event,
    Emitter<TrackingState> emit,
  ) {
    final current = state.trackingData;
    if (current == null) return;
    emit(state.copyWith(
      trackingData: current.copyWith(riderLocation: event.location),
    ));
  }

  void _subscribeToOrder(String orderId) {
    if (_subscribedOrderId != null && _subscribedOrderId != orderId) {
      watchTrackingUpdatesUseCase.unsubscribe(_subscribedOrderId!);
    }
    _locationSub?.cancel();
    _subscribedOrderId = orderId;
    _locationSub = watchTrackingUpdatesUseCase(orderId).listen((loc) {
      add(TrackingRiderLocationReceivedEvent(loc));
    });
  }

  @override
  Future<void> close() async {
    if (_subscribedOrderId != null) {
      watchTrackingUpdatesUseCase.unsubscribe(_subscribedOrderId!);
    }
    await _locationSub?.cancel();
    return super.close();
  }
}
