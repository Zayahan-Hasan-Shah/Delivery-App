import 'package:delivery_app/features/home/domain/entities/dashboard_summary_entity.dart';

class DashboardSummaryModel extends DashboardSummaryEntity {
  const DashboardSummaryModel({
    required super.activeOrdersCount,
    required super.completedOrdersCount,
    required super.totalCodPkr,
    required super.activeOrders,
    required super.recentOrders,
  });
}
