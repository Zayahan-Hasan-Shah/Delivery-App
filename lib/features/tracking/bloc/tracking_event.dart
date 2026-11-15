import 'package:equatable/equatable.dart';
import '../model/rider_location.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrackableOrdersEvent extends TrackingEvent {
  final String? initialOrderId;
  const LoadTrackableOrdersEvent({this.initialOrderId});

  @override
  List<Object?> get props => [initialOrderId];
}

class SelectOrderForTrackingEvent extends TrackingEvent {
  final String orderId;
  const SelectOrderForTrackingEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class LiveRiderLocationReceivedEvent extends TrackingEvent {
  final String orderId;
  final RiderLocation location;
  const LiveRiderLocationReceivedEvent({required this.orderId, required this.location});

  @override
  List<Object?> get props => [orderId, location];
}

class LiveOrderStatusUpdatedEvent extends TrackingEvent {
  final String orderId;
  final String status;
  const LiveOrderStatusUpdatedEvent({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}
