import '../model/order_model.dart';
import '../model/location_point_model.dart';
import '../model/order_item_model.dart';

abstract class OrderService {
  Future<OrderModel> createOrder({
    required LocationPointModel pickup,
    required LocationPointModel dropoff,
    required List<OrderItemModel> items,
    String? riderNote,
  });

  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderById(String orderId);
  Future<List<OrderModel>> getActiveOrders();
  Future<OrderModel> updateOrderStatus(String orderId, String newStatus);
}
