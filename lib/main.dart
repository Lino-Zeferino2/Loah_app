import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'core/navigation/navigation_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'screens/contacts/contacts_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/finances/finances_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'widgets/loah_bottom_nav.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LoahApp());
}

/// Root widget: owns the [ThemeMode] and exposes a way for descendants
/// to toggle between light and dark (see [LoahThemeController]).
class LoahApp extends StatefulWidget {
  const LoahApp({super.key});

  @override
  State<LoahApp> createState() => _LoahAppState();
}

class _LoahAppState extends State<LoahApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoahThemeController(
      themeMode: _themeMode,
      toggleTheme: _toggleTheme,
      child: MaterialApp(
        title: 'Loah',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
       home: const SplashScreenVistoso(),   // pra testar a versão vistosa
      ),
    );
  }
}

/// Hosts the bottom navigation (4 tabs) plus a 5th drawer-only screen
/// (Contatos), preserving every screen's state via [IndexedStack].
///
/// Exposes [LoahNavigationController] so the drawer (or any screen) can
/// switch tabs — including to the drawer-only "Contatos" screen, which
/// sits outside the bottom nav's index range.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),   // 0
    GoalsScreen(),       // 1
    TasksScreen(),       // 2
    FinancesScreen(),    // 3
    ContactsScreen(),    // 4 — drawer-only, not in the bottom nav
  ];

  void _navigateTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return LoahNavigationController(
      currentIndex: _index,
      navigateTo: _navigateTo,
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        // The bottom nav only covers indices 0-3; when Contatos (4) is
        // open via the drawer, no tab shows as selected — which is the
        // correct behavior since it isn't one of the 4 bottom tabs.
        bottomNavigationBar: LoahBottomNav(
          currentIndex: _index,
          onTap: _navigateTo,
        ),
      ),
    );
  }
}
