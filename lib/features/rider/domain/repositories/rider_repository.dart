import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/features/rider/domain/entities/earnings_entity.dart';

abstract class RiderRepository {
  Future<List<OrderEntity>> getAssignedOrders();
  Future<OrderEntity> updateDeliveryStatus({
    required String orderId,
    required OrderStatus newStatus,
  });
  Future<EarningsEntity> getEarningsSummary();
}
