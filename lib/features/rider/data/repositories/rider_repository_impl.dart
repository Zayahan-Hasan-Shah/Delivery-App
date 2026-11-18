import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/features/rider/data/data_sources/rider_local_data_source.dart';
import 'package:delivery_app/features/rider/domain/entities/earnings_entity.dart';
import 'package:delivery_app/features/rider/domain/repositories/rider_repository.dart';

class RiderRepositoryImpl implements RiderRepository {
  final RiderLocalDataSource localDataSource;

  const RiderRepositoryImpl({required this.localDataSource});

  @override
  Future<List<OrderEntity>> getAssignedOrders() {
    return localDataSource.getAssignedOrders();
  }

  @override
  Future<OrderEntity> updateDeliveryStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) {
    return localDataSource.updateDeliveryStatus(
      orderId: orderId,
      newStatus: newStatus,
    );
  }

  @override
  Future<EarningsEntity> getEarningsSummary() {
    return localDataSource.getEarningsSummary();
  }
}
