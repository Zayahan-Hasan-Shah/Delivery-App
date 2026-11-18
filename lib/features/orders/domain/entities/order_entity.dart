import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/orders/domain/entities/location_point_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_item_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String senderId;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final LocationPointEntity pickup;
  final LocationPointEntity dropoff;
  final List<OrderItemEntity> items;
  final OrderStatus status;
  final String? notes;
  final double codAmountPkr;
  final double deliveryFeePkr;
  final double riderSharePkr;
  final double distanceKm;
  final String deliveryOtp;
  final String? proofPhotoPath;
  final int colorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.senderId,
    this.riderId,
    this.riderName,
    this.riderPhone,
    required this.pickup,
    required this.dropoff,
    required this.items,
    required this.status,
    this.notes,
    this.codAmountPkr = 0,
    this.deliveryFeePkr = 180,
    this.riderSharePkr = 135,
    this.distanceKm = 3.2,
    this.deliveryOtp = '4829',
    this.proofPhotoPath,
    this.colorIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    String? senderId,
    String? riderId,
    String? riderName,
    String? riderPhone,
    LocationPointEntity? pickup,
    LocationPointEntity? dropoff,
    List<OrderItemEntity>? items,
    OrderStatus? status,
    String? notes,
    double? codAmountPkr,
    double? deliveryFeePkr,
    double? riderSharePkr,
    double? distanceKm,
    String? deliveryOtp,
    String? proofPhotoPath,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      senderId: senderId ?? this.senderId,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      items: items ?? this.items,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      codAmountPkr: codAmountPkr ?? this.codAmountPkr,
      deliveryFeePkr: deliveryFeePkr ?? this.deliveryFeePkr,
      riderSharePkr: riderSharePkr ?? this.riderSharePkr,
      distanceKm: distanceKm ?? this.distanceKm,
      deliveryOtp: deliveryOtp ?? this.deliveryOtp,
      proofPhotoPath: proofPhotoPath ?? this.proofPhotoPath,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        senderId,
        riderId,
        riderName,
        riderPhone,
        pickup,
        dropoff,
        items,
        status,
        notes,
        codAmountPkr,
        deliveryFeePkr,
        riderSharePkr,
        distanceKm,
        deliveryOtp,
        proofPhotoPath,
        colorIndex,
        createdAt,
        updatedAt,
      ];
}
