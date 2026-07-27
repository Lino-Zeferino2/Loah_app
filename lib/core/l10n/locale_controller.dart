import 'package:flutter/material.dart';

/// InheritedWidget que expõe o [Locale] atual e um callback para o alterar.
///
/// Segue o mesmo padrão do [LoahThemeController] e [LoahNavigationController].
///
/// USAGE (dentro do build):
///   final controller = LocaleController.of(context);
///   print(controller.locale); // pt ou en
///   controller.onLocaleChanged(Locale('en'));
class LocaleController extends InheritedWidget {
  /// Locale atual (ex: Locale('pt'), Locale('en')).
  final Locale locale;

  /// Callback disparado quando o utilizador seleciona um novo idioma.
  final ValueChanged<Locale> onLocaleChanged;

  const LocaleController({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required super.child,
  });

  /// Lê o [LocaleController] mais próximo na árvore de widgets.
  static LocaleController of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<LocaleController>();
    assert(result != null, 'No LocaleController found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(LocaleController oldWidget) =>
      locale != oldWidget.locale;
}

