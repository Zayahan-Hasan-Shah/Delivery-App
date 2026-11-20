import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/core/utils/order_color_helper.dart';
import 'package:delivery_app/features/authentication/data/data_sources/auth_local_data_source.dart';
import 'package:delivery_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';
import 'package:delivery_app/features/authentication/domain/usecases/check_auth_status_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/forgot_password_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/register_rider_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/register_sender_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/update_rider_online_status_usecase.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/bloc/auth_bloc.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/event/auth_event.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/state/auth_state.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/state/auth_status.dart';
import 'package:delivery_app/features/orders/data/data_sources/order_local_data_source.dart';
import 'package:delivery_app/features/orders/data/repositories/order_repository_impl.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:delivery_app/features/orders/presentation/bloc/bloc/new_order_bloc.dart';
import 'package:delivery_app/features/orders/presentation/bloc/event/new_order_event.dart';
import 'package:delivery_app/features/orders/presentation/bloc/state/new_order_state.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/service/location_gate_cubit.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';
import 'package:delivery_app/shared/service/secure_storage_service.dart';

class FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> deleteAll() async => _data.clear();

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;
}

class FakeLocationService implements LocationService {
  LocationAccessStatus mockStatus;

  FakeLocationService({this.mockStatus = LocationAccessStatus.granted});

  @override
  Future<LocationAccessStatus> checkLocationAccessStatus() async => mockStatus;

  @override
  Future<LocationAccessStatus> requestMandatoryLocationAccess() async =>
      mockStatus;

  @override
  Future<bool> checkPermission() async =>
      mockStatus == LocationAccessStatus.granted;

  @override
  Future<bool> requestPermission() async =>
      mockStatus == LocationAccessStatus.granted;

  @override
  Future<bool> isGpsEnabled() async =>
      mockStatus != LocationAccessStatus.gpsDisabled;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Future<UserLocation?> getCurrentLocation() async => UserLocation(
        latitude: 33.7215,
        longitude: 73.0561,
      );

  @override
  Stream<UserLocation> get locationStream => const Stream.empty();

  @override
  Future<void> startTracking({
    int distanceFilterMeters = 10,
    int intervalSeconds = 5,
    bool enableBackgroundService = true,
  }) async {}

  @override
  Future<void> stopTracking() async {}

  @override
  bool get isTracking => false;

  @override
  UserLocation? get lastKnownLocation => UserLocation(
        latitude: 33.7215,
        longitude: 73.0561,
      );
}

void main() {
  group('1. Role Model & Localization (EN/UR)', () {
    test('Only Sender and Rider roles exist (Client removed)', () {
      expect(UserRole.values, [UserRole.sender, UserRole.rider]);
      expect(UserRole.fromString('sender'), UserRole.sender);
      expect(UserRole.fromString('rider'), UserRole.rider);
      expect(UserRole.sender.isSender, isTrue);
      expect(UserRole.rider.isRider, isTrue);
    });

    test('English and Urdu localizations load cleanly', () {
      final en = lookupAppLocalizations(const Locale('en'));
      final ur = lookupAppLocalizations(const Locale('ur'));
      expect(en.roleSender, 'Sender');
      expect(en.roleRider, 'Rider');
      expect(ur.roleRider, 'رائیڈر');
      expect(ur.allowLocationPermission.isNotEmpty, isTrue);
    });
  });

  group('2. Mandatory Location Permission Gate', () {
    test('Blocks user when location permission is denied', () async {
      final loc = FakeLocationService(mockStatus: LocationAccessStatus.denied);
      final cubit = LocationGateCubit(locationService: loc);

      await cubit.checkAndRequestOnStartup();
      expect(cubit.state.isGranted, isFalse);
      expect(cubit.state.status, LocationAccessStatus.denied);

      // Once user grants permission, gate unlocks
      loc.mockStatus = LocationAccessStatus.granted;
      await cubit.requestPermission();
      expect(cubit.state.isGranted, isTrue);

      await cubit.close();
    });
  });

  group('3. Authentication Flows (Sender & Rider Signup + Login)', () {
    late AuthBloc authBloc;

    setUp(() {
      final storage = FakeSecureStorageService();
      final ds = AuthLocalDataSourceImpl(secureStorage: storage);
      final repo = AuthRepositoryImpl(localDataSource: ds);
      authBloc = AuthBloc(
        checkAuthStatusUseCase: CheckAuthStatusUseCase(repo),
        loginUseCase: LoginUseCase(repo),
        registerSenderUseCase: RegisterSenderUseCase(repo),
        registerRiderUseCase: RegisterRiderUseCase(repo),
        forgotPasswordUseCase: ForgotPasswordUseCase(repo),
        resetPasswordUseCase: ResetPasswordUseCase(repo),
        logoutUseCase: LogoutUseCase(repo),
        updateRiderOnlineStatusUseCase: UpdateRiderOnlineStatusUseCase(repo),
      );
    });

    tearDown(() => authBloc.close());

    test('Sender signup captures full name, phone & pickup address with map location',
        () async {
      authBloc.add(
        const RegisterSenderSubmittedEvent(
          fullName: 'Hassan Ali',
          phone: '03009998877',
          pickupAddress: 'Sector F-8 Markaz, Islamabad',
          pickupLatitude: 33.7215,
          pickupLongitude: 73.0560,
          password: 'password123',
        ),
      );

      await expectLater(
        authBloc.stream,
        emitsThrough(
          predicate<AuthState>((state) {
            return state.status == AuthStatus.authenticated &&
                state.user?.role == UserRole.sender &&
                state.user?.name == 'Hassan Ali' &&
                state.user?.pickupAddress == 'Sector F-8 Markaz, Islamabad';
          }),
        ),
      );
    });

    test('Rider signup captures driving license and bike papers photos',
        () async {
      authBloc.add(
        const RegisterRiderSubmittedEvent(
          fullName: 'Tariq Mehmood',
          phone: '03121112233',
          password: 'password123',
          drivingLicenseImagePath: '/tmp/license.jpg',
          bikePapersImagePath: '/tmp/bike_papers.jpg',
          cnicNumber: '61101-0000000-1',
        ),
      );

      await expectLater(
        authBloc.stream,
        emitsThrough(
          predicate<AuthState>((state) {
            return state.status == AuthStatus.authenticated &&
                state.user?.role == UserRole.rider &&
                state.user?.drivingLicenseImagePath == '/tmp/license.jpg' &&
                state.user?.bikePapersImagePath == '/tmp/bike_papers.jpg';
          }),
        ),
      );
    });
  });

  group('4. Multi-Order Unique Colors & NewOrderBloc', () {
    test('Assigns distinct unique colors to multiple active rider orders', () {
      final map = OrderColorHelper.buildColorMap(
        ['ord_101', 'ord_102', 'ord_103', 'ord_104'],
      );
      expect(map.values.toSet().length, 4);
    });

    test('NewOrderBloc fetches GPS location and creates order cleanly',
        () async {
      final rt = MockRealtimeService();
      final ds = OrderLocalDataSourceImpl(realtimeService: rt);
      final repo = OrderRepositoryImpl(localDataSource: ds);
      final bloc = NewOrderBloc(
        createOrderUseCase: CreateOrderUseCase(repo),
        locationService: FakeLocationService(),
      );

      bloc.add(
        const FetchCurrentSenderLocationEvent(updatePickupCoordinates: true),
      );

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<NewOrderState>(
            (s) => s.senderLatitude == 33.7215 && s.pickupLatitude == 33.7215,
          ),
        ),
      );

      bloc.add(
        const UpdatePickupDetailsEvent(
          name: 'Spice Kitchen',
          phone: '03001234567',
          address: 'F-7 Markaz',
        ),
      );
      bloc.add(
        const UpdateDropoffDetailsEvent(
          name: 'Ayesha',
          phone: '03215551010',
          address: 'Blue Area',
        ),
      );
      bloc.add(const AddOrderItemEvent(name: 'Biryani Box', quantity: 2));
      bloc.add(const SubmitOrderEvent(senderId: 'sender_01'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<NewOrderState>(
            (s) =>
                s.status == NewOrderSubmissionStatus.success &&
                s.createdOrder != null &&
                s.createdOrder!.status == OrderStatus.assigned,
          ),
        ),
      );

      await bloc.close();
      rt.dispose();
    });
  });
}
