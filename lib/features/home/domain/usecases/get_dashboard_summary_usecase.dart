import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';
import 'package:delivery_app/features/home/domain/entities/dashboard_summary_entity.dart';
import 'package:delivery_app/features/home/domain/repositories/home_repository.dart';

class GetDashboardSummaryUseCase {
  final HomeRepository repository;

  const GetDashboardSummaryUseCase(this.repository);

  Future<DashboardSummaryEntity> call({
    required UserRole role,
    required String userId,
  }) {
    return repository.getDashboardSummary(role: role, userId: userId);
  }
}
