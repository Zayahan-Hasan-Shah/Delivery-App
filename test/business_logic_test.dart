import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';
import 'package:delivery_app/features/authentication/bloc/auth_bloc.dart';
import 'package:delivery_app/features/authentication/bloc/auth_event.dart';
import 'package:delivery_app/features/authentication/state/auth_status.dart';
import 'package:delivery_app/features/authentication/service/mock_auth_service.dart';
import 'package:delivery_app/features/orders/model/order_status.dart';
import 'package:delivery_app/features/orders/bloc/new_order_bloc.dart';
import 'package:delivery_app/features/orders/bloc/new_order_event.dart';
import 'package:delivery_app/features/orders/bloc/new_order_state.dart';
import 'package:delivery_app/features/orders/service/mock_order_service.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';
import 'package:delivery_app/shared/service/secure_storage_service.dart';
import 'package:delivery_app/shared/service/location_service.dart';

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
  @override
  Future<bool> checkPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> isGpsEnabled() async => true;

  @override
  Future<UserLocation?> getCurrentLocation() async => UserLocation(
        latitude: 37.7749,
        longitude: -122.4194,
      );

  @override
  Stream<UserLocation> get locationStream => const Stream.empty();

  @override
  Future<void> startTracking({int distanceFilterMeters = 10, int intervalSeconds = 5}) async {}

  @override
  Future<void> stopTracking() async {}

  @override
  bool get isTracking => false;
}

void main() {
  group('1. Complete Authentication Flow Tests', () {
    late FakeSecureStorageService fakeStorage;
    late MockAuthService authService;
    late AuthBloc authBloc;

    setUp(() {
      fakeStorage = FakeSecureStorageService();
      authService = MockAuthService(secureStorage: fakeStorage);
      authBloc = AuthBloc(authService: authService);
    });

    tearDown(() {
      authBloc.close();
    });

    test('Initial auth state is unauthenticated without active session', () {
      expect(authBloc.state.user, isNull);
      expect(authBloc.state.status, AuthStatus.initial);
    });

    test('1. Registration Flow: registers user with role and updates auth state', () async {
      authBloc.add(
        const RegisterSubmittedEvent(
          name: 'Dave Courier',
          phone: '+1 555-8888',
          email: 'dave@delivery.com',
          password: 'password123',
          role: UserRole.rider,
          vehicleType: 'Motorcycle',
        ),
      );

      await expectLater(
        authBloc.stream,
        emitsThrough(
          predicate<dynamic>((state) {
            return state.status == AuthStatus.authenticated &&
                state.user != null &&
                state.user!.role == UserRole.rider &&
                state.user!.email == 'dave@delivery.com';
          }),
        ),
      );
    });

    test('2. Login Flow: authenticates registered role account', () async {
      authBloc.add(
        const LoginSubmittedEvent(
          usernameOrPhone: 'customer@delivery.com',
          password: 'password123',
        ),
      );

      await expectLater(
        authBloc.stream,
        emitsThrough(
          predicate<dynamic>((state) {
            return state.status == AuthStatus.authenticated &&
                state.user != null &&
                state.user!.role == UserRole.customer &&
                state.user!.email == 'customer@delivery.com';
          }),
        ),
      );
    });

    test('3. Forgot Password Flow: requests OTP recovery and resets password', () async {
      // Step A: Request OTP
      authBloc.add(const ForgotPasswordRequestedEvent('customer@delivery.com'));

      await expectLater(
        authBloc.stream,
        emitsThrough(
          predicate<dynamic>((state) {
            return state.status == AuthStatus.passwordResetCodeSent && state.message != null;
          }),
        ),
      );

      // Step B: Submit OTP & New Password
      authBloc.add(
        const ResetPasswordSubmittedEvent(
          emailOrPhone: 'customer@delivery.com',
          otpCode: '123456',
          newPassword: 'newSecretPassword123',
        ),
      );

      await expectLater(
        authBloc.stream,
        emitsThrough(
          predicate<dynamic>((state) {
            return state.status == AuthStatus.passwordResetSuccess && state.message != null;
          }),
        ),
      );
    });

    test('Logout clears user session and returns to unauthenticated', () async {
      authBloc.add(
        const LoginSubmittedEvent(
          usernameOrPhone: 'rider@delivery.com',
          password: 'password123',
        ),
      );

      await expectLater(
        authBloc.stream,
        emitsThrough(predicate<dynamic>((state) => state.user != null)),
      );

      authBloc.add(const LogoutRequestedEvent());

      await expectLater(
        authBloc.stream,
        emitsThrough(predicate<dynamic>((state) => state.user == null && state.status == AuthStatus.unauthenticated)),
      );
    });
  });

  group('2. UserRole & OrderStatus Domain Logic Tests', () {
    test('Role parsing and permissions', () {
      expect(UserRole.fromString('customer'), UserRole.customer);
      expect(UserRole.fromString('client'), UserRole.client);
      expect(UserRole.fromString('rider'), UserRole.rider);
      expect(UserRole.customer.isCustomer, isTrue);
      expect(UserRole.rider.isRider, isTrue);
    });

    test('OrderStatus timeline sequence and terminal states', () {
      expect(OrderStatus.placed.timelineOrder, 0);
      expect(OrderStatus.accepted.timelineOrder, 1);
      expect(OrderStatus.assigned.timelineOrder, 2);
      expect(OrderStatus.pickedUp.timelineOrder, 3);
      expect(OrderStatus.onTheWay.timelineOrder, 4);
      expect(OrderStatus.delivered.timelineOrder, 5);

      expect(OrderStatus.placed.isActive, isTrue);
      expect(OrderStatus.delivered.isTerminal, isTrue);
      expect(OrderStatus.cancelled.isTerminal, isTrue);
    });
  });

  group('3. NewOrderBloc Validation & Creation Tests', () {
    late MockRealtimeService realtimeService;
    late MockOrderService orderService;
    late FakeLocationService locationService;
    late NewOrderBloc newOrderBloc;

    setUp(() {
      realtimeService = MockRealtimeService();
      orderService = MockOrderService(realtimeService: realtimeService);
      locationService = FakeLocationService();
      newOrderBloc = NewOrderBloc(
        orderService: orderService,
        locationService: locationService,
      );
    });

    tearDown(() {
      newOrderBloc.close();
    });

    test('Fetches current customer location and sets pickup pin', () async {
      newOrderBloc.add(
        const FetchCurrentCustomerLocationEvent(updatePickupCoordinates: true),
      );

      await expectLater(
        newOrderBloc.stream,
        emitsThrough(
          predicate<NewOrderState>((state) {
            return state.customerLatitude == 37.7749 &&
                state.customerLongitude == -122.4194 &&
                state.pickupLatitude == 37.7749 &&
                state.pickupLongitude == -122.4194 &&
                state.isLocatingCustomer == false;
          }),
        ),
      );
    });

    test('Prevents order submission when items list is empty', () async {
      newOrderBloc.add(
        const UpdatePickupDetailsEvent(name: 'Sender', phone: '+12345678', address: 'Addr 1'),
      );
      newOrderBloc.add(
        const UpdateDropoffDetailsEvent(name: 'Receiver', phone: '+87654321', address: 'Addr 2'),
      );
      newOrderBloc.add(const SubmitOrderEvent());

      await expectLater(
        newOrderBloc.stream,
        emitsThrough(
          predicate<NewOrderState>((state) {
            return state.status == NewOrderSubmissionStatus.error &&
                state.errorMessage == 'Please add at least one item to deliver.';
          }),
        ),
      );
    });

    test('Allows submission when all fields and items are valid', () async {
      newOrderBloc.add(
        const UpdatePickupDetailsEvent(name: 'Sender', phone: '+12345678', address: 'Addr 1'),
      );
      newOrderBloc.add(
        const UpdateDropoffDetailsEvent(name: 'Receiver', phone: '+87654321', address: 'Addr 2'),
      );
      newOrderBloc.add(
        const AddOrderItemEvent(name: 'Important Documents', quantity: 2),
      );
      newOrderBloc.add(const SubmitOrderEvent());

      await expectLater(
        newOrderBloc.stream,
        emitsThrough(
          predicate<NewOrderState>((state) {
            return state.status == NewOrderSubmissionStatus.success &&
                state.createdOrder != null &&
                state.createdOrder!.items.length == 1 &&
                state.createdOrder!.items.first.quantity == 2;
          }),
        ),
      );
    });
  });
}
