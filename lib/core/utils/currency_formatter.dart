import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  /// Formats the price based on the current locale.
  /// If [currencyCode] is not provided, defaults to UZS.
  static String format(
    num price,
    BuildContext context, {
    String currencyCode = 'UZS',
  }) {
    String symbol = currencyCode;
    String localeCode = Localizations.localeOf(context).languageCode;
    
    if (currencyCode == 'UZS') {
      if (localeCode == 'uz') {
        symbol = 'so\'m';
        localeCode = 'uz_UZ';
      } else if (localeCode == 'ru') {
        symbol = 'сум';
        localeCode = 'ru_RU';
      } else if (localeCode == 'en') {
        symbol = 'UZS';
        localeCode = 'en_US';
      }
    }

    final formatter = NumberFormat.currency(
      locale: localeCode,
      name: currencyCode,
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(price);
  }
}
