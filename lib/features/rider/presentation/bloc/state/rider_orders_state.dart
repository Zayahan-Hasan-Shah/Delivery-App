import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/rider/domain/entities/earnings_entity.dart';
import 'package:delivery_app/features/rider/presentation/bloc/event/rider_orders_event.dart';

class RiderOrdersState extends Equatable {
  final bool isLoading;
  final bool isOnline;
  final bool isBackgroundTrackingActive;
  final List<OrderEntity> allOrders;
  final Map<String, Color> orderColors;
  final String? selectedOrderId;
  final RiderOrderFilter activeFilter;
  final EarningsEntity? earnings;
  final double riderLatitude;
  final double riderLongitude;
  final String? errorMessage;

  const RiderOrdersState({
    this.isLoading = false,
    this.isOnline = true,
    this.isBackgroundTrackingActive = false,
    this.allOrders = const [],
    this.orderColors = const {},
    this.selectedOrderId,
    this.activeFilter = RiderOrderFilter.all,
    this.earnings,
    this.riderLatitude = AppConstants.defaultLatitude + 0.02,
    this.riderLongitude = AppConstants.defaultLongitude,
    this.errorMessage,
  });

  List<OrderEntity> get activeOrders =>
      allOrders.where((o) => o.status.isActive).toList();

  List<OrderEntity> get completedOrders =>
      allOrders.where((o) => o.status.isTerminal).toList();

  List<OrderEntity> get filteredLogOrders {
    switch (activeFilter) {
      case RiderOrderFilter.active:
        return activeOrders;
      case RiderOrderFilter.delivered:
        return completedOrders;
      case RiderOrderFilter.all:
        return allOrders;
    }
  }

  RiderOrdersState copyWith({
    bool? isLoading,
    bool? isOnline,
    bool? isBackgroundTrackingActive,
    List<OrderEntity>? allOrders,
    Map<String, Color>? orderColors,
    String? selectedOrderId,
    bool clearSelectedOrder = false,
    RiderOrderFilter? activeFilter,
    EarningsEntity? earnings,
    double? riderLatitude,
    double? riderLongitude,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RiderOrdersState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      isBackgroundTrackingActive:
          isBackgroundTrackingActive ?? this.isBackgroundTrackingActive,
      allOrders: allOrders ?? this.allOrders,
      orderColors: orderColors ?? this.orderColors,
      selectedOrderId: clearSelectedOrder
          ? null
          : (selectedOrderId ?? this.selectedOrderId),
      activeFilter: activeFilter ?? this.activeFilter,
      earnings: earnings ?? this.earnings,
      riderLatitude: riderLatitude ?? this.riderLatitude,
      riderLongitude: riderLongitude ?? this.riderLongitude,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isOnline,
        isBackgroundTrackingActive,
        allOrders,
        orderColors,
        selectedOrderId,
        activeFilter,
        earnings,
        riderLatitude,
        riderLongitude,
        errorMessage,
      ];
}
