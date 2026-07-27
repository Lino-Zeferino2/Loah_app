import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'core/navigation/navigation_controller.dart';
import 'core/services/contact_service.dart';
import 'core/services/goal_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/notification_scheduler.dart';
import 'core/services/task_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'models/app_notification.dart';
import 'models/contact_model.dart';
import 'models/goal_model.dart';
import 'models/task_model.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM push notifications
  await NotificationService().initialize();

  // Start periodic checks for local notifications (contact overdue,
  // tasks due, recurring bills, budgets over limit, etc.)
  NotificationScheduler().startPeriodicChecks(intervalMinutes: 30);
  NotificationScheduler().runAllChecks();

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

