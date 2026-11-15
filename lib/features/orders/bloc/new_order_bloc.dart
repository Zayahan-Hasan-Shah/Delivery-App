import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_app/features/orders/bloc/new_order_event.dart';
import 'package:delivery_app/features/orders/bloc/new_order_state.dart';
import 'package:delivery_app/features/orders/service/order_service.dart';
import 'package:delivery_app/features/orders/model/location_point_model.dart';
import 'package:delivery_app/features/orders/model/order_item_model.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

class NewOrderBloc extends Bloc<NewOrderEvent, NewOrderState> {
  final OrderService orderService;
  final LocationService locationService;
  final Uuid _uuid = const Uuid();

  NewOrderBloc({
    required this.orderService,
    required this.locationService,
  }) : super(const NewOrderState()) {
    on<SetActivePinTabEvent>((event, emit) {
      emit(state.copyWith(activePinTab: event.tabIndex));
    });

    on<FetchCurrentCustomerLocationEvent>(_onFetchCurrentCustomerLocation);

    on<UpdatePickupCoordinatesEvent>((event, emit) {
      emit(state.copyWith(pickupLatitude: event.latitude, pickupLongitude: event.longitude));
    });

    on<UpdateDropoffCoordinatesEvent>((event, emit) {
      emit(state.copyWith(dropoffLatitude: event.latitude, dropoffLongitude: event.longitude));
    });

    on<UpdatePickupDetailsEvent>((event, emit) {
      emit(state.copyWith(
        pickupName: event.name,
        pickupPhone: event.phone,
        pickupAddress: event.address,
      ));
    });

    on<UpdateDropoffDetailsEvent>((event, emit) {
      emit(state.copyWith(
        dropoffName: event.name,
        dropoffPhone: event.phone,
        dropoffAddress: event.address,
      ));
    });

    on<AddOrderItemEvent>((event, emit) {
      final newItem = OrderItemModel(
        id: _uuid.v4(),
        name: event.name.trim(),
        quantity: event.quantity,
      );
      emit(state.copyWith(items: [...state.items, newItem]));
    });

    on<EditOrderItemEvent>((event, emit) {
      final updatedList = state.items.map((item) {
        if (item.id == event.itemId) {
          return item.copyWith(name: event.name.trim(), quantity: event.quantity);
        }
        return item;
      }).toList();
      emit(state.copyWith(items: updatedList));
    });

    on<RemoveOrderItemEvent>((event, emit) {
      final updatedList = state.items.where((i) => i.id != event.itemId).toList();
      emit(state.copyWith(items: updatedList));
    });

    on<UpdateRiderNoteEvent>((event, emit) {
      emit(state.copyWith(riderNote: event.note));
    });

    on<ResetOrderFormEvent>((event, emit) {
      emit(const NewOrderState());
    });

    on<SubmitOrderEvent>(_onSubmitOrder);
  }

  Future<void> _onFetchCurrentCustomerLocation(
    FetchCurrentCustomerLocationEvent event,
    Emitter<NewOrderState> emit,
  ) async {
    emit(state.copyWith(isLocatingCustomer: true, locationPermissionError: null));

    try {
      final hasPermission = await locationService.requestPermission();
      if (!hasPermission) {
        emit(state.copyWith(
          isLocatingCustomer: false,
          locationPermissionError: 'Location permission denied. Tap the GPS icon to grant permission.',
        ));
        return;
      }

      final location = await locationService.getCurrentLocation();
      if (location != null) {
        emit(state.copyWith(
          customerLatitude: location.latitude,
          customerLongitude: location.longitude,
          pickupLatitude: event.updatePickupCoordinates ? location.latitude : state.pickupLatitude,
          pickupLongitude: event.updatePickupCoordinates ? location.longitude : state.pickupLongitude,
          isLocatingCustomer: false,
          locationPermissionError: null,
        ));
      } else {
        emit(state.copyWith(
          isLocatingCustomer: false,
          locationPermissionError: 'Could not determine device position. Please select pin manually.',
        ));
      }
    } catch (e, st) {
      AppLogger.error('Failed to get customer location', error: e, stackTrace: st, tag: 'NewOrderBloc');
      emit(state.copyWith(
        isLocatingCustomer: false,
        locationPermissionError: 'Location service error. Please set pin manually.',
      ));
    }
  }

  Future<void> _onSubmitOrder(
    SubmitOrderEvent event,
    Emitter<NewOrderState> emit,
  ) async {
    // 1. Validation
    if (state.pickupName.trim().isEmpty) {
      emit(state.copyWith(
        status: NewOrderSubmissionStatus.error,
        errorMessage: 'Pickup contact name is required.',
      ));
      return;
    }
    if (state.pickupPhone.trim().isEmpty) {
      emit(state.copyWith(
        status: NewOrderSubmissionStatus.error,
        errorMessage: 'Pickup contact phone number is required.',
      ));
      return;
    }
    if (state.dropoffName.trim().isEmpty) {
      emit(state.copyWith(
        status: NewOrderSubmissionStatus.error,
        errorMessage: 'Drop-off recipient name is required.',
      ));
      return;
    }
    if (state.dropoffPhone.trim().isEmpty) {
      emit(state.copyWith(
        status: NewOrderSubmissionStatus.error,
        errorMessage: 'Drop-off recipient phone number is required.',
      ));
      return;
    }
    if (state.items.isEmpty) {
      emit(state.copyWith(
        status: NewOrderSubmissionStatus.error,
        errorMessage: 'Please add at least one item to deliver.',
      ));
      return;
    }

    emit(state.copyWith(status: NewOrderSubmissionStatus.submitting, errorMessage: null));

    try {
      final pickup = LocationPointModel(
        contactName: state.pickupName.trim(),
        contactPhone: state.pickupPhone.trim(),
        address: state.pickupAddress.trim(),
        latitude: state.pickupLatitude,
        longitude: state.pickupLongitude,
      );

      final dropoff = LocationPointModel(
        contactName: state.dropoffName.trim(),
        contactPhone: state.dropoffPhone.trim(),
        address: state.dropoffAddress.trim(),
        latitude: state.dropoffLatitude,
        longitude: state.dropoffLongitude,
      );

      final order = await orderService.createOrder(
        pickup: pickup,
        dropoff: dropoff,
        items: state.items,
        riderNote: state.riderNote.trim().isEmpty ? null : state.riderNote.trim(),
      );

      AppLogger.info('Order placed successfully: ${order.orderNumber}', tag: 'NewOrderBloc');

      emit(state.copyWith(
        status: NewOrderSubmissionStatus.success,
        createdOrder: order,
        errorMessage: null,
      ));
    } catch (e, st) {
      AppLogger.error('Failed to place order', error: e, stackTrace: st, tag: 'NewOrderBloc');
      emit(state.copyWith(
        status: NewOrderSubmissionStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
