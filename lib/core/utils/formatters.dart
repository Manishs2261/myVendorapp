import 'package:intl/intl.dart';

class AppFormatters {
  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _compact = NumberFormat.compact(locale: 'en_IN');
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');

  static String currency(num amount) => _currency.format(amount);
  static String compact(num value) => _compact.format(value);
  static String date(DateTime dt) => _date.format(dt);
  static String dateTime(DateTime dt) => _dateTime.format(dt);
}
