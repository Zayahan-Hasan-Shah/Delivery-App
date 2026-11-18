import 'package:delivery_app/features/orders/data/data_sources/order_local_data_source.dart';
import 'package:delivery_app/features/orders/domain/entities/location_point_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_item_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;

  const OrderRepositoryImpl({required this.localDataSource});

  @override
  Future<List<OrderEntity>> getOrders({String? roleFilter, String? userId}) {
    return localDataSource.getOrders(roleFilter: roleFilter, userId: userId);
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) {
    return localDataSource.getOrderById(orderId);
  }

  @override
  Future<OrderEntity> createOrder({
    required String senderId,
    required LocationPointEntity pickup,
    required LocationPointEntity dropoff,
    required List<OrderItemEntity> items,
    required double codAmountPkr,
    String? notes,
  }) {
    return localDataSource.createOrder(
      senderId: senderId,
      pickup: pickup,
      dropoff: dropoff,
      items: items,
      codAmountPkr: codAmountPkr,
      notes: notes,
    );
  }

  @override
  Future<OrderEntity> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? proofPhotoPath,
  }) {
    return localDataSource.updateOrderStatus(
      orderId: orderId,
      newStatus: newStatus,
      proofPhotoPath: proofPhotoPath,
    );
  }
}
