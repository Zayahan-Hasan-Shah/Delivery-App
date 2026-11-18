import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/features/orders/domain/repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository repository;

  const UpdateOrderStatusUseCase(this.repository);

  Future<OrderEntity> call({
    required String orderId,
    required OrderStatus newStatus,
    String? proofPhotoPath,
  }) {
    return repository.updateOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
      proofPhotoPath: proofPhotoPath,
    );
  }
}
