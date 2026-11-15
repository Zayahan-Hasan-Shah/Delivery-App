import 'app_config.dart';

class Environment {
  static const AppConfig development = AppConfig(
    environment: EnvironmentType.dev,
    appName: 'LogiFlow Delivery (Dev)',
    apiBaseUrl: 'https://api-dev.deliveryapp.local/v1',
    wsBaseUrl: 'wss://ws-dev.deliveryapp.local/realtime',
  );

  static const AppConfig production = AppConfig(
    environment: EnvironmentType.prod,
    appName: 'LogiFlow Delivery',
    apiBaseUrl: 'https://api.deliveryapp.com/v1',
    wsBaseUrl: 'wss://ws.deliveryapp.com/realtime',
  );
}
