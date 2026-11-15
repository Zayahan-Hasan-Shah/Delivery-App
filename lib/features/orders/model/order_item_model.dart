import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  final String id;
  final String name;
  final int quantity;

  const OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
  });

  OrderItemModel copyWith({
    String? id,
    String? name,
    int? quantity,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
    );
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => [id, name, quantity];
}
