import 'package:flutter/material.dart';
import 'package:delivery_app/core/configurations/app_config.dart';
import 'package:delivery_app/core/configurations/environment.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/core/localization/locale_cubit.dart';
import 'package:delivery_app/core/utils/app_logger.dart';
import 'package:delivery_app/shared/service/notification_service.dart';
import 'package:delivery_app/shared/service/realtime_service.dart';

class InitializeApp {
  static Future<void> initialize({AppConfig? config}) async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize App Configuration
    AppConfig.initialize(config ?? Environment.development);
    AppLogger.info(
      'AppConfig initialized in ${AppConfig.instance.environment.name} mode',
    );

    // 2. Initialize Service Locator / Dependency Injection
    await initServiceLocator();
    AppLogger.info('Service locator registered');

    // 3. Load Saved Locale (EN / UR)
    await sl<LocaleCubit>().loadSavedLocale();

    // 4. Initialize Push Notifications Abstraction
    await sl<NotificationService>().initialize();

    // 5. Connect to Real-time Stream Engine
    await sl<RealtimeService>().connect();

    AppLogger.info('Application bootstrap complete');
  }
}
