import 'package:equatable/equatable.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_item_entity.dart';

enum NewOrderSubmissionStatus { initial, submitting, success, error }

class NewOrderState extends Equatable {
  final int activePinTab;
  final double pickupLatitude;
  final double pickupLongitude;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final double? senderLatitude;
  final double? senderLongitude;
  final bool isLocatingSender;
  final String? locationPermissionError;
  final String pickupName;
  final String pickupPhone;
  final String pickupAddress;
  final String dropoffName;
  final String dropoffPhone;
  final String dropoffAddress;
  final double codAmountPkr;
  final String notes;
  final List<OrderItemEntity> items;
  final NewOrderSubmissionStatus status;
  final OrderEntity? createdOrder;
  final String? errorMessage;

  const NewOrderState({
    this.activePinTab = 0,
    this.pickupLatitude = AppConstants.defaultLatitude,
    this.pickupLongitude = AppConstants.defaultLongitude,
    this.dropoffLatitude = AppConstants.defaultLatitude + 0.015,
    this.dropoffLongitude = AppConstants.defaultLongitude + 0.012,
    this.senderLatitude,
    this.senderLongitude,
    this.isLocatingSender = false,
    this.locationPermissionError,
    this.pickupName = '',
    this.pickupPhone = '',
    this.pickupAddress = '',
    this.dropoffName = '',
    this.dropoffPhone = '',
    this.dropoffAddress = '',
    this.codAmountPkr = 0,
    this.notes = '',
    this.items = const [],
    this.status = NewOrderSubmissionStatus.initial,
    this.createdOrder,
    this.errorMessage,
  });

  double get estimatedFeePkr {
    final dLat = (dropoffLatitude - pickupLatitude).abs();
    final dLng = (dropoffLongitude - pickupLongitude).abs();
    final approxKm = ((dLat + dLng) * 111.0).clamp(1.2, 30.0);
    return (120 + approxKm * 28).roundToDouble().clamp(150.0, 900.0);
  }

  NewOrderState copyWith({
    int? activePinTab,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    double? senderLatitude,
    double? senderLongitude,
    bool? isLocatingSender,
    String? locationPermissionError,
    bool clearLocationError = false,
    String? pickupName,
    String? pickupPhone,
    String? pickupAddress,
    String? dropoffName,
    String? dropoffPhone,
    String? dropoffAddress,
    double? codAmountPkr,
    String? notes,
    List<OrderItemEntity>? items,
    NewOrderSubmissionStatus? status,
    OrderEntity? createdOrder,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NewOrderState(
      activePinTab: activePinTab ?? this.activePinTab,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      senderLatitude: senderLatitude ?? this.senderLatitude,
      senderLongitude: senderLongitude ?? this.senderLongitude,
      isLocatingSender: isLocatingSender ?? this.isLocatingSender,
      locationPermissionError: clearLocationError
          ? null
          : (locationPermissionError ?? this.locationPermissionError),
      pickupName: pickupName ?? this.pickupName,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffName: dropoffName ?? this.dropoffName,
      dropoffPhone: dropoffPhone ?? this.dropoffPhone,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      codAmountPkr: codAmountPkr ?? this.codAmountPkr,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      status: status ?? this.status,
      createdOrder: createdOrder ?? this.createdOrder,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        activePinTab,
        pickupLatitude,
        pickupLongitude,
        dropoffLatitude,
        dropoffLongitude,
        senderLatitude,
        senderLongitude,
        isLocatingSender,
        locationPermissionError,
        pickupName,
        pickupPhone,
        pickupAddress,
        dropoffName,
        dropoffPhone,
        dropoffAddress,
        codAmountPkr,
        notes,
        items,
        status,
        createdOrder,
        errorMessage,
      ];
}
