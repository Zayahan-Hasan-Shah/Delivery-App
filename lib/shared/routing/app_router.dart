import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/shared/routing/route_names.dart';
import 'package:delivery_app/shared/screens/splash_screen.dart';
import 'package:delivery_app/shared/screens/not_found_screen.dart';
import 'package:delivery_app/features/authentication/view/screen/login_screen.dart';
import 'package:delivery_app/features/authentication/view/screen/register_screen.dart';
import 'package:delivery_app/features/authentication/view/screen/forgot_password_screen.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';
import 'package:delivery_app/features/home/view/screen/home_screen.dart';
import 'package:delivery_app/features/orders/view/screen/new_order_screen.dart';
import 'package:delivery_app/features/orders/view/screen/order_details_screen.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/tracking/view/screen/track_order_screen.dart';
import 'package:delivery_app/features/rider/view/screen/rider_orders_screen.dart';
import 'package:delivery_app/features/authentication/bloc/auth_bloc.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final isAuthenticated = authState.user != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // Role permission guard: Rider cannot create orders
      if (isAuthenticated && authState.user?.role == UserRole.rider && state.matchedLocation == '/orders/new') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
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
          final order = state.extra as OrderModel?;
          if (order == null) {
            return const NotFoundScreen();
          }
          return OrderDetailsScreen(order: order);
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
