import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/tracking/domain/entities/rider_location_entity.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrackingOrdersEvent extends TrackingEvent {
  final String? initialOrderId;

  const LoadTrackingOrdersEvent({this.initialOrderId});

  @override
  List<Object?> get props => [initialOrderId];
}

class SelectTrackingOrderEvent extends TrackingEvent {
  final String orderId;

  const SelectTrackingOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class TrackingRiderLocationReceivedEvent extends TrackingEvent {
  final RiderLocationEntity location;

  const TrackingRiderLocationReceivedEvent(this.location);

  @override
  List<Object?> get props => [location];
}
