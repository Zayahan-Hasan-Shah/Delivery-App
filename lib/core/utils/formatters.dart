import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _dateTimeFormat.format(dateTime.toLocal());
  }

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _timeFormat.format(dateTime.toLocal());
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _dateFormat.format(dateTime.toLocal());
  }

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    final km = meters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }
}
