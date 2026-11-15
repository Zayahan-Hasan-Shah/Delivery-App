import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/orders/model/order_status.dart';
import 'package:delivery_app/features/orders/model/location_point_model.dart';
import 'package:delivery_app/features/orders/model/order_item_model.dart';
import 'package:delivery_app/features/authentication/model/user_model.dart';
import 'package:delivery_app/features/tracking/model/rider_location.dart';

class OrderStatusHistoryItem extends Equatable {
  final OrderStatus status;
  final DateTime timestamp;
  final String? note;

  const OrderStatusHistoryItem({
    required this.status,
    required this.timestamp,
    this.note,
  });

  factory OrderStatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryItem(
      status: OrderStatus.fromString(json['status'] as String?),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  @override
  List<Object?> get props => [status, timestamp, note];
}

class OrderModel extends Equatable {
  final String id;
  final String orderNumber;
  final UserModel? customer;
  final UserModel? client;
  final UserModel? rider;
  final LocationPointModel pickup;
  final LocationPointModel dropoff;
  final List<OrderItemModel> items;
  final String? riderNote;
  final OrderStatus status;
  final List<OrderStatusHistoryItem> statusHistory;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? eta; // e.g. "Arriving in 18 min"
  final RiderLocation? riderLocation;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    this.customer,
    this.client,
    this.rider,
    required this.pickup,
    required this.dropoff,
    required this.items,
    this.riderNote,
    required this.status,
    this.statusHistory = const [],
    required this.createdAt,
    this.updatedAt,
    this.eta,
    this.riderLocation,
  });

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    UserModel? customer,
    UserModel? client,
    UserModel? rider,
    LocationPointModel? pickup,
    LocationPointModel? dropoff,
    List<OrderItemModel>? items,
    String? riderNote,
    OrderStatus? status,
    List<OrderStatusHistoryItem>? statusHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? eta,
    RiderLocation? riderLocation,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customer: customer ?? this.customer,
      client: client ?? this.client,
      rider: rider ?? this.rider,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      items: items ?? this.items,
      riderNote: riderNote ?? this.riderNote,
      status: status ?? this.status,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      eta: eta ?? this.eta,
      riderLocation: riderLocation ?? this.riderLocation,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      customer: json['customer'] != null
          ? UserModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      client: json['client'] != null
          ? UserModel.fromJson(json['client'] as Map<String, dynamic>)
          : null,
      rider: json['rider'] != null
          ? UserModel.fromJson(json['rider'] as Map<String, dynamic>)
          : null,
      pickup: LocationPointModel.fromJson(json['pickup'] as Map<String, dynamic>? ?? {}),
      dropoff: LocationPointModel.fromJson(json['dropoff'] as Map<String, dynamic>? ?? {}),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      riderNote: json['riderNote'] as String?,
      status: OrderStatus.fromString(json['status'] as String?),
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((item) => OrderStatusHistoryItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      eta: json['eta'] as String?,
      riderLocation: json['riderLocation'] != null
          ? RiderLocation.fromJson(json['riderLocation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customer': customer?.toJson(),
      'client': client?.toJson(),
      'rider': rider?.toJson(),
      'pickup': pickup.toJson(),
      'dropoff': dropoff.toJson(),
      'items': items.map((i) => i.toJson()).toList(),
      'riderNote': riderNote,
      'status': status.name,
      'statusHistory': statusHistory.map((h) => h.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'eta': eta,
      'riderLocation': riderLocation?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customer,
        client,
        rider,
        pickup,
        dropoff,
        items,
        riderNote,
        status,
        statusHistory,
        createdAt,
        updatedAt,
        eta,
        riderLocation,
      ];
}
