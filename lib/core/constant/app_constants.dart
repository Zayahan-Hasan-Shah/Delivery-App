class AppConstants {
  static const String appTitle = 'LogiFlow Delivery';

  // Secure storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyFcmToken = 'fcm_token';

  // Location tracking configuration
  static const int locationDistanceFilterMeters = 10;
  static const int locationUpdateIntervalSeconds = 5;

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Default coordinates (e.g. City Center for initial map focus)
  static const double defaultLatitude = 33.6844;
  static const double defaultLongitude = 73.0479;
}
