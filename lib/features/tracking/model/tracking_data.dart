import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/tracking/model/rider_location.dart';

class TrackingData extends Equatable {
  final OrderModel order;
  final RiderLocation? liveRiderLocation;
  final bool isLiveConnected;
  final String? connectionError;

  const TrackingData({
    required this.order,
    this.liveRiderLocation,
    this.isLiveConnected = false,
    this.connectionError,
  });

  TrackingData copyWith({
    OrderModel? order,
    RiderLocation? liveRiderLocation,
    bool? isLiveConnected,
    String? connectionError,
  }) {
    return TrackingData(
      order: order ?? this.order,
      liveRiderLocation: liveRiderLocation ?? this.liveRiderLocation,
      isLiveConnected: isLiveConnected ?? this.isLiveConnected,
      connectionError: connectionError ?? this.connectionError,
    );
  }

  @override
  List<Object?> get props => [order, liveRiderLocation, isLiveConnected, connectionError];
}
