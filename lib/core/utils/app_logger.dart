import 'dart:developer' as developer;

class AppLogger {
  static void debug(String message, {String tag = 'DEBUG'}) {
    developer.log('[$tag] $message', level: 500);
  }

  static void info(String message, {String tag = 'INFO'}) {
    developer.log('[$tag] $message', level: 800);
  }

  static void warning(String message, {String tag = 'WARNING'}) {
    developer.log('[$tag] ⚠️ $message', level: 900);
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace, String tag = 'ERROR'}) {
    developer.log(
      '[$tag] ❌ $message',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
