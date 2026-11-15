import 'package:equatable/equatable.dart';

abstract class RiderOrdersEvent extends Equatable {
  const RiderOrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadRiderOrdersEvent extends RiderOrdersEvent {
  const LoadRiderOrdersEvent();
}

class FilterRiderOrdersEvent extends RiderOrdersEvent {
  final String statusFilter; // 'All', 'Waiting', 'Assigned', 'Picked Up', 'On Road', 'Delivered'
  const FilterRiderOrdersEvent(this.statusFilter);

  @override
  List<Object?> get props => [statusFilter];
}

class UpdateRiderOrderStatusEvent extends RiderOrdersEvent {
  final String orderId;
  final String newStatus;
  const UpdateRiderOrderStatusEvent({required this.orderId, required this.newStatus});

  @override
  List<Object?> get props => [orderId, newStatus];
}
