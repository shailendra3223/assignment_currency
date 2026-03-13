import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currencyCode) {
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
    return '${formatter.format(amount)} $currencyCode';
  }

  static String formatWithSymbol(double amount, String code) {
    const symbols = {
      'USD': '\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥',
      'INR': '₹', 'CNY': '¥', 'KRW': '₩', 'RUB': '₽',
    };
    final symbol = symbols[code] ?? code;
    return '$symbol ${NumberFormat('#,##0.00').format(amount)}';
  }
}
