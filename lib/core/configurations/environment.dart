import 'package:delivery_app/core/configurations/app_config.dart';

class Environment {
  static const AppConfig development = AppConfig(
    environment: EnvironmentType.dev,
    appName: 'ShefsCloud Delivery',
    apiBaseUrl: 'https://api-dev.shefscloud.local/v1',
    wsBaseUrl: 'wss://ws-dev.shefscloud.local/realtime',
  );

  static const AppConfig production = AppConfig(
    environment: EnvironmentType.prod,
    appName: 'ShefsCloud Delivery',
    apiBaseUrl: 'https://api.shefscloud.com/v1',
    wsBaseUrl: 'wss://ws.shefscloud.com/realtime',
  );
}
