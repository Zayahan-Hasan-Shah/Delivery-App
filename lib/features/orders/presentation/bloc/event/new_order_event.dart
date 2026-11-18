import 'package:equatable/equatable.dart';

abstract class NewOrderEvent extends Equatable {
  const NewOrderEvent();

  @override
  List<Object?> get props => [];
}

class SetActivePinTabEvent extends NewOrderEvent {
  final int tabIndex;

  const SetActivePinTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class FetchCurrentSenderLocationEvent extends NewOrderEvent {
  final bool updatePickupCoordinates;

  const FetchCurrentSenderLocationEvent({
    this.updatePickupCoordinates = true,
  });

  @override
  List<Object?> get props => [updatePickupCoordinates];
}

class UpdatePickupCoordinatesEvent extends NewOrderEvent {
  final double latitude;
  final double longitude;

  const UpdatePickupCoordinatesEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class UpdateDropoffCoordinatesEvent extends NewOrderEvent {
  final double latitude;
  final double longitude;

  const UpdateDropoffCoordinatesEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class UpdatePickupDetailsEvent extends NewOrderEvent {
  final String name;
  final String phone;
  final String address;

  const UpdatePickupDetailsEvent({
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [name, phone, address];
}

class UpdateDropoffDetailsEvent extends NewOrderEvent {
  final String name;
  final String phone;
  final String address;

  const UpdateDropoffDetailsEvent({
    required this.name,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [name, phone, address];
}

class UpdateCodAmountEvent extends NewOrderEvent {
  final double codAmountPkr;

  const UpdateCodAmountEvent(this.codAmountPkr);

  @override
  List<Object?> get props => [codAmountPkr];
}

class UpdateOrderNotesEvent extends NewOrderEvent {
  final String notes;

  const UpdateOrderNotesEvent(this.notes);

  @override
  List<Object?> get props => [notes];
}

class AddOrderItemEvent extends NewOrderEvent {
  final String name;
  final int quantity;
  final String? notes;

  const AddOrderItemEvent({
    required this.name,
    required this.quantity,
    this.notes,
  });

  @override
  List<Object?> get props => [name, quantity, notes];
}

class RemoveOrderItemEvent extends NewOrderEvent {
  final String itemId;

  const RemoveOrderItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class SubmitOrderEvent extends NewOrderEvent {
  final String senderId;

  const SubmitOrderEvent({this.senderId = 'sender_01'});

  @override
  List<Object?> get props => [senderId];
}

class ResetNewOrderEvent extends NewOrderEvent {
  const ResetNewOrderEvent();
}
