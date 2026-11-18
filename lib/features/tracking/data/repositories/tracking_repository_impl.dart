import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/tracking/data/data_sources/tracking_local_data_source.dart';
import 'package:delivery_app/features/tracking/domain/entities/rider_location_entity.dart';
import 'package:delivery_app/features/tracking/domain/entities/tracking_data_entity.dart';
import 'package:delivery_app/features/tracking/domain/repositories/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingLocalDataSource localDataSource;

  const TrackingRepositoryImpl({required this.localDataSource});

  @override
  Future<List<OrderEntity>> getActiveTrackingOrders() {
    return localDataSource.getActiveTrackingOrders();
  }

  @override
  Future<TrackingDataEntity?> getTrackingData(String orderId) {
    return localDataSource.getTrackingData(orderId);
  }

  @override
  Stream<RiderLocationEntity> watchRiderLocation(String orderId) {
    return localDataSource.watchRiderLocation(orderId);
  }

  @override
  void unsubscribeOrder(String orderId) {
    localDataSource.unsubscribeOrder(orderId);
  }
}
