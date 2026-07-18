import 'package:intl/intl.dart';

/// Formats numbers as Brazilian Real currency, e.g. `R$ 4.820,50`.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '€',
    decimalDigits: 2,
  );

  static String format(double value) => _formatter.format(value);
}
