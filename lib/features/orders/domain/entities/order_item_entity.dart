import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String name;
  final int quantity;
  final String? notes;

  const OrderItemEntity({
    required this.id,
    required this.name,
    required this.quantity,
    this.notes,
  });

  @override
  List<Object?> get props => [id, name, quantity, notes];
}
