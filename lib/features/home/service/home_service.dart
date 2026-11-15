import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/orders/model/order_status.dart';
import 'package:delivery_app/features/orders/service/order_service.dart';
import 'package:delivery_app/features/home/model/dashboard_summary.dart';

abstract class HomeService {
  Future<DashboardSummary> getDashboardSummary();
  Future<List<OrderModel>> getRecentOrders();
}

class HomeServiceImpl implements HomeService {
  final OrderService orderService;

  HomeServiceImpl({required this.orderService});

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    final orders = await orderService.getOrders();
    int onRoad = 0;
    int waiting = 0;
    int delivered = 0;

    for (final o in orders) {
      if (o.status == OrderStatus.onTheWay || o.status == OrderStatus.pickedUp) {
        onRoad++;
      } else if (o.status == OrderStatus.placed || o.status == OrderStatus.accepted || o.status == OrderStatus.assigned) {
        waiting++;
      } else if (o.status == OrderStatus.delivered) {
        delivered++;
      }
    }

    return DashboardSummary(
      onRoadCount: onRoad,
      waitingCount: waiting,
      deliveredCount: delivered,
    );
  }

  @override
  Future<List<OrderModel>> getRecentOrders() async {
    return await orderService.getOrders();
  }
}
