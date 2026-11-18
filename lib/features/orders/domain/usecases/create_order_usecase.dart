import 'package:delivery_app/features/orders/domain/entities/location_point_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_item_entity.dart';
import 'package:delivery_app/features/orders/domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  const CreateOrderUseCase(this.repository);

  Future<OrderEntity> call({
    required String senderId,
    required LocationPointEntity pickup,
    required LocationPointEntity dropoff,
    required List<OrderItemEntity> items,
    required double codAmountPkr,
    String? notes,
  }) {
    return repository.createOrder(
      senderId: senderId,
      pickup: pickup,
      dropoff: dropoff,
      items: items,
      codAmountPkr: codAmountPkr,
      notes: notes,
    );
  }
}
