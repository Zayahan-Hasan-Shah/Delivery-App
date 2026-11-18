import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;

  const GetOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call({String? roleFilter, String? userId}) {
    return repository.getOrders(roleFilter: roleFilter, userId: userId);
  }
}
