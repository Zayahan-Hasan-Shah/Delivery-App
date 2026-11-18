import 'package:delivery_app/features/orders/data/models/location_point_model.dart';
import 'package:delivery_app/features/orders/data/models/order_item_model.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.senderId,
    super.riderId,
    super.riderName,
    super.riderPhone,
    required super.pickup,
    required super.dropoff,
    required super.items,
    required super.status,
    super.notes,
    super.codAmountPkr,
    super.deliveryFeePkr,
    super.riderSharePkr,
    super.distanceKm,
    super.deliveryOtp,
    super.proofPhotoPath,
    super.colorIndex,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      senderId: entity.senderId,
      riderId: entity.riderId,
      riderName: entity.riderName,
      riderPhone: entity.riderPhone,
      pickup: LocationPointModel.fromEntity(entity.pickup),
      dropoff: LocationPointModel.fromEntity(entity.dropoff),
      items: entity.items.map(OrderItemModel.fromEntity).toList(),
      status: entity.status,
      notes: entity.notes,
      codAmountPkr: entity.codAmountPkr,
      deliveryFeePkr: entity.deliveryFeePkr,
      riderSharePkr: entity.riderSharePkr,
      distanceKm: entity.distanceKm,
      deliveryOtp: entity.deliveryOtp,
      proofPhotoPath: entity.proofPhotoPath,
      colorIndex: entity.colorIndex,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      riderId: json['rider_id']?.toString(),
      riderName: json['rider_name']?.toString(),
      riderPhone: json['rider_phone']?.toString(),
      pickup: LocationPointModel.fromJson(
        (json['pickup'] as Map<String, dynamic>?) ?? const {},
      ),
      dropoff: LocationPointModel.fromJson(
        (json['dropoff'] as Map<String, dynamic>?) ?? const {},
      ),
      items: ((json['items'] as List?) ?? const [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: OrderStatus.fromString(json['status']?.toString() ?? 'placed'),
      notes: json['notes']?.toString(),
      codAmountPkr: (json['cod_amount_pkr'] as num?)?.toDouble() ?? 0,
      deliveryFeePkr: (json['delivery_fee_pkr'] as num?)?.toDouble() ?? 180,
      riderSharePkr: (json['rider_share_pkr'] as num?)?.toDouble() ?? 135,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 3.0,
      deliveryOtp: json['delivery_otp']?.toString() ?? '4829',
      proofPhotoPath: json['proof_photo_path']?.toString(),
      colorIndex: (json['color_index'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'sender_id': senderId,
        'rider_id': riderId,
        'rider_name': riderName,
        'rider_phone': riderPhone,
        'pickup': LocationPointModel.fromEntity(pickup).toJson(),
        'dropoff': LocationPointModel.fromEntity(dropoff).toJson(),
        'items': items.map((e) => OrderItemModel.fromEntity(e).toJson()).toList(),
        'status': status.name,
        'notes': notes,
        'cod_amount_pkr': codAmountPkr,
        'delivery_fee_pkr': deliveryFeePkr,
        'rider_share_pkr': riderSharePkr,
        'distance_km': distanceKm,
        'delivery_otp': deliveryOtp,
        'proof_photo_path': proofPhotoPath,
        'color_index': colorIndex,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
