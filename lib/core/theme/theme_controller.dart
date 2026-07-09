import 'package:flutter/material.dart';

/// Inherited widget so any screen/widget can read the current
/// [ThemeMode] and flip it (e.g. from the drawer's theme switch or a
/// settings icon) without prop-drilling a callback through every level.
class LoahThemeController extends InheritedWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const LoahThemeController({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required super.child,
  });

  static LoahThemeController of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<LoahThemeController>();
    assert(result != null, 'No LoahThemeController found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(LoahThemeController oldWidget) =>
      themeMode != oldWidget.themeMode;
}
