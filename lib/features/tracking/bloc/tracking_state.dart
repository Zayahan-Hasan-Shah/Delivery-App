import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/tracking/model/rider_location.dart';

enum TrackingStatus { initial, loading, success, error }

class TrackingState extends Equatable {
  final TrackingStatus status;
  final List<OrderModel> orders;
  final OrderModel? selectedOrder;
  final RiderLocation? liveRiderLocation;
  final bool isLiveConnected;
  final String? errorMessage;

  const TrackingState({
    this.status = TrackingStatus.initial,
    this.orders = const [],
    this.selectedOrder,
    this.liveRiderLocation,
    this.isLiveConnected = true,
    this.errorMessage,
  });

  TrackingState copyWith({
    TrackingStatus? status,
    List<OrderModel>? orders,
    OrderModel? selectedOrder,
    RiderLocation? liveRiderLocation,
    bool? isLiveConnected,
    String? errorMessage,
  }) {
    return TrackingState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      liveRiderLocation: liveRiderLocation ?? this.liveRiderLocation,
      isLiveConnected: isLiveConnected ?? this.isLiveConnected,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        selectedOrder,
        liveRiderLocation,
        isLiveConnected,
        errorMessage,
      ];
}
