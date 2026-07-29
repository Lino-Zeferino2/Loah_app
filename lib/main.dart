// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'core/currency/currency_controller.dart';
import 'core/l10n/locale_controller.dart';
import 'core/navigation/navigation_controller.dart';
import 'core/services/analytics_service.dart';
import 'core/services/contact_service.dart';
import 'core/services/goal_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/notification_scheduler.dart';
import 'core/services/task_service.dart';
import 'core/services/user_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'models/app_notification.dart';
import 'screens/contacts/contacts_screen.dart';
import 'screens/contacts/contact_detail_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/goals/goal_detail_screen.dart';
import 'screens/finances/finances_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/tasks/task_detail_screen.dart';
import 'widgets/loah_bottom_nav.dart';
import 'screens/splash/splash_screen.dart';

/// Global navigator key for accessing NavigatorState from anywhere
/// (e.g., from Crashlytics error recovery).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Firebase Analytics ────────────────────────────────────────
  try {
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(true);
  } catch (e) {
    debugPrint('[main] Analytics init error (non-fatal): $e');
  }

  // ── Firebase Crashlytics ──────────────────────────────────────
  FlutterError.onError = (errorDetails) {
    try {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    } catch (_) {}
  };

  // Passa os erros de zonas assíncronas para o Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (_) {}
    return true;
  };

  // ── Firestore Offline Persistence ─────────────────────────────
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('[main] Firestore settings error (non-fatal): $e');
  }

  // ── FCM Push Notifications ────────────────────────────────────
  await NotificationService().initialize();

  // Start periodic checks for local notifications (contact overdue,
  // tasks due, recurring bills, budgets over limit, etc.)
  NotificationScheduler().startPeriodicChecks(intervalMinutes: 30);
  NotificationScheduler().runAllChecks();

  // ── Configure Analytics user ──────────────────────────────────
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await AnalyticsService().setUserId(user.uid);
    }
  } catch (e) {
    debugPrint('[main] Analytics user config error (non-fatal): $e');
  }

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
  Locale _locale = const Locale('pt');
  String _currencyCode = 'BRL';

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _onLocaleChanged(Locale locale) {
    setState(() => _locale = locale);
    _persistLocalePreference(locale);
  }

  Future<void> _persistLocalePreference(Locale locale) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserService().updateUserProfile(
          uid: user.uid,
          data: {'locale': locale.languageCode},
        );
      }
    } catch (e) {
      debugPrint('[Locale] Erro ao persistir preferência: $e');
    }
  }

  void _onCurrencyChanged(String code) {
    setState(() => _currencyCode = code);
    _persistCurrencyPreference(code);
  }

  Future<void> _persistCurrencyPreference(String code) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserService().updateUserProfile(
          uid: user.uid,
          data: {'currency': code},
        );
      }
    } catch (e) {
      debugPrint('[Currency] Erro ao persistir preferência: $e');
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await UserService().getUserProfile(user.uid);
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final savedLocale = data['locale'] as String?;
          if (savedLocale != null && savedLocale.isNotEmpty) {
            setState(() => _locale = Locale(savedLocale));
          }
          final savedCurrency = data['currency'] as String?;
          if (savedCurrency != null && savedCurrency.isNotEmpty) {
            setState(() => _currencyCode = savedCurrency);
          }
        }
      }
    } catch (e) {
      debugPrint('[main] Erro ao carregar preferências: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleController(
      locale: _locale,
      onLocaleChanged: _onLocaleChanged,
      child: LoahThemeController(
        themeMode: _themeMode,
        toggleTheme: _toggleTheme,
        child: CurrencyController(
          currencyCode: _currencyCode,
          onCurrencyChanged: _onCurrencyChanged,
          child: MaterialApp(
            title: 'Loah',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _themeMode,
            locale: _locale,
            supportedLocales: const [
              Locale('pt'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) return const Locale('pt');
              for (final supported in supportedLocales) {
                if (supported.languageCode == locale.languageCode) {
                  return supported;
                }
              }
              return const Locale('pt');
            },
            home: const SplashScreenVistoso(),
          ),
        ),
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

  /// Navega para a tela apropriada quando o usuário toca numa
  /// notificação push. Conectado via [NotificationService.setNavigator].
  /// Busca os dados completos do Firestore para abrir a tela de detalhes.
  void _navigateFromNotification(AppNotification notification) {
    switch (notification.category) {
      case NotificationCategory.contacts:
        if (notification.relatedId != null) {
          _openContactDetail(notification.relatedId!);
        } else {
          _navigateTo(4);
        }
        break;
      case NotificationCategory.tasks:
        if (notification.relatedId != null) {
          _openTaskDetail(notification.relatedId!);
        }
        break;
      case NotificationCategory.goals:
        if (notification.relatedId != null) {
          _openGoalDetail(notification.relatedId!);
        } else {
          _navigateTo(1);
        }
        break;
      case NotificationCategory.finance:
        _navigateTo(3);
        break;
      case NotificationCategory.system:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
        break;
    }
  }

  /// Busca o contacto completo do Firestore e abre a tela de detalhes.
  Future<void> _openContactDetail(String contactId) async {
    final contact = await ContactService().getContact(contactId);
    if (contact == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContactDetailScreen(contact: contact),
      ),
    );
  }

  /// Busca a tarefa completa do Firestore e abre a tela de detalhes.
  Future<void> _openTaskDetail(String taskId) async {
    final task = await TaskService().getTask(taskId);
    if (task == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );
  }

  /// Busca a meta completa do Firestore e abre a tela de detalhes.
  Future<void> _openGoalDetail(String goalId) async {
    final goal = await GoalService().getGoal(goalId);
    if (goal == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GoalDetailScreen(goal: goal),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Conecta o callback de navegação para quando o usuário tocar
    // numa notificação push (FCM) ou local notification.
    NotificationService().setNavigator(_navigateFromNotification);
  }

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
