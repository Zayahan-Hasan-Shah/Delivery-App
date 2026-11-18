import 'package:delivery_app/features/tracking/domain/entities/tracking_data_entity.dart';
import 'package:delivery_app/features/tracking/domain/repositories/tracking_repository.dart';

class GetTrackingDataUseCase {
  final TrackingRepository repository;

  const GetTrackingDataUseCase(this.repository);

  Future<TrackingDataEntity?> call(String orderId) {
    return repository.getTrackingData(orderId);
  }
}
