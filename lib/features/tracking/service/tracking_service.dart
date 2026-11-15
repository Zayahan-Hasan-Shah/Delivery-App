import 'dart:async';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/orders/service/order_service.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';

abstract class TrackingService {
  Future<List<OrderModel>> getTrackableOrders();
  Future<OrderModel> getOrderDetails(String orderId);
  void subscribeToOrderTracking(String orderId);
  void unsubscribeFromOrderTracking(String orderId);
  Stream<Map<String, dynamic>> listenToLocationUpdates(String orderId);
  Stream<Map<String, dynamic>> listenToStatusUpdates(String orderId);
}

class TrackingServiceImpl implements TrackingService {
  final OrderService orderService;
  final RealtimeService realtimeService;

  TrackingServiceImpl({
    required this.orderService,
    required this.realtimeService,
  });

  @override
  Future<List<OrderModel>> getTrackableOrders() async {
    return await orderService.getActiveOrders();
  }

  @override
  Future<OrderModel> getOrderDetails(String orderId) async {
    return await orderService.getOrderById(orderId);
  }

  @override
  void subscribeToOrderTracking(String orderId) {
    realtimeService.subscribeToOrder(orderId);
  }

  @override
  void unsubscribeFromOrderTracking(String orderId) {
    realtimeService.unsubscribeFromOrder(orderId);
  }

  @override
  Stream<Map<String, dynamic>> listenToLocationUpdates(String orderId) {
    return realtimeService.listenForRiderLocation(orderId);
  }

  @override
  Stream<Map<String, dynamic>> listenToStatusUpdates(String orderId) {
    return realtimeService.listenForStatusUpdates(orderId);
  }
}
