import 'package:delivery_app/features/orders/domain/entities/location_point_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_item_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders({String? roleFilter, String? userId});
  Future<OrderEntity?> getOrderById(String orderId);
  Future<OrderEntity> createOrder({
    required String senderId,
    required LocationPointEntity pickup,
    required LocationPointEntity dropoff,
    required List<OrderItemEntity> items,
    required double codAmountPkr,
    String? notes,
  });
  Future<OrderEntity> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? proofPhotoPath,
  });
}
