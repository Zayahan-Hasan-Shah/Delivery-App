import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:delivery_app/core/network/api_client.dart';
import 'package:delivery_app/core/network/network_info.dart';
import 'package:delivery_app/shared/service/secure_storage_service.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/service/notification_service.dart';
import 'package:delivery_app/shared/routing/app_router.dart';
import 'package:delivery_app/features/authentication/service/auth_service.dart';
import 'package:delivery_app/features/authentication/service/mock_auth_service.dart';
import 'package:delivery_app/features/authentication/bloc/auth_bloc.dart';
import 'package:delivery_app/features/orders/service/order_service.dart';
import 'package:delivery_app/features/orders/service/mock_order_service.dart';
import 'package:delivery_app/features/orders/bloc/new_order_bloc.dart';
import 'package:delivery_app/features/tracking/service/tracking_service.dart';
import 'package:delivery_app/features/tracking/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/home/service/home_service.dart';
import 'package:delivery_app/features/home/bloc/home_bloc.dart';
import 'package:delivery_app/features/rider/service/rider_service.dart';
import 'package:delivery_app/features/rider/bloc/rider_orders_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // 1. Shared Infrastructure Services
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageServiceImpl());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<RealtimeService>(() => MockRealtimeService());
  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  sl.registerLazySingleton<NotificationService>(() => NotificationServiceImpl());

  // 2. HTTP Client
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(dio: sl(), secureStorage: sl()));

  // 3. Feature Services & Repositories
  sl.registerLazySingleton<AuthService>(() => MockAuthService(secureStorage: sl()));
  sl.registerLazySingleton<OrderService>(() => MockOrderService(realtimeService: sl()));
  sl.registerLazySingleton<TrackingService>(() => TrackingServiceImpl(orderService: sl(), realtimeService: sl()));
  sl.registerLazySingleton<HomeService>(() => HomeServiceImpl(orderService: sl()));
  sl.registerLazySingleton<RiderService>(() => RiderServiceImpl(orderService: sl()));

  // 4. BLoCs
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(authService: sl()));
  sl.registerFactory<NewOrderBloc>(() => NewOrderBloc(orderService: sl(), locationService: sl()));
  sl.registerFactory<TrackingBloc>(() => TrackingBloc(trackingService: sl()));
  sl.registerFactory<HomeBloc>(() => HomeBloc(homeService: sl()));
  sl.registerFactory<RiderOrdersBloc>(() => RiderOrdersBloc(riderService: sl()));

  // 5. Router
  sl.registerLazySingleton<AppRouter>(() => AppRouter(authBloc: sl()));
}
