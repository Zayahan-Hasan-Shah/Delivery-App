import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/repositories/order_repository.dart';

class GetOrderByIdUseCase {
  final OrderRepository repository;

  const GetOrderByIdUseCase(this.repository);

  Future<OrderEntity?> call(String orderId) {
    return repository.getOrderById(orderId);
  }
}
