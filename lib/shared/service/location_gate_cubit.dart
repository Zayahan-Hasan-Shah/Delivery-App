import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/shared/service/location_service.dart';

class LocationGateState extends Equatable {
  final LocationAccessStatus status;
  final bool isChecking;

  const LocationGateState({
    this.status = LocationAccessStatus.denied,
    this.isChecking = true,
  });

  bool get isGranted => status == LocationAccessStatus.granted;

  LocationGateState copyWith({
    LocationAccessStatus? status,
    bool? isChecking,
  }) {
    return LocationGateState(
      status: status ?? this.status,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  @override
  List<Object?> get props => [status, isChecking];
}

class LocationGateCubit extends Cubit<LocationGateState> {
  final LocationService locationService;

  LocationGateCubit({required this.locationService})
      : super(const LocationGateState());

  Future<void> checkAndRequestOnStartup() async {
    emit(state.copyWith(isChecking: true));
    final current = await locationService.checkLocationAccessStatus();
    if (current == LocationAccessStatus.granted) {
      emit(const LocationGateState(
        status: LocationAccessStatus.granted,
        isChecking: false,
      ));
      return;
    }

    // Proactively trigger the OS permission prompt on startup
    final requested = await locationService.requestMandatoryLocationAccess();
    emit(LocationGateState(
      status: requested,
      isChecking: false,
    ));
  }

  Future<void> recheckStatus() async {
    emit(state.copyWith(isChecking: true));
    final current = await locationService.checkLocationAccessStatus();
    emit(LocationGateState(
      status: current,
      isChecking: false,
    ));
  }

  Future<void> requestPermission() async {
    emit(state.copyWith(isChecking: true));
    final status = await locationService.requestMandatoryLocationAccess();
    emit(LocationGateState(
      status: status,
      isChecking: false,
    ));
  }

  Future<void> openAppSettings() async {
    await locationService.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await locationService.openLocationSettings();
  }
}
