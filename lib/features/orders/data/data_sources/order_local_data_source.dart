import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:delivery_app/core/constant/event_names.dart';
import 'package:delivery_app/features/orders/data/models/location_point_model.dart';
import 'package:delivery_app/features/orders/data/models/order_item_model.dart';
import 'package:delivery_app/features/orders/data/models/order_model.dart';
import 'package:delivery_app/features/orders/domain/entities/location_point_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_item_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';

abstract class OrderLocalDataSource {
  Future<List<OrderModel>> getOrders({String? roleFilter, String? userId});
  Future<OrderModel?> getOrderById(String orderId);
  Future<OrderModel> createOrder({
    required String senderId,
    required LocationPointEntity pickup,
    required LocationPointEntity dropoff,
    required List<OrderItemEntity> items,
    required double codAmountPkr,
    String? notes,
  });
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? proofPhotoPath,
  });
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  final RealtimeService realtimeService;
  final Uuid _uuid = const Uuid();
  final List<OrderModel> _orders = [];
  int _nextOrderSeq = 105;

  OrderLocalDataSourceImpl({required this.realtimeService}) {
    _seedInitialOrders();
  }

  void _seedInitialOrders() {
    final now = DateTime.now();

    _orders.addAll([
      OrderModel(
        id: 'ord_101',
        orderNumber: 'SC-101',
        senderId: 'sender_01',
        riderId: 'rider_01',
        riderName: 'Bilal Raza',
        riderPhone: '03117654321',
        pickup: const LocationPointModel(
          latitude: 33.7215,
          longitude: 73.0561,
          contactName: 'Spice Cloud Kitchen',
          contactPhone: '03001234567',
          addressText: 'Plot 14, F-7 Markaz, Islamabad',
        ),
        dropoff: const LocationPointModel(
          latitude: 33.7077,
          longitude: 73.0501,
          contactName: 'Ayesha Siddiqui',
          contactPhone: '03215551010',
          addressText: 'Jinnah Ave, Blue Area, Islamabad',
        ),
        items: const [
          OrderItemModel(id: 'i1', name: 'Chicken Karahi (Full)', quantity: 1),
          OrderItemModel(id: 'i2', name: 'Garlic Naan', quantity: 4),
        ],
        status: OrderStatus.assigned,
        notes: 'Keep hot box upright. Ring bell at reception.',
        codAmountPkr: 1850,
        deliveryFeePkr: 180,
        riderSharePkr: 140,
        distanceKm: 2.8,
        deliveryOtp: '4821',
        colorIndex: 0,
        createdAt: now.subtract(const Duration(minutes: 18)),
        updatedAt: now.subtract(const Duration(minutes: 12)),
      ),
      OrderModel(
        id: 'ord_102',
        orderNumber: 'SC-102',
        senderId: 'sender_01',
        riderId: 'rider_01',
        riderName: 'Bilal Raza',
        riderPhone: '03117654321',
        pickup: const LocationPointModel(
          latitude: 33.7294,
          longitude: 73.0766,
          contactName: 'Karachi Biryani House',
          contactPhone: '03009871122',
          addressText: 'Super Market, F-6 Markaz, Islamabad',
        ),
        dropoff: const LocationPointModel(
          latitude: 33.6884,
          longitude: 73.0332,
          contactName: 'Usman Tariq',
          contactPhone: '03335552020',
          addressText: 'House 22, St 14, G-9/2, Islamabad',
        ),
        items: const [
          OrderItemModel(id: 'i3', name: 'Special Beef Biryani', quantity: 3),
          OrderItemModel(id: 'i4', name: 'Mint Raita & Salad', quantity: 2),
        ],
        status: OrderStatus.pickedUp,
        notes: 'Call upon arrival at gate.',
        codAmountPkr: 2400,
        deliveryFeePkr: 220,
        riderSharePkr: 170,
        distanceKm: 5.4,
        deliveryOtp: '7394',
        colorIndex: 1,
        createdAt: now.subtract(const Duration(minutes: 34)),
        updatedAt: now.subtract(const Duration(minutes: 9)),
      ),
      OrderModel(
        id: 'ord_103',
        orderNumber: 'SC-103',
        senderId: 'sender_01',
        riderId: 'rider_01',
        riderName: 'Bilal Raza',
        riderPhone: '03117654321',
        pickup: const LocationPointModel(
          latitude: 33.6961,
          longitude: 73.0114,
          contactName: 'Tandoor Express',
          contactPhone: '03025558899',
          addressText: 'F-10 Markaz Main Plaza, Islamabad',
        ),
        dropoff: const LocationPointModel(
          latitude: 33.7024,
          longitude: 72.9765,
          contactName: 'Sana Malik',
          contactPhone: '03455553030',
          addressText: 'Apt 4B, Heights Tower, E-11/3, Islamabad',
        ),
        items: const [
          OrderItemModel(id: 'i5', name: 'Malai Boti Platter', quantity: 2),
        ],
        status: OrderStatus.onTheWay,
        notes: 'Hand to security if unavailable.',
        codAmountPkr: 1200,
        deliveryFeePkr: 210,
        riderSharePkr: 160,
        distanceKm: 4.1,
        deliveryOtp: '5190',
        colorIndex: 2,
        createdAt: now.subtract(const Duration(minutes: 45)),
        updatedAt: now.subtract(const Duration(minutes: 4)),
      ),
      OrderModel(
        id: 'ord_104',
        orderNumber: 'SC-104',
        senderId: 'sender_01',
        riderId: 'rider_01',
        riderName: 'Bilal Raza',
        riderPhone: '03117654321',
        pickup: const LocationPointModel(
          latitude: 33.6998,
          longitude: 73.0507,
          contactName: 'Chai & Paratha Hub',
          contactPhone: '03015554477',
          addressText: 'G-8 Markaz Food Court, Islamabad',
        ),
        dropoff: const LocationPointModel(
          latitude: 33.7131,
          longitude: 73.0389,
          contactName: 'Hamza Nawaz',
          contactPhone: '03125556060',
          addressText: 'House 8, Street 31, F-8/4, Islamabad',
        ),
        items: const [
          OrderItemModel(id: 'i6', name: 'Doodh Patti Flask', quantity: 1),
          OrderItemModel(id: 'i7', name: 'Aloo Cheese Paratha', quantity: 3),
        ],
        status: OrderStatus.assigned,
        notes: 'Hot liquid flask — handle carefully.',
        codAmountPkr: 950,
        deliveryFeePkr: 160,
        riderSharePkr: 125,
        distanceKm: 2.3,
        deliveryOtp: '2048',
        colorIndex: 3,
        createdAt: now.subtract(const Duration(minutes: 10)),
        updatedAt: now.subtract(const Duration(minutes: 6)),
      ),
      OrderModel(
        id: 'ord_099',
        orderNumber: 'SC-099',
        senderId: 'sender_01',
        riderId: 'rider_01',
        riderName: 'Bilal Raza',
        riderPhone: '03117654321',
        pickup: const LocationPointModel(
          latitude: 33.7215,
          longitude: 73.0561,
          contactName: 'Spice Cloud Kitchen',
          contactPhone: '03001234567',
          addressText: 'Plot 14, F-7 Markaz, Islamabad',
        ),
        dropoff: const LocationPointModel(
          latitude: 33.6841,
          longitude: 72.9882,
          contactName: 'Zainab Ali',
          contactPhone: '03005559988',
          addressText: 'House 19, Street 5, F-11/2, Islamabad',
        ),
        items: const [
          OrderItemModel(id: 'i8', name: 'Family BBQ Deal', quantity: 1),
        ],
        status: OrderStatus.delivered,
        codAmountPkr: 3100,
        deliveryFeePkr: 260,
        riderSharePkr: 200,
        distanceKm: 7.2,
        deliveryOtp: '8831',
        colorIndex: 4,
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 2, minutes: 20)),
      ),
      OrderModel(
        id: 'ord_098',
        orderNumber: 'SC-098',
        senderId: 'sender_01',
        riderId: 'rider_01',
        riderName: 'Bilal Raza',
        riderPhone: '03117654321',
        pickup: const LocationPointModel(
          latitude: 33.7215,
          longitude: 73.0561,
          contactName: 'Spice Cloud Kitchen',
          contactPhone: '03001234567',
          addressText: 'Plot 14, F-7 Markaz, Islamabad',
        ),
        dropoff: const LocationPointModel(
          latitude: 33.6691,
          longitude: 73.0748,
          contactName: 'Kamran Shah',
          contactPhone: '03345557711',
          addressText: 'Plot 9, St 12, I-8/3, Islamabad',
        ),
        items: const [
          OrderItemModel(id: 'i9', name: 'Pulao Kabab Box', quantity: 2),
        ],
        status: OrderStatus.delivered,
        codAmountPkr: 1600,
        deliveryFeePkr: 240,
        riderSharePkr: 185,
        distanceKm: 6.4,
        deliveryOtp: '6412',
        colorIndex: 5,
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 4, minutes: 10)),
      ),
    ]);
  }

  @override
  Future<List<OrderModel>> getOrders({String? roleFilter, String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 180));
    return List<OrderModel>.from(_orders);
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<OrderModel> createOrder({
    required String senderId,
    required LocationPointEntity pickup,
    required LocationPointEntity dropoff,
    required List<OrderItemEntity> items,
    required double codAmountPkr,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final distanceKm = _haversineKm(
      pickup.latitude,
      pickup.longitude,
      dropoff.latitude,
      dropoff.longitude,
    );
    final fee = (120 + (distanceKm * 28)).roundToDouble().clamp(150.0, 900.0);
    final riderShare = (fee * 0.78).roundToDouble();
    final now = DateTime.now();
    final orderId = 'ord_${_uuid.v4().substring(0, 6)}';
    final orderNumber = 'SC-${_nextOrderSeq++}';
    final otp = (1000 + Random().nextInt(8999)).toString();
    final colorIdx = _orders.length;

    final newOrder = OrderModel(
      id: orderId,
      orderNumber: orderNumber,
      senderId: senderId,
      riderId: 'rider_01',
      riderName: 'Bilal Raza',
      riderPhone: '03117654321',
      pickup: LocationPointModel.fromEntity(pickup),
      dropoff: LocationPointModel.fromEntity(dropoff),
      items: items.map(OrderItemModel.fromEntity).toList(),
      status: OrderStatus.assigned,
      notes: notes,
      codAmountPkr: codAmountPkr,
      deliveryFeePkr: fee,
      riderSharePkr: riderShare,
      distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
      deliveryOtp: otp,
      colorIndex: colorIdx,
      createdAt: now,
      updatedAt: now,
    );

    _orders.insert(0, newOrder);

    realtimeService.emit(
      RealtimeEvent(
        eventName: RealtimeEventNames.riderAssigned,
        orderId: orderId,
        payload: {
          'order_id': orderId,
          'rider_id': 'rider_01',
          'rider_name': 'Bilal Raza',
          'status': OrderStatus.assigned.name,
        },
      ),
    );

    return newOrder;
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    String? proofPhotoPath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) {
      throw Exception('Order $orderId not found.');
    }

    final existing = _orders[idx];
    final updated = OrderModel.fromEntity(
      existing.copyWith(
        status: newStatus,
        proofPhotoPath: proofPhotoPath ?? existing.proofPhotoPath,
        updatedAt: DateTime.now(),
      ),
    );
    _orders[idx] = updated;

    realtimeService.emit(
      RealtimeEvent(
        eventName: RealtimeEventNames.orderStatusUpdated,
        orderId: orderId,
        payload: {
          'order_id': orderId,
          'status': newStatus.name,
          'updated_at': updated.updatedAt.toIso8601String(),
        },
      ),
    );

    return updated;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final dist = r * c;
    return dist < 0.5 ? 1.5 : dist;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);
}
