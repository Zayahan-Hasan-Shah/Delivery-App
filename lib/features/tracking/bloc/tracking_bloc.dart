import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/features/tracking/bloc/tracking_event.dart';
import 'package:delivery_app/features/tracking/bloc/tracking_state.dart';
import 'package:delivery_app/features/tracking/service/tracking_service.dart';
import 'package:delivery_app/features/tracking/model/rider_location.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/orders/model/order_status.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final TrackingService trackingService;

  StreamSubscription? _locationSub;
  StreamSubscription? _statusSub;

  TrackingBloc({required this.trackingService}) : super(const TrackingState()) {
    on<LoadTrackableOrdersEvent>(_onLoadTrackableOrders);
    on<SelectOrderForTrackingEvent>(_onSelectOrderForTracking);
    on<LiveRiderLocationReceivedEvent>((event, emit) {
      if (state.selectedOrder?.id == event.orderId) {
        emit(state.copyWith(liveRiderLocation: event.location));
      }
    });
    on<LiveOrderStatusUpdatedEvent>((event, emit) {
      if (state.selectedOrder?.id == event.orderId) {
        final newStatus = OrderStatus.fromString(event.status);
        final updatedOrder = state.selectedOrder!.copyWith(
          status: newStatus,
          statusHistory: [
            ...state.selectedOrder!.statusHistory,
            OrderStatusHistoryItem(status: newStatus, timestamp: DateTime.now()),
          ],
        );
        emit(state.copyWith(selectedOrder: updatedOrder));
      }
    });
  }

  Future<void> _onLoadTrackableOrders(
    LoadTrackableOrdersEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(state.copyWith(status: TrackingStatus.loading));
    try {
      final orders = await trackingService.getTrackableOrders();
      if (orders.isEmpty) {
        emit(state.copyWith(status: TrackingStatus.success, orders: const [], selectedOrder: null));
        return;
      }

      // Default: select initialOrderId if passed, or latest order
      OrderModel initialOrder;
      if (event.initialOrderId != null) {
        initialOrder = orders.firstWhere(
          (o) => o.id == event.initialOrderId || o.orderNumber == event.initialOrderId,
          orElse: () => orders.first,
        );
      } else {
        initialOrder = orders.first;
      }

      emit(state.copyWith(
        status: TrackingStatus.success,
        orders: orders,
        selectedOrder: initialOrder,
        liveRiderLocation: initialOrder.riderLocation,
      ));

      _subscribeToRealtime(initialOrder.id);
    } catch (e, st) {
      AppLogger.error('Failed to load trackable orders', error: e, stackTrace: st, tag: 'TrackingBloc');
      emit(state.copyWith(
        status: TrackingStatus.error,
        errorMessage: 'Unable to load orders for tracking. Please check your connection.',
      ));
    }
  }

  Future<void> _onSelectOrderForTracking(
    SelectOrderForTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    // Avoid redundant reload if already selected
    if (state.selectedOrder?.id == event.orderId) return;

    final targetOrder = state.orders.firstWhere(
      (o) => o.id == event.orderId,
      orElse: () => state.orders.first,
    );

    // Unsubscribe previous
    if (state.selectedOrder != null) {
      trackingService.unsubscribeFromOrderTracking(state.selectedOrder!.id);
    }

    emit(state.copyWith(
      selectedOrder: targetOrder,
      liveRiderLocation: targetOrder.riderLocation,
    ));

    _subscribeToRealtime(targetOrder.id);
  }

  void _subscribeToRealtime(String orderId) {
    _locationSub?.cancel();
    _statusSub?.cancel();

    trackingService.subscribeToOrderTracking(orderId);

    _locationSub = trackingService.listenToLocationUpdates(orderId).listen((payload) {
      final lat = (payload['latitude'] as num?)?.toDouble();
      final lng = (payload['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        add(LiveRiderLocationReceivedEvent(
          orderId: orderId,
          location: RiderLocation(
            latitude: lat,
            longitude: lng,
            heading: (payload['heading'] as num?)?.toDouble(),
            speed: (payload['speed'] as num?)?.toDouble(),
            timestamp: DateTime.now(),
          ),
        ));
      }
    });

    _statusSub = trackingService.listenToStatusUpdates(orderId).listen((payload) {
      final status = payload['status'] as String?;
      if (status != null) {
        add(LiveOrderStatusUpdatedEvent(orderId: orderId, status: status));
      }
    });
  }

  @override
  Future<void> close() {
    _locationSub?.cancel();
    _statusSub?.cancel();
    if (state.selectedOrder != null) {
      trackingService.unsubscribeFromOrderTracking(state.selectedOrder!.id);
    }
    return super.close();
  }
}
