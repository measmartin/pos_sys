import 'package:intl/intl.dart';

double roundForCurrency(double amount, String? currencyCode) {
  if (currencyCode?.toUpperCase() == 'KHR') {
    return (amount / 100).round() * 100.0;
  }
  return (amount * 100).round() / 100.0;
}

String formatAmount(double amount, String? currencyCode, String? symbol) {
  final isKhr = currencyCode?.toUpperCase() == 'KHR';
  final rounded = roundForCurrency(amount, currencyCode);
  final formatted = NumberFormat.currency(
    symbol: symbol ?? r'$',
    decimalDigits: isKhr ? 0 : 2,
  ).format(rounded);
  return formatted;
}

NumberFormat makeCurrencyFormat(String? currencyCode, String? symbol) {
  final isKhr = currencyCode?.toUpperCase() == 'KHR';
  return NumberFormat.currency(
    symbol: symbol ?? r'$',
    decimalDigits: isKhr ? 0 : 2,
  );
}
