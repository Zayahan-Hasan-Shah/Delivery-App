import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/features/rider/domain/repositories/rider_repository.dart';

class UpdateRiderOrderStatusUseCase {
  final RiderRepository repository;

  const UpdateRiderOrderStatusUseCase(this.repository);

  Future<OrderEntity> call({
    required String orderId,
    required OrderStatus newStatus,
  }) {
    return repository.updateDeliveryStatus(
      orderId: orderId,
      newStatus: newStatus,
    );
  }
}
