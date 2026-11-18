import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';

class DashboardSummaryEntity extends Equatable {
  final int activeOrdersCount;
  final int completedOrdersCount;
  final double totalCodPkr;
  final List<OrderEntity> activeOrders;
  final List<OrderEntity> recentOrders;

  const DashboardSummaryEntity({
    required this.activeOrdersCount,
    required this.completedOrdersCount,
    required this.totalCodPkr,
    required this.activeOrders,
    required this.recentOrders,
  });

  @override
  List<Object?> get props => [
        activeOrdersCount,
        completedOrdersCount,
        totalCodPkr,
        activeOrders,
        recentOrders,
      ];
}
