enum EnvironmentType { dev, staging, prod }

class AppConfig {
  final EnvironmentType environment;
  final String appName;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const AppConfig({
    required this.environment,
    required this.appName,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
  });

  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  static void initialize(AppConfig config) {
    _instance = config;
  }
}
