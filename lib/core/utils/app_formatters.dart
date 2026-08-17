import 'package:intl/intl.dart';

class AppFormatters {
  static String currency(num amount, [String locale = 'uz']) {
    String symbol = 'UZS';
    String localeCode = 'en_US';

    if (locale == 'uz') {
      symbol = 'so\'m';
      localeCode = 'uz_UZ';
    } else if (locale == 'ru') {
      symbol = 'сум';
      localeCode = 'ru_RU';
    } else if (locale == 'en') {
      symbol = 'UZS';
      localeCode = 'en_US';
    }

    final format = NumberFormat.currency(
      locale: localeCode,
      symbol: symbol,
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  static String date(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
}
