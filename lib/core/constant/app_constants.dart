class AppConstants {
  static const String appTitle = 'ShefsCloud Delivery';

  // Secure storage & SharedPreferences keys
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyFcmToken = 'fcm_token';
  static const String keyAppLocale = 'app_locale';
  static const String keyRiderOnlineShift = 'rider_online_shift';

  // Location tracking configuration
  static const int locationDistanceFilterMeters = 10;
  static const int locationUpdateIntervalSeconds = 5;

  // Cash in hand limit (PKR)
  static const double riderCashInHandLimitPkr = 25000.0;

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Default coordinates (Islamabad City Center)
  static const double defaultLatitude = 33.6844;
  static const double defaultLongitude = 73.0479;
}
