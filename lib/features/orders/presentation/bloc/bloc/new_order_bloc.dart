import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_app/features/orders/domain/entities/location_point_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_item_entity.dart';
import 'package:delivery_app/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:delivery_app/features/orders/presentation/bloc/event/new_order_event.dart';
import 'package:delivery_app/features/orders/presentation/bloc/state/new_order_state.dart';
import 'package:delivery_app/shared/service/location_service.dart';

class NewOrderBloc extends Bloc<NewOrderEvent, NewOrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final LocationService locationService;
  final Uuid _uuid = const Uuid();

  NewOrderBloc({
    required this.createOrderUseCase,
    required this.locationService,
  }) : super(const NewOrderState()) {
    on<SetActivePinTabEvent>((event, emit) {
      emit(state.copyWith(activePinTab: event.tabIndex));
    });

    on<FetchCurrentSenderLocationEvent>(_onFetchCurrentSenderLocation);

    on<UpdatePickupCoordinatesEvent>((event, emit) {
      emit(state.copyWith(
        pickupLatitude: event.latitude,
        pickupLongitude: event.longitude,
      ));
    });

    on<UpdateDropoffCoordinatesEvent>((event, emit) {
      emit(state.copyWith(
        dropoffLatitude: event.latitude,
        dropoffLongitude: event.longitude,
      ));
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

    on<UpdateCodAmountEvent>((event, emit) {
      emit(state.copyWith(codAmountPkr: event.codAmountPkr));
    });

    on<UpdateOrderNotesEvent>((event, emit) {
      emit(state.copyWith(notes: event.notes));
    });

    on<AddOrderItemEvent>((event, emit) {
      final updated = List<OrderItemEntity>.from(state.items)
        ..add(OrderItemEntity(
          id: _uuid.v4().substring(0, 6),
          name: event.name,
          quantity: event.quantity,
          notes: event.notes,
        ));
      emit(state.copyWith(items: updated, clearError: true));
    });

    on<RemoveOrderItemEvent>((event, emit) {
      final updated = state.items.where((i) => i.id != event.itemId).toList();
      emit(state.copyWith(items: updated));
    });

    on<SubmitOrderEvent>(_onSubmitOrder);

    on<ResetNewOrderEvent>((event, emit) {
      emit(const NewOrderState());
    });
  }

  Future<void> _onFetchCurrentSenderLocation(
    FetchCurrentSenderLocationEvent event,
    Emitter<NewOrderState> emit,
  ) async {
    emit(state.copyWith(isLocatingSender: true, clearLocationError: true));

    try {
      final isGpsOn = await locationService.isGpsEnabled();
      if (!isGpsOn) {
        emit(state.copyWith(
          isLocatingSender: false,
          locationPermissionError:
              'Location services (GPS) are disabled. Please enable GPS.',
        ));
        return;
      }

      final hasPerm = await locationService.requestPermission();
      if (!hasPerm) {
        emit(state.copyWith(
          isLocatingSender: false,
          locationPermissionError:
              'Location permission is required to detect your pickup location.',
        ));
        return;
      }

      final loc = await locationService.getCurrentLocation();
      if (loc != null) {
        emit(state.copyWith(
          senderLatitude: loc.latitude,
          senderLongitude: loc.longitude,
          pickupLatitude: event.updatePickupCoordinates
              ? loc.latitude
              : state.pickupLatitude,
          pickupLongitude: event.updatePickupCoordinates
              ? loc.longitude
              : state.pickupLongitude,
          isLocatingSender: false,
        ));
      } else {
        emit(state.copyWith(
          isLocatingSender: false,
          locationPermissionError: 'Unable to retrieve device GPS coordinates.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLocatingSender: false,
        locationPermissionError: 'Location error: $e',
      ));
    }
  }

  Future<void> _onSubmitOrder(
    SubmitOrderEvent event,
    Emitter<NewOrderState> emit,
  ) async {
    if (state.pickupName.trim().isEmpty || state.pickupPhone.trim().isEmpty) {
      emit(state.copyWith(
        status: NewOrderSubmissionStatus.error,
        errorMessage: 'Please enter pickup contact name and phone number.',
      ));
      return;
    }

    if (state.dropoffName.trim().isEmpty || state.dropoffPhone.trim().isEmpty) {
      emit(state.copyWith(
        status: NewOrderSubmissionStatus.error,
        errorMessage: 'Please enter receiver name and phone number.',
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

    emit(state.copyWith(
      status: NewOrderSubmissionStatus.submitting,
      clearError: true,
    ));

    try {
      final order = await createOrderUseCase(
        senderId: event.senderId,
        pickup: LocationPointEntity(
          latitude: state.pickupLatitude,
          longitude: state.pickupLongitude,
          contactName: state.pickupName.trim(),
          contactPhone: state.pickupPhone.trim(),
          addressText: state.pickupAddress.trim().isEmpty
              ? 'Pinned Pickup (${state.pickupLatitude.toStringAsFixed(4)}, ${state.pickupLongitude.toStringAsFixed(4)})'
              : state.pickupAddress.trim(),
        ),
        dropoff: LocationPointEntity(
          latitude: state.dropoffLatitude,
          longitude: state.dropoffLongitude,
          contactName: state.dropoffName.trim(),
          contactPhone: state.dropoffPhone.trim(),
          addressText: state.dropoffAddress.trim().isEmpty
              ? 'Pinned Drop-off (${state.dropoffLatitude.toStringAsFixed(4)}, ${state.dropoffLongitude.toStringAsFixed(4)})'
              : state.dropoffAddress.trim(),
        ),
        items: state.items,
        codAmountPkr: state.codAmountPkr,
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      );

      emit(state.copyWith(
        status: NewOrderSubmissionStatus.success,
        createdOrder: order,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NewOrderSubmissionStatus.error,
        errorMessage: 'Failed to create delivery order: $e',
      ));
    }
  }
}
