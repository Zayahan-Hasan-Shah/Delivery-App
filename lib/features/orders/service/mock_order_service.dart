import 'dart:async';
import 'package:delivery_app/features/orders/service/order_service.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/orders/model/order_status.dart';
import 'package:delivery_app/features/orders/model/location_point_model.dart';
import 'package:delivery_app/features/orders/model/order_item_model.dart';
import 'package:delivery_app/features/authentication/model/user_model.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';
import 'package:delivery_app/features/tracking/model/rider_location.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';
import 'package:delivery_app/core/constant/event_names.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

class MockOrderService implements OrderService {
  final RealtimeService realtimeService;

  static final List<OrderModel> _inMemoryOrders = [
    OrderModel(
      id: 'ORD-1001',
      orderNumber: 'ORD-1001',
      status: OrderStatus.onTheWay,
      eta: 'Arriving in 14 min',
      customer: const UserModel(
        id: 'USR-CUST-001',
        name: 'Alice Johnson',
        email: 'customer@delivery.com',
        phone: '+1 555-0101',
        role: UserRole.customer,
      ),
      client: const UserModel(
        id: 'USR-CLNT-002',
        name: 'Apex Merchant Co.',
        email: 'client@delivery.com',
        phone: '+1 555-0202',
        role: UserRole.client,
      ),
      rider: const UserModel(
        id: 'USR-RIDR-003',
        name: 'Michael Swift',
        email: 'rider@delivery.com',
        phone: '+1 555-0303',
        role: UserRole.rider,
      ),
      pickup: const LocationPointModel(
        contactName: 'Apex Warehouse',
        contactPhone: '+1 555-0202',
        address: '45 Industrial Blvd, Sector B',
        latitude: 33.6944,
        longitude: 73.0579,
      ),
      dropoff: const LocationPointModel(
        contactName: 'Alice Johnson',
        contactPhone: '+1 555-0101',
        address: 'Apt 4B, Blue Skyline Towers',
        latitude: 33.7150,
        longitude: 73.0720,
      ),
      items: const [
        OrderItemModel(id: 'ITM-1', name: 'Legal Documents Folder', quantity: 2),
        OrderItemModel(id: 'ITM-2', name: 'Office Laptop Package', quantity: 1),
      ],
      riderNote: 'Please ring bell 4B or call when downstairs.',
      riderLocation: RiderLocation(
        latitude: 33.7040,
        longitude: 73.0640,
        heading: 35.0,
        speed: 28.5,
        timestamp: DateTime.now(),
      ),
      statusHistory: [
        OrderStatusHistoryItem(
          status: OrderStatus.placed,
          timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
        ),
        OrderStatusHistoryItem(
          status: OrderStatus.assigned,
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          note: 'Assigned to Michael Swift based on proximity.',
        ),
        OrderStatusHistoryItem(
          status: OrderStatus.pickedUp,
          timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        OrderStatusHistoryItem(
          status: OrderStatus.onTheWay,
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    OrderModel(
      id: 'ORD-1002',
      orderNumber: 'ORD-1002',
      status: OrderStatus.assigned,
      eta: 'Arriving in 22 min',
      customer: const UserModel(
        id: 'USR-CUST-004',
        name: 'Sarah Connor',
        email: 'sarah@example.com',
        phone: '+1 555-0404',
        role: UserRole.customer,
      ),
      client: const UserModel(
        id: 'USR-CLNT-002',
        name: 'Apex Merchant Co.',
        email: 'client@delivery.com',
        phone: '+1 555-0202',
        role: UserRole.client,
      ),
      rider: const UserModel(
        id: 'USR-RIDR-003',
        name: 'Michael Swift',
        email: 'rider@delivery.com',
        phone: '+1 555-0303',
        role: UserRole.rider,
      ),
      pickup: const LocationPointModel(
        contactName: 'Express Pharmacy',
        contactPhone: '+1 555-0505',
        address: '12 Central Plaza',
        latitude: 33.6820,
        longitude: 73.0410,
      ),
      dropoff: const LocationPointModel(
        contactName: 'Sarah Connor',
        contactPhone: '+1 555-0404',
        address: 'Villa 19, Green Meadows',
        latitude: 33.6610,
        longitude: 73.0290,
      ),
      items: const [
        OrderItemModel(id: 'ITM-3', name: 'Prescription Medical Box', quantity: 1),
      ],
      riderNote: 'Fragile package, handle with care.',
      riderLocation: RiderLocation(
        latitude: 33.6815,
        longitude: 73.0405,
        heading: 90.0,
        speed: 15.0,
        timestamp: DateTime.now(),
      ),
      statusHistory: [
        OrderStatusHistoryItem(
          status: OrderStatus.placed,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        OrderStatusHistoryItem(
          status: OrderStatus.assigned,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    OrderModel(
      id: 'ORD-1003',
      orderNumber: 'ORD-1003',
      status: OrderStatus.delivered,
      customer: const UserModel(
        id: 'USR-CUST-001',
        name: 'Alice Johnson',
        email: 'customer@delivery.com',
        phone: '+1 555-0101',
        role: UserRole.customer,
      ),
      pickup: const LocationPointModel(
        contactName: 'City Bakery',
        contactPhone: '+1 555-0606',
        address: 'Block 7, Commercial Hub',
        latitude: 33.7010,
        longitude: 73.0550,
      ),
      dropoff: const LocationPointModel(
        contactName: 'Alice Johnson',
        contactPhone: '+1 555-0101',
        address: 'Apt 4B, Blue Skyline Towers',
        latitude: 33.7150,
        longitude: 73.0720,
      ),
      items: const [
        OrderItemModel(id: 'ITM-4', name: 'Artisan Pastry Box', quantity: 3),
      ],
      statusHistory: [
        OrderStatusHistoryItem(
          status: OrderStatus.placed,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        OrderStatusHistoryItem(
          status: OrderStatus.delivered,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          note: 'Signed by recipient.',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  MockOrderService({required this.realtimeService});

  @override
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_inMemoryOrders);
  }

  @override
  Future<List<OrderModel>> getActiveOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _inMemoryOrders.where((order) => order.status.isActive).toList();
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final match = _inMemoryOrders.firstWhere(
      (o) => o.id == orderId || o.orderNumber == orderId,
      orElse: () => throw Exception('Order not found with ID: $orderId'),
    );
    return match;
  }

  @override
  Future<OrderModel> createOrder({
    required LocationPointModel pickup,
    required LocationPointModel dropoff,
    required List<OrderItemModel> items,
    String? riderNote,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final newNumber = 'ORD-${1000 + _inMemoryOrders.length + 1}';
    final now = DateTime.now();

    final newOrder = OrderModel(
      id: newNumber,
      orderNumber: newNumber,
      status: OrderStatus.placed,
      pickup: pickup,
      dropoff: dropoff,
      items: items,
      riderNote: riderNote,
      createdAt: now,
      eta: 'Calculating...',
      statusHistory: [
        OrderStatusHistoryItem(
          status: OrderStatus.placed,
          timestamp: now,
          note: 'Order registered in logistics system.',
        ),
      ],
    );

    _inMemoryOrders.insert(0, newOrder);

    // Simulate automatic rider assignment based on proximity after 3 seconds
    Timer(const Duration(seconds: 3), () {
      final assignedRider = const UserModel(
        id: 'USR-RIDR-003',
        name: 'Michael Swift',
        email: 'rider@delivery.com',
        phone: '+1 555-0303',
        role: UserRole.rider,
      );

      final updatedOrder = newOrder.copyWith(
        status: OrderStatus.assigned,
        rider: assignedRider,
        eta: 'Arriving in 15 min',
        riderLocation: RiderLocation(
          latitude: pickup.latitude - 0.005,
          longitude: pickup.longitude - 0.005,
          timestamp: DateTime.now(),
        ),
        statusHistory: [
          ...newOrder.statusHistory,
          OrderStatusHistoryItem(
            status: OrderStatus.assigned,
            timestamp: DateTime.now(),
            note: 'Auto-assigned to Michael Swift (closest available rider).',
          ),
        ],
      );

      // Update in memory
      final index = _inMemoryOrders.indexWhere((o) => o.id == newNumber);
      if (index != -1) {
        _inMemoryOrders[index] = updatedOrder;
      }

      // Emit real-time assignment event
      realtimeService.emit(
        RealtimeEvent(
          eventName: RealtimeEventNames.riderAssigned,
          orderId: newNumber,
          payload: {
            'orderId': newNumber,
            'status': OrderStatus.assigned.name,
            'rider': assignedRider.toJson(),
            'eta': 'Arriving in 15 min',
          },
        ),
      );

      AppLogger.info('Simulated proximity rider auto-assignment for order: $newNumber', tag: 'MockOrderService');
    });

    return newOrder;
  }

  @override
  Future<OrderModel> updateOrderStatus(String orderId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _inMemoryOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) throw Exception('Order not found');

    final status = OrderStatus.fromString(newStatus);
    final existing = _inMemoryOrders[index];

    final updated = existing.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      statusHistory: [
        ...existing.statusHistory,
        OrderStatusHistoryItem(
          status: status,
          timestamp: DateTime.now(),
        ),
      ],
    );

    _inMemoryOrders[index] = updated;

    // Emit realtime event
    realtimeService.emit(
      RealtimeEvent(
        eventName: RealtimeEventNames.orderStatusUpdated,
        orderId: orderId,
        payload: {
          'orderId': orderId,
          'status': status.name,
        },
      ),
    );

    return updated;
  }
}
