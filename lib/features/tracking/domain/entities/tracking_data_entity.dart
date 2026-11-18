import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/tracking/domain/entities/rider_location_entity.dart';

class TrackingDataEntity extends Equatable {
  final OrderEntity order;
  final RiderLocationEntity? riderLocation;
  final String etaMinutes;

  const TrackingDataEntity({
    required this.order,
    this.riderLocation,
    this.etaMinutes = '12 min',
  });

  TrackingDataEntity copyWith({
    OrderEntity? order,
    RiderLocationEntity? riderLocation,
    String? etaMinutes,
  }) {
    return TrackingDataEntity(
      order: order ?? this.order,
      riderLocation: riderLocation ?? this.riderLocation,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }

  @override
  List<Object?> get props => [order, riderLocation, etaMinutes];
}
