import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/app/initialize_app.dart';
import 'package:delivery_app/core/configurations/app_config.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/core/theme/app_theme.dart';
import 'package:delivery_app/shared/routing/app_router.dart';
import 'package:delivery_app/features/authentication/bloc/auth_bloc.dart';
import 'package:delivery_app/features/home/bloc/home_bloc.dart';
import 'package:delivery_app/features/orders/bloc/new_order_bloc.dart';
import 'package:delivery_app/features/tracking/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/rider/bloc/rider_orders_bloc.dart';

void main() async {
  await InitializeApp.initialize();
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = sl<AppRouter>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => sl<HomeBloc>(),
        ),
        BlocProvider<NewOrderBloc>(
          create: (_) => sl<NewOrderBloc>(),
        ),
        BlocProvider<TrackingBloc>(
          create: (_) => sl<TrackingBloc>(),
        ),
        BlocProvider<RiderOrdersBloc>(
          create: (_) => sl<RiderOrdersBloc>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: AppConfig.instance.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
