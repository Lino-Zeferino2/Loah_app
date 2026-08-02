// ignore_for_file: avoid_types_as_parameter_names

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_repository.dart';
import '../../core/services/task_service.dart';
import '../../core/services/goal_service.dart';
import '../../core/services/finance_service.dart';
import '../../core/utils/account_balance.dart';
import '../../core/utils/finance_summary.dart';
import '../../core/theme/app_theme.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_drawer.dart';
import 'widgets/new_item_modal_sheet.dart';
import '../../models/task_model.dart';
import '../../models/goal_model.dart';
import '../../models/reflection_model.dart';
import '../../core/services/reflection_service.dart';
import 'widgets/balance_card.dart';
import 'widgets/daily_reflection_card.dart';
import 'widgets/goals_summary_card.dart';
import 'widgets/new_item_card.dart';
import 'widgets/pending_tasks_card.dart';

/// "Loah - Dashboard": the home screen with a greeting, balance summary,
/// pending tasks, a quick-add card, goal progress and a daily reflection.
///
/// Lê tarefas, metas e finanças do Firestore via services.
/// O saldo e progresso financeiro são calculados em tempo real.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TaskService _taskService = TaskService();
  final GoalService _goalService = GoalService();
  final FinanceService _financeService = FinanceService();
  final NotificationRepository _notificationRepo = NotificationRepository();
  final ReflectionService _reflectionService = ReflectionService();

  List<TaskModel> _standaloneTasks = [];
  List<GoalModel> _goals = [];
  double _totalWealth = 0;
  double _progressToGoal = 0;
  int _unreadCount = 0;
  ReflectionModel? _activeReflection;
  StreamSubscription? _notificationSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _notificationSub = _notificationRepo.getUnreadCountStream().listen((count) {
      if (mounted) setState(() => _unreadCount = count);
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  Future<bool> _loadFinanceData() async {
    if (!mounted || FirebaseAuth.instance.currentUser == null) return false;
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('Dashboard - Sem usuário autenticado');
        return false;
      }

      final txns = await _financeService.getAllTransactions();
      final accts = await _financeService.getAllAccounts();

      double assetsValue = 0;
      try {
        final assets = await _financeService.getAllAssets();
        assetsValue = assets.fold<double>(0.0, (sum, a) => sum + a.currentValue);
      } catch (e) {
        debugPrint('Dashboard - Erro ao carregar ativos: $e');
      }

      final accountsBalance = AccountBalance.totalOf(accts, txns);
      final totalWealth = accountsBalance + assetsValue;

      final monthlyIncome = FinanceSummary.monthlyIncome(txns);
      final monthlyExpense = FinanceSummary.monthlyExpense(txns);

      final progress = monthlyIncome > 0
          ? (monthlyExpense / monthlyIncome).clamp(0.0, 1.0)
          : 0.0;

      if (mounted) {
        setState(() {
          _totalWealth = totalWealth;
          _progressToGoal = progress;
        });
      }
      return true;
    } catch (e) {
      debugPrint('Dashboard - Erro ao carregar finanças: $e');
      return false;
    }
  }

  Future<void> _loadData() async {
    if (!mounted || FirebaseAuth.instance.currentUser == null) return;
    await _loadFinanceData();

    try {
      final tasksSnapshot = await _taskService.getTasksStream().first;
      final standalone = tasksSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return TaskModel(
              id: doc.id,
              title: data['title'] ?? '',
              subtitle: data['subtitle'],
              tag: data['tag'],
              dueLabel: data['dueLabel'],
              priority: data['priority'] != null
                  ? TaskPriority.values.firstWhere(
                      (p) => p.name == data['priority'],
                      orElse: () => TaskPriority.baixa,
                    )
                  : null,
              isDone: data['isDone'] ?? false,
              goalId: data['goalId'],
              completedAt: data['completedAt'] != null
                  ? (data['completedAt'] as Timestamp).toDate()
                  : null,
              description: data['description'],
              dueDate: data['dueDate'] != null
                  ? (data['dueDate'] as Timestamp).toDate()
                  : null,
              createdAt: data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : null,
              status: data['status'] != null
                  ? TaskStatus.values.firstWhere(
                      (s) => s.name == data['status'],
                      orElse: () => TaskStatus.pendente,
                    )
                  : null,
            );
          })
          .where((t) => t.goalId == null)
          .toList();

      final goalsSnapshot = await _goalService.getGoalsStream().first;
      final goals = goalsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return GoalModel(
          id: doc.id,
          title: data['title'] ?? '',
          category: data['category'] ?? 'Pessoal',
          term: data['term'] != null
              ? GoalTerm.values.firstWhere(
                  (t) => t.name == data['term'],
                  orElse: () => GoalTerm.curtoPrazo,
                )
              : GoalTerm.curtoPrazo,
          progressMode: data['progressMode'] != null
              ? GoalProgressMode.values.firstWhere(
                  (m) => m.name == data['progressMode'],
                  orElse: () => GoalProgressMode.manualValue,
                )
              : GoalProgressMode.manualValue,
          current: (data['current'] as num?)?.toDouble(),
          target: (data['target'] as num?)?.toDouble(),
          imageAsset: data['imageAsset'],
          description: data['description'],
          targetDate: data['targetDate'] != null
              ? (data['targetDate'] as Timestamp).toDate()
              : null,
          progressColor: data['progressColor'] != null
              ? Color(int.parse(data['progressColor']))
              : Colors.blue,
          remainingLabel: data['remainingLabel'],
        );
      }).toList();

      if (mounted) {
        setState(() {
          _standaloneTasks = standalone;
          _goals = goals;
        });
      }
    } catch (e) {
      debugPrint('Dashboard - Erro ao carregar tasks/goals: $e');
    }

    try {
      final reflections = await _reflectionService.getAllActiveReflections();
      if (mounted) {
        if (reflections.isNotEmpty) {
          final randomIndex = Random().nextInt(reflections.length);
          setState(() => _activeReflection = reflections[randomIndex]);
        } else {
          setState(() => _activeReflection = null);
        }
      }
    } catch (e) {
      debugPrint('Dashboard - Erro ao carregar reflexões: $e');
    }
  }

  void _toggleTask(int index) {
    if (index >= _standaloneTasks.length) return;
    final task = _standaloneTasks[index];
    final updated = task.copyWith(isDone: !task.isDone);
    _taskService.updateTask(updated);
    setState(() {
      _standaloneTasks[index] = updated;
    });
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = LoahNavigationController.of(context);
    final loc = AppLocales.of(context);
    final notificationCount = _unreadCount;

    return Scaffold(
      drawer: LoahDrawer(
        currentIndex: nav.currentIndex,
        onNavigate: nav.navigateTo,
      ),
      appBar: LoahAppBar(
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: loc.translate('common_notificacoes'),
                onPressed: _openNotifications,
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              if (notificationCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$notificationCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                loc.translate('dashboard_ola').replaceAll(
                  '%s',
                  AuthService().currentUser?.displayName?.split(' ').first ??
                      loc.translate('dashboard_utilizador'),
                ),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                loc.translate('dashboard_subtitulo'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Card de Finanças com dados reais do Firebase
              BalanceCard(
                available: _totalWealth,
                progressToGoal: _progressToGoal,
              ),
              const SizedBox(height: AppSpacing.lg),
              PendingTasksCard(
                tasks: _standaloneTasks,
                onToggle: (i) => _toggleTask(i),
              ),
              const SizedBox(height: AppSpacing.lg),
              NewItemCard(
                onCreate: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    backgroundColor: context.loahColors.cardBackground,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const NewItemModalSheet(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              GoalsSummaryCard(
                goals: _goals.take(3).toList(),
                allTasks: _standaloneTasks,
                onSeeAll: () => nav.navigateTo(1),
              ),
              const SizedBox(height: AppSpacing.lg),
              DailyReflectionCard(
                quote: _activeReflection?.localizedText(loc.languageCode) ??
                    loc.translate('reflection_fallback_quote'),
                imageUrl: _activeReflection?.imageUrl.isNotEmpty == true
                    ? _activeReflection!.imageUrl
                    : 'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=800',
              ),
              const SizedBox(height: AppSpacing.xxxl * 2),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        heroTag: 'dashboard_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: false,
            backgroundColor: context.loahColors.cardBackground,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const NewItemModalSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
