import 'package:equatable/equatable.dart';

abstract class NewOrderEvent extends Equatable {
  const NewOrderEvent();

  @override
  List<Object?> get props => [];
}

class SetActivePinTabEvent extends NewOrderEvent {
  final int tabIndex; // 0: Pickup, 1: Drop-off
  const SetActivePinTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class UpdatePickupCoordinatesEvent extends NewOrderEvent {
  final double latitude;
  final double longitude;
  const UpdatePickupCoordinatesEvent({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class UpdateDropoffCoordinatesEvent extends NewOrderEvent {
  final double latitude;
  final double longitude;
  const UpdateDropoffCoordinatesEvent({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class UpdatePickupDetailsEvent extends NewOrderEvent {
  final String name;
  final String phone;
  final String address;
  const UpdatePickupDetailsEvent({required this.name, required this.phone, required this.address});

  @override
  List<Object?> get props => [name, phone, address];
}

class UpdateDropoffDetailsEvent extends NewOrderEvent {
  final String name;
  final String phone;
  final String address;
  const UpdateDropoffDetailsEvent({required this.name, required this.phone, required this.address});

  @override
  List<Object?> get props => [name, phone, address];
}

class AddOrderItemEvent extends NewOrderEvent {
  final String name;
  final int quantity;
  const AddOrderItemEvent({required this.name, required this.quantity});

  @override
  List<Object?> get props => [name, quantity];
}

class EditOrderItemEvent extends NewOrderEvent {
  final String itemId;
  final String name;
  final int quantity;
  const EditOrderItemEvent({required this.itemId, required this.name, required this.quantity});

  @override
  List<Object?> get props => [itemId, name, quantity];
}

class RemoveOrderItemEvent extends NewOrderEvent {
  final String itemId;
  const RemoveOrderItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class UpdateRiderNoteEvent extends NewOrderEvent {
  final String note;
  const UpdateRiderNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class FetchCurrentCustomerLocationEvent extends NewOrderEvent {
  final bool updatePickupCoordinates;
  const FetchCurrentCustomerLocationEvent({this.updatePickupCoordinates = true});

  @override
  List<Object?> get props => [updatePickupCoordinates];
}

class SubmitOrderEvent extends NewOrderEvent {
  const SubmitOrderEvent();
}

class ResetOrderFormEvent extends NewOrderEvent {
  const ResetOrderFormEvent();
}
