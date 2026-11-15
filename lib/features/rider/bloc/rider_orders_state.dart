import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/rider/model/earnings_model.dart';

enum RiderOrdersStatus { initial, loading, success, error }

class RiderOrdersState extends Equatable {
  final RiderOrdersStatus status;
  final List<OrderModel> allOrders;
  final List<OrderModel> filteredOrders;
  final String activeFilter;
  final EarningsModel? earnings;
  final String? errorMessage;

  const RiderOrdersState({
    this.status = RiderOrdersStatus.initial,
    this.allOrders = const [],
    this.filteredOrders = const [],
    this.activeFilter = 'All',
    this.earnings,
    this.errorMessage,
  });

  RiderOrdersState copyWith({
    RiderOrdersStatus? status,
    List<OrderModel>? allOrders,
    List<OrderModel>? filteredOrders,
    String? activeFilter,
    EarningsModel? earnings,
    String? errorMessage,
  }) {
    return RiderOrdersState(
      status: status ?? this.status,
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      activeFilter: activeFilter ?? this.activeFilter,
      earnings: earnings ?? this.earnings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allOrders,
        filteredOrders,
        activeFilter,
        earnings,
        errorMessage,
      ];
}
