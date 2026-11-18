import 'package:delivery_app/features/tracking/domain/entities/rider_location_entity.dart';
import 'package:delivery_app/features/tracking/domain/repositories/tracking_repository.dart';

class WatchTrackingUpdatesUseCase {
  final TrackingRepository repository;

  const WatchTrackingUpdatesUseCase(this.repository);

  Stream<RiderLocationEntity> call(String orderId) {
    return repository.watchRiderLocation(orderId);
  }

  void unsubscribe(String orderId) {
    repository.unsubscribeOrder(orderId);
  }
}
