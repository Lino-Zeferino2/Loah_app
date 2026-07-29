import 'package:flutter/material.dart';

/// InheritedWidget that exposes the currently selected currency and
/// a callback to change it, following the same pattern as
/// [LocaleController] and [LoahThemeController].
///
/// USAGE:
///   final controller = CurrencyController.of(context);
///   print(controller.currencyCode); // e.g. "EUR"
///   controller.onCurrencyChanged("USD");
class CurrencyController extends InheritedWidget {
  /// Current currency code (e.g. "EUR", "USD", "BRL", "AOA").
  final String currencyCode;

  /// Callback triggered when the user selects a new currency.
  final ValueChanged<String> onCurrencyChanged;

  const CurrencyController({
    super.key,
    required this.currencyCode,
    required this.onCurrencyChanged,
    required super.child,
  });

  /// Reads the [CurrencyController] closest in the widget tree.
  static CurrencyController of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<CurrencyController>();
    assert(result != null, 'No CurrencyController found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(CurrencyController oldWidget) =>
      currencyCode != oldWidget.currencyCode;
}

