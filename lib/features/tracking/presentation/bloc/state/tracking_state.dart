import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/tracking/domain/entities/tracking_data_entity.dart';

class TrackingState extends Equatable {
  final bool isLoading;
  final List<OrderEntity> activeOrders;
  final TrackingDataEntity? trackingData;
  final String? errorMessage;

  const TrackingState({
    this.isLoading = false,
    this.activeOrders = const [],
    this.trackingData,
    this.errorMessage,
  });

  TrackingState copyWith({
    bool? isLoading,
    List<OrderEntity>? activeOrders,
    TrackingDataEntity? trackingData,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrackingState(
      isLoading: isLoading ?? this.isLoading,
      activeOrders: activeOrders ?? this.activeOrders,
      trackingData: trackingData ?? this.trackingData,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, activeOrders, trackingData, errorMessage];
}
