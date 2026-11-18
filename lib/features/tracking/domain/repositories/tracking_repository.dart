import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/tracking/domain/entities/rider_location_entity.dart';
import 'package:delivery_app/features/tracking/domain/entities/tracking_data_entity.dart';

abstract class TrackingRepository {
  Future<List<OrderEntity>> getActiveTrackingOrders();
  Future<TrackingDataEntity?> getTrackingData(String orderId);
  Stream<RiderLocationEntity> watchRiderLocation(String orderId);
  void unsubscribeOrder(String orderId);
}
