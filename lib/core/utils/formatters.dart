import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// R 1 234.50
  static String currency(double amount, {String symbol = 'R'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_ZA',
      symbol: '$symbol ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// 22 Jan 2026
  static String date(DateTime date) =>
      DateFormat('d MMM yyyy').format(date);

  /// 22 Jan 2026 · 14:30
  static String dateTime(DateTime date) =>
      DateFormat('d MMM yyyy · HH:mm').format(date);

  /// ORD-00042
  static String orderId(String rawId) {
    final short = rawId.length > 6 ? rawId.substring(0, 6).toUpperCase() : rawId.toUpperCase();
    return 'ORD-$short';
  }

  /// 1 234 (no decimals, for stock counts)
  static String quantity(int qty) =>
      NumberFormat('#,###').format(qty);
}
