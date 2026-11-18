import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';
import 'package:delivery_app/features/home/domain/entities/dashboard_summary_entity.dart';

abstract class HomeRepository {
  Future<DashboardSummaryEntity> getDashboardSummary({
    required UserRole role,
    required String userId,
  });
}
