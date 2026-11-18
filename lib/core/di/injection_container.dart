import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:delivery_app/core/localization/locale_cubit.dart';
import 'package:delivery_app/core/network/api_client.dart';
import 'package:delivery_app/core/network/network_info.dart';

// Shared Infrastructure Services
import 'package:delivery_app/shared/routing/app_router.dart';
import 'package:delivery_app/shared/service/background_delivery_service.dart';
import 'package:delivery_app/shared/service/document_picker_service.dart';
import 'package:delivery_app/shared/service/location_gate_cubit.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/service/notification_service.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';
import 'package:delivery_app/shared/service/route_navigation_service.dart';
import 'package:delivery_app/shared/service/secure_storage_service.dart';

// Feature: Authentication
import 'package:delivery_app/features/authentication/data/data_sources/auth_local_data_source.dart';
import 'package:delivery_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:delivery_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/authentication/domain/usecases/check_auth_status_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/forgot_password_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/register_rider_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/register_sender_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/update_rider_online_status_usecase.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/bloc/auth_bloc.dart';

// Feature: Orders
import 'package:delivery_app/features/orders/data/data_sources/order_local_data_source.dart';
import 'package:delivery_app/features/orders/data/repositories/order_repository_impl.dart';
import 'package:delivery_app/features/orders/domain/repositories/order_repository.dart';
import 'package:delivery_app/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:delivery_app/features/orders/domain/usecases/get_order_by_id_usecase.dart';
import 'package:delivery_app/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:delivery_app/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:delivery_app/features/orders/presentation/bloc/bloc/new_order_bloc.dart';

// Feature: Home
import 'package:delivery_app/features/home/data/data_sources/home_local_data_source.dart';
import 'package:delivery_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:delivery_app/features/home/domain/repositories/home_repository.dart';
import 'package:delivery_app/features/home/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:delivery_app/features/home/presentation/bloc/bloc/home_bloc.dart';

// Feature: Rider
import 'package:delivery_app/features/rider/data/data_sources/rider_local_data_source.dart';
import 'package:delivery_app/features/rider/data/repositories/rider_repository_impl.dart';
import 'package:delivery_app/features/rider/domain/repositories/rider_repository.dart';
import 'package:delivery_app/features/rider/domain/usecases/get_rider_earnings_usecase.dart';
import 'package:delivery_app/features/rider/domain/usecases/get_rider_orders_usecase.dart';
import 'package:delivery_app/features/rider/domain/usecases/update_rider_order_status_usecase.dart';
import 'package:delivery_app/features/rider/presentation/bloc/bloc/rider_orders_bloc.dart';

// Feature: Tracking
import 'package:delivery_app/features/tracking/data/data_sources/tracking_local_data_source.dart';
import 'package:delivery_app/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:delivery_app/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:delivery_app/features/tracking/domain/usecases/get_active_tracking_orders_usecase.dart';
import 'package:delivery_app/features/tracking/domain/usecases/get_tracking_data_usecase.dart';
import 'package:delivery_app/features/tracking/domain/usecases/watch_tracking_updates_usecase.dart';
import 'package:delivery_app/features/tracking/presentation/bloc/bloc/tracking_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // ==================== 1. CORE & SHARED INFRASTRUCTURE ====================
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(),
  );
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<RealtimeService>(() => MockRealtimeService());
  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  sl.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(),
  );
  sl.registerLazySingleton<DocumentPickerService>(
    () => DocumentPickerServiceImpl(),
  );
  sl.registerLazySingleton<BackgroundDeliveryService>(
    () => BackgroundDeliveryServiceImpl(
      locationService: sl(),
      realtimeService: sl(),
    ),
  );

  // HTTP Client & In-App Route Navigation
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(dio: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<RouteNavigationService>(
    () => RouteNavigationServiceImpl(dio: sl()),
  );

  // App-level Cubits
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit());
  sl.registerLazySingleton<LocationGateCubit>(
    () => LocationGateCubit(locationService: sl()),
  );

  // ==================== 2. FEATURE: AUTHENTICATION ====================
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterSenderUseCase(sl()));
  sl.registerLazySingleton(() => RegisterRiderUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRiderOnlineStatusUseCase(sl()));
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      checkAuthStatusUseCase: sl(),
      loginUseCase: sl(),
      registerSenderUseCase: sl(),
      registerRiderUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resetPasswordUseCase: sl(),
      logoutUseCase: sl(),
      updateRiderOnlineStatusUseCase: sl(),
    ),
  );

  // ==================== 3. FEATURE: ORDERS ====================
  sl.registerLazySingleton<OrderLocalDataSource>(
    () => OrderLocalDataSourceImpl(realtimeService: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));
  sl.registerFactory<NewOrderBloc>(
    () => NewOrderBloc(
      createOrderUseCase: sl(),
      locationService: sl(),
    ),
  );

  // ==================== 4. FEATURE: HOME ====================
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(orderRepository: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetDashboardSummaryUseCase(sl()));
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(getDashboardSummaryUseCase: sl()),
  );

  // ==================== 5. FEATURE: RIDER ====================
  sl.registerLazySingleton<RiderLocalDataSource>(
    () => RiderLocalDataSourceImpl(orderRepository: sl()),
  );
  sl.registerLazySingleton<RiderRepository>(
    () => RiderRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetRiderOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetRiderEarningsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRiderOrderStatusUseCase(sl()));
  sl.registerFactory<RiderOrdersBloc>(
    () => RiderOrdersBloc(
      getRiderOrdersUseCase: sl(),
      getRiderEarningsUseCase: sl(),
      updateRiderOrderStatusUseCase: sl(),
      backgroundDeliveryService: sl(),
      realtimeService: sl(),
    ),
  );

  // ==================== 6. FEATURE: TRACKING ====================
  sl.registerLazySingleton<TrackingLocalDataSource>(
    () => TrackingLocalDataSourceImpl(
      orderRepository: sl(),
      realtimeService: sl(),
    ),
  );
  sl.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetActiveTrackingOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetTrackingDataUseCase(sl()));
  sl.registerLazySingleton(() => WatchTrackingUpdatesUseCase(sl()));
  sl.registerFactory<TrackingBloc>(
    () => TrackingBloc(
      getActiveTrackingOrdersUseCase: sl(),
      getTrackingDataUseCase: sl(),
      watchTrackingUpdatesUseCase: sl(),
    ),
  );

  // ==================== 7. ROUTER ====================
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(
      authBloc: sl(),
      locationGateCubit: sl(),
    ),
  );
}
