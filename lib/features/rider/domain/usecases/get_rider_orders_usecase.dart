import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/rider/domain/repositories/rider_repository.dart';

class GetRiderOrdersUseCase {
  final RiderRepository repository;

  const GetRiderOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call() => repository.getAssignedOrders();
}
