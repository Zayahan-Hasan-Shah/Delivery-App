import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/repositories/order_repository.dart';
import 'package:delivery_app/features/tracking/data/models/rider_location_model.dart';
import 'package:delivery_app/features/tracking/data/models/tracking_data_model.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';

abstract class TrackingLocalDataSource {
  Future<List<OrderEntity>> getActiveTrackingOrders();
  Future<TrackingDataModel?> getTrackingData(String orderId);
  Stream<RiderLocationModel> watchRiderLocation(String orderId);
  void unsubscribeOrder(String orderId);
}

class TrackingLocalDataSourceImpl implements TrackingLocalDataSource {
  final OrderRepository orderRepository;
  final RealtimeService realtimeService;

  const TrackingLocalDataSourceImpl({
    required this.orderRepository,
    required this.realtimeService,
  });

  @override
  Future<List<OrderEntity>> getActiveTrackingOrders() async {
    final orders = await orderRepository.getOrders();
    return orders.where((o) => o.status.isActive).toList();
  }

  @override
  Future<TrackingDataModel?> getTrackingData(String orderId) async {
    final order = await orderRepository.getOrderById(orderId);
    if (order == null) return null;

    final midLat = (order.pickup.latitude + order.dropoff.latitude) / 2;
    final midLng = (order.pickup.longitude + order.dropoff.longitude) / 2;

    return TrackingDataModel(
      order: order,
      riderLocation: RiderLocationModel(
        latitude: midLat,
        longitude: midLng,
        speed: 30,
        timestamp: DateTime.now(),
      ),
      etaMinutes: '${(order.distanceKm * 3.5).round().clamp(5, 45)} min',
    );
  }

  @override
  Stream<RiderLocationModel> watchRiderLocation(String orderId) {
    realtimeService.subscribeToOrder(orderId);
    return realtimeService
        .listenForRiderLocation(orderId)
        .map(RiderLocationModel.fromJson);
  }

  @override
  void unsubscribeOrder(String orderId) {
    realtimeService.unsubscribeFromOrder(orderId);
  }
}
