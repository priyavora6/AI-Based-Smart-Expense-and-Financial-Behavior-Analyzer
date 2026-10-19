import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatCompactCurrency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.compactCurrency(symbol: symbol);
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String symbol = '₹'}) =>
      formatCompactCurrency(amount, symbol: symbol);

  static String formatWithSign(double amount, [String? type]) {
    final sign = type == 'expense' || amount < 0 ? '-' : '+';
    return '$sign${formatCurrency(amount.abs(), symbol: '₹')}';
  }
}
