import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/features/orders/domain/repositories/order_repository.dart';
import 'package:delivery_app/features/rider/data/models/earnings_model.dart';

abstract class RiderLocalDataSource {
  Future<List<OrderEntity>> getAssignedOrders();
  Future<OrderEntity> updateDeliveryStatus({
    required String orderId,
    required OrderStatus newStatus,
  });
  Future<EarningsModel> getEarningsSummary();
}

class RiderLocalDataSourceImpl implements RiderLocalDataSource {
  final OrderRepository orderRepository;

  const RiderLocalDataSourceImpl({required this.orderRepository});

  @override
  Future<List<OrderEntity>> getAssignedOrders() {
    return orderRepository.getOrders(roleFilter: 'rider');
  }

  @override
  Future<OrderEntity> updateDeliveryStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) {
    return orderRepository.updateOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
    );
  }

  @override
  Future<EarningsModel> getEarningsSummary() async {
    final orders = await orderRepository.getOrders(roleFilter: 'rider');
    final delivered =
        orders.where((o) => o.status == OrderStatus.delivered).toList();
    final todayEarnings = delivered.fold<double>(
      0,
      (sum, o) => sum + o.riderSharePkr,
    );
    final codCollected = delivered.fold<double>(
      0,
      (sum, o) => sum + o.codAmountPkr,
    );
    const deposited = 2000.0;
    final cashInHand = (codCollected - deposited).clamp(0.0, 999999.0);

    return EarningsModel(
      todayEarningsPkr: todayEarnings + 950,
      weekEarningsPkr: todayEarnings + 6420,
      monthEarningsPkr: todayEarnings + 24800,
      cashCollectedPkr: codCollected + 3500,
      cashDepositedPkr: deposited,
      cashInHandPkr: cashInHand + 3500,
      cashLimitPkr: AppConstants.riderCashInHandLimitPkr,
      deliveriesToday: delivered.length + 5,
      deliveriesTotal: delivered.length + 42,
    );
  }
}
