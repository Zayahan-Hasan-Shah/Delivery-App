import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';

enum RiderOrderFilter { all, active, delivered }

abstract class RiderOrdersEvent extends Equatable {
  const RiderOrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadRiderDashboardEvent extends RiderOrdersEvent {
  final bool initialOnline;

  const LoadRiderDashboardEvent({this.initialOnline = true});

  @override
  List<Object?> get props => [initialOnline];
}

class ToggleRiderOnlineShiftEvent extends RiderOrdersEvent {
  final bool isOnline;

  const ToggleRiderOnlineShiftEvent(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class SelectRiderOrderOnMapEvent extends RiderOrdersEvent {
  final String? orderId;

  const SelectRiderOrderOnMapEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateRiderOrderStatusEvent extends RiderOrdersEvent {
  final String orderId;
  final OrderStatus newStatus;

  const UpdateRiderOrderStatusEvent({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [orderId, newStatus];
}

class ChangeRiderOrderFilterEvent extends RiderOrdersEvent {
  final RiderOrderFilter filter;

  const ChangeRiderOrderFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class RiderLiveLocationUpdatedEvent extends RiderOrdersEvent {
  final double latitude;
  final double longitude;

  const RiderLiveLocationUpdatedEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
