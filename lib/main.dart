import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/app/initialize_app.dart';
import 'package:delivery_app/core/configurations/app_config.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/core/localization/locale_cubit.dart';
import 'package:delivery_app/core/theme/app_theme.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/bloc/auth_bloc.dart';
import 'package:delivery_app/features/home/presentation/bloc/bloc/home_bloc.dart';
import 'package:delivery_app/features/orders/presentation/bloc/bloc/new_order_bloc.dart';
import 'package:delivery_app/features/rider/presentation/bloc/bloc/rider_orders_bloc.dart';
import 'package:delivery_app/features/tracking/presentation/bloc/bloc/tracking_bloc.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/routing/app_router.dart';
import 'package:delivery_app/shared/service/location_gate_cubit.dart';

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
        BlocProvider<LocaleCubit>.value(value: sl<LocaleCubit>()),
        BlocProvider<LocationGateCubit>.value(value: sl<LocationGateCubit>()),
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
        BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
        BlocProvider<NewOrderBloc>(create: (_) => sl<NewOrderBloc>()),
        BlocProvider<TrackingBloc>(create: (_) => sl<TrackingBloc>()),
        BlocProvider<RiderOrdersBloc>(create: (_) => sl<RiderOrdersBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: AppConfig.instance.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                routerConfig: appRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
