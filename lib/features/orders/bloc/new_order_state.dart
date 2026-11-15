import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/orders/model/order_item_model.dart';
import 'package:delivery_app/core/constant/app_constants.dart';

enum NewOrderSubmissionStatus { initial, submitting, success, error }

class NewOrderState extends Equatable {
  final int activePinTab; // 0: Pickup, 1: Drop-off

  // Customer real-time device location
  final double? customerLatitude;
  final double? customerLongitude;
  final bool isLocatingCustomer;
  final String? locationPermissionError;

  // Pickup location
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupName;
  final String pickupPhone;
  final String pickupAddress;

  // Drop-off location
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String dropoffName;
  final String dropoffPhone;
  final String dropoffAddress;

  // Items & Notes
  final List<OrderItemModel> items;
  final String riderNote;

  // Submission state
  final NewOrderSubmissionStatus status;
  final OrderModel? createdOrder;
  final String? errorMessage;

  const NewOrderState({
    this.activePinTab = 0,
    this.customerLatitude,
    this.customerLongitude,
    this.isLocatingCustomer = false,
    this.locationPermissionError,
    this.pickupLatitude = AppConstants.defaultLatitude,
    this.pickupLongitude = AppConstants.defaultLongitude,
    this.pickupName = '',
    this.pickupPhone = '',
    this.pickupAddress = '',
    this.dropoffLatitude = AppConstants.defaultLatitude + 0.015,
    this.dropoffLongitude = AppConstants.defaultLongitude + 0.015,
    this.dropoffName = '',
    this.dropoffPhone = '',
    this.dropoffAddress = '',
    this.items = const [],
    this.riderNote = '',
    this.status = NewOrderSubmissionStatus.initial,
    this.createdOrder,
    this.errorMessage,
  });

  NewOrderState copyWith({
    int? activePinTab,
    double? customerLatitude,
    double? customerLongitude,
    bool? isLocatingCustomer,
    String? locationPermissionError,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupName,
    String? pickupPhone,
    String? pickupAddress,
    double? dropoffLatitude,
    double? dropoffLongitude,
    String? dropoffName,
    String? dropoffPhone,
    String? dropoffAddress,
    List<OrderItemModel>? items,
    String? riderNote,
    NewOrderSubmissionStatus? status,
    OrderModel? createdOrder,
    String? errorMessage,
  }) {
    return NewOrderState(
      activePinTab: activePinTab ?? this.activePinTab,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      isLocatingCustomer: isLocatingCustomer ?? this.isLocatingCustomer,
      locationPermissionError: locationPermissionError,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      pickupName: pickupName ?? this.pickupName,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      dropoffName: dropoffName ?? this.dropoffName,
      dropoffPhone: dropoffPhone ?? this.dropoffPhone,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      items: items ?? this.items,
      riderNote: riderNote ?? this.riderNote,
      status: status ?? this.status,
      createdOrder: createdOrder ?? this.createdOrder,
      errorMessage: errorMessage,
    );
  }

  bool get isSubmitting => status == NewOrderSubmissionStatus.submitting;

  @override
  List<Object?> get props => [
        activePinTab,
        customerLatitude,
        customerLongitude,
        isLocatingCustomer,
        locationPermissionError,
        pickupLatitude,
        pickupLongitude,
        pickupName,
        pickupPhone,
        pickupAddress,
        dropoffLatitude,
        dropoffLongitude,
        dropoffName,
        dropoffPhone,
        dropoffAddress,
        items,
        riderNote,
        status,
        createdOrder,
        errorMessage,
      ];
}
