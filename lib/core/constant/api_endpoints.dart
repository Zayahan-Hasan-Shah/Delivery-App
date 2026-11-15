class ApiEndpoints {
  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';

  // Orders
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderTracking(String id) => '/orders/$id/tracking';
  static String orderHistory(String id) => '/orders/$id/history';

  // Rider
  static const String riderOrders = '/rider/orders';
  static const String riderProfile = '/rider/profile';
  static const String riderEarnings = '/rider/earnings';
  static const String riderLocation = '/rider/location';

  // Notifications
  static const String fcmToken = '/notifications/token';
}
