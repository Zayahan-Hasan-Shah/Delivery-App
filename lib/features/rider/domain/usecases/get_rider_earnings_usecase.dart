import 'package:delivery_app/features/rider/domain/entities/earnings_entity.dart';
import 'package:delivery_app/features/rider/domain/repositories/rider_repository.dart';

class GetRiderEarningsUseCase {
  final RiderRepository repository;

  const GetRiderEarningsUseCase(this.repository);

  Future<EarningsEntity> call() => repository.getEarningsSummary();
}
