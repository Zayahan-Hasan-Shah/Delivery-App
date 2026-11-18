import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';
import 'package:delivery_app/features/home/data/models/dashboard_summary_model.dart';
import 'package:delivery_app/features/orders/domain/repositories/order_repository.dart';

abstract class HomeLocalDataSource {
  Future<DashboardSummaryModel> getDashboardSummary({
    required UserRole role,
    required String userId,
  });
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final OrderRepository orderRepository;

  const HomeLocalDataSourceImpl({required this.orderRepository});

  @override
  Future<DashboardSummaryModel> getDashboardSummary({
    required UserRole role,
    required String userId,
  }) async {
    final orders = await orderRepository.getOrders(
      roleFilter: role.name,
      userId: userId,
    );
    final active = orders.where((o) => o.status.isActive).toList();
    final completed = orders.where((o) => o.status.isTerminal).toList();
    final totalCod = orders.fold<double>(0, (sum, o) => sum + o.codAmountPkr);

    return DashboardSummaryModel(
      activeOrdersCount: active.length,
      completedOrdersCount: completed.length,
      totalCodPkr: totalCod,
      activeOrders: active,
      recentOrders: orders.take(6).toList(),
    );
  }
}
