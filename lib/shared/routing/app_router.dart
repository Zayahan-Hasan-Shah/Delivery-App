import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/bloc/auth_bloc.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/state/auth_status.dart';
import 'package:delivery_app/features/authentication/presentation/view/screen/forgot_password_screen.dart';
import 'package:delivery_app/features/authentication/presentation/view/screen/login_screen.dart';
import 'package:delivery_app/features/authentication/presentation/view/screen/register_screen.dart';
import 'package:delivery_app/features/home/presentation/view/screen/home_screen.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/presentation/view/screen/in_app_navigation_screen.dart';
import 'package:delivery_app/features/orders/presentation/view/screen/new_order_screen.dart';
import 'package:delivery_app/features/orders/presentation/view/screen/order_details_screen.dart';
import 'package:delivery_app/features/rider/presentation/view/screen/rider_orders_screen.dart';
import 'package:delivery_app/features/tracking/presentation/view/screen/track_order_screen.dart';
import 'package:delivery_app/shared/routing/route_names.dart';
import 'package:delivery_app/shared/screens/location_permission_gate_screen.dart';
import 'package:delivery_app/shared/screens/not_found_screen.dart';
import 'package:delivery_app/shared/screens/splash_screen.dart';
import 'package:delivery_app/shared/service/location_gate_cubit.dart';

class _CombinedRefreshListenable extends ChangeNotifier {
  final List<StreamSubscription<dynamic>> _subs = [];

  _CombinedRefreshListenable(List<Stream<dynamic>> streams) {
    for (final stream in streams) {
      _subs.add(stream.asBroadcastStream().listen((_) => notifyListeners()));
    }
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }
}

class AppRouter {
  final AuthBloc authBloc;
  final LocationGateCubit locationGateCubit;

  AppRouter({
    required this.authBloc,
    required this.locationGateCubit,
  });

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _CombinedRefreshListenable([
      authBloc.stream,
      locationGateCubit.stream,
    ]),
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      final path = state.uri.path;
      final gateState = locationGateCubit.state;
      final authState = authBloc.state;

      // 1. MANDATORY LOCATION PERMISSION GATE ON APP START
      if (!gateState.isGranted) {
        if (gateState.isChecking && path == '/splash') {
          return null;
        }
        return path == '/location-permission' ? null : '/location-permission';
      }

      // 2. AUTHENTICATION FLOW
      final isAuthenticated = authState.status == AuthStatus.authenticated &&
          authState.user != null;
      final isAuthRoute = path == '/login' ||
          path == '/register' ||
          path == '/forgot-password';

      if (authState.status == AuthStatus.initial) {
        return path == '/splash' ? null : '/splash';
      }

      if (!isAuthenticated) {
        if (isAuthRoute) return null;
        return '/login';
      }

      // 3. AUTHENTICATED REDIRECTS & ROLE GUARDS
      if (path == '/splash' || path == '/location-permission' || isAuthRoute) {
        return '/home';
      }

      // Riders cannot create orders
      if (authState.user!.role.isRider && path == '/orders/new') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/location-permission',
        name: RouteNames.locationGate,
        builder: (context, state) => const LocationPermissionGateScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/orders/new',
        name: RouteNames.newOrder,
        builder: (context, state) => const NewOrderScreen(),
      ),
      GoRoute(
        path: '/orders/details',
        name: RouteNames.orderDetails,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is OrderEntity) {
            return OrderDetailsScreen(order: extra);
          }
          if (extra is Map<String, dynamic> && extra['order'] is OrderEntity) {
            return OrderDetailsScreen(
              order: extra['order'] as OrderEntity,
              assignedColor: extra['color'] as Color?,
            );
          }
          return const NotFoundScreen();
        },
      ),
      GoRoute(
        path: '/orders/navigate',
        name: RouteNames.inAppNavigation,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic> && extra['order'] is OrderEntity) {
            return InAppNavigationScreen(
              order: extra['order'] as OrderEntity,
              navigateToPickup: extra['toPickup'] == true,
              orderColor: extra['color'] as Color?,
            );
          }
          return const NotFoundScreen();
        },
      ),
      GoRoute(
        path: '/tracking',
        name: RouteNames.trackOrder,
        builder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'];
          return TrackOrderScreen(initialOrderId: orderId);
        },
      ),
      GoRoute(
        path: '/rider/orders',
        name: RouteNames.riderOrders,
        builder: (context, state) => const RiderOrdersScreen(),
      ),
    ],
  );
}
