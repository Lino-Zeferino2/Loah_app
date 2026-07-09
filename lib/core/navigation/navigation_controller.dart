import 'package:flutter/material.dart';

/// Inherited widget exposing which top-level screen is currently shown
/// (by index) and a function to switch to another one. Provided by
/// `RootShell` in `main.dart`; read by [LoahDrawer] and any screen that
/// needs to navigate (e.g. "Ver todas" linking Dashboard -> Metas).
class LoahNavigationController extends InheritedWidget {
  final int currentIndex;
  final ValueChanged<int> navigateTo;

  const LoahNavigationController({
    super.key,
    required this.currentIndex,
    required this.navigateTo,
    required super.child,
  });

  static LoahNavigationController of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<LoahNavigationController>();
    assert(result != null, 'No LoahNavigationController found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(LoahNavigationController oldWidget) =>
      currentIndex != oldWidget.currentIndex;
}
