import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';
import 'package:delivery_app/features/home/data/data_sources/home_local_data_source.dart';
import 'package:delivery_app/features/home/domain/entities/dashboard_summary_entity.dart';
import 'package:delivery_app/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  const HomeRepositoryImpl({required this.localDataSource});

  @override
  Future<DashboardSummaryEntity> getDashboardSummary({
    required UserRole role,
    required String userId,
  }) {
    return localDataSource.getDashboardSummary(role: role, userId: userId);
  }
}
