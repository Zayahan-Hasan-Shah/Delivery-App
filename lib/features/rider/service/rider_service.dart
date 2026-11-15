import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/orders/service/order_service.dart';
import 'package:delivery_app/features/rider/model/earnings_model.dart';

abstract class RiderService {
  Future<List<OrderModel>> getAssignedOrders();
  Future<EarningsModel> getEarnings();
  Future<void> updateDeliveryStatus(String orderId, String newStatus);
}

class RiderServiceImpl implements RiderService {
  final OrderService orderService;

  RiderServiceImpl({required this.orderService});

  @override
  Future<List<OrderModel>> getAssignedOrders() async {
    final all = await orderService.getOrders();
    // Return all orders or those assigned to rider
    return all;
  }

  @override
  Future<EarningsModel> getEarnings() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const EarningsModel(
      totalEarned: 1480.50,
      todayEarned: 95.00,
      weekEarned: 480.20,
      completedDeliveriesCount: 42,
    );
  }

  @override
  Future<void> updateDeliveryStatus(String orderId, String newStatus) async {
    await orderService.updateOrderStatus(orderId, newStatus);
  }
}
