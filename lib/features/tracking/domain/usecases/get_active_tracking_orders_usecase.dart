import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/tracking/domain/repositories/tracking_repository.dart';

class GetActiveTrackingOrdersUseCase {
  final TrackingRepository repository;

  const GetActiveTrackingOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call() => repository.getActiveTrackingOrders();
}
