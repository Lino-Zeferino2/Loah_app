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
import '../../core/utils/budget_summary.dart';
import '../../core/utils/finance_summary.dart';
import '../../core/theme/app_theme.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_drawer.dart';
import '../../widgets/section_header.dart';
// import 'widgets/new_item_modal_sheet.dart';
import '../../models/task_model.dart';
import '../../models/goal_model.dart';
import '../../models/reflection_model.dart';
import '../../models/account_model.dart';
import '../../models/asset_model.dart';
import '../../models/budget_model.dart';
import '../../models/recurring_transaction_model.dart';
import '../../models/transaction_model.dart';
import '../../core/services/reflection_service.dart';
import '../../core/utils/recurring_engine.dart';
import '../finances/accounts_screen.dart';
import '../finances/assets_screen.dart';
import '../finances/budgets_screen.dart';
import '../finances/recurring_transactions_screen.dart';
import '../finances/reports_screen.dart';
import '../finances/add_transaction_screen.dart';
import '../finances/transaction_history_screen.dart';
import '../finances/expense_distribution_detail_screen.dart';
import '../finances/widgets/expense_distribution_card.dart';
import '../finances/widgets/transaction_list_item.dart';
import '../finances/widgets/account_card.dart';
import '../finances/widgets/asset_card.dart';
import '../finances/widgets/budget_card.dart';
import '../finances/widgets/recurring_transaction_card.dart';
import 'widgets/balance_card.dart';
import 'widgets/daily_reflection_card.dart';
import 'widgets/goals_summary_card.dart';
import 'widgets/pending_tasks_card.dart';

/// "Loah - Dashboard Financeiro": the home screen with a complete financial
/// overview: greeting, balance card, quick links, expense distribution,
/// accounts summary, assets summary, budgets overview, recurring list,
/// recent transactions, goals summary, pending tasks, daily reflection,
/// and a FAB to add new transactions.
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
  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];
  List<AssetModel> _assets = [];
  List<BudgetModel> _budgets = [];
  List<RecurringTransactionModel> _recurring = [];
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
      // Process due recurring transactions
      await RecurringEngine.processDue(financeService: _financeService);

      final txns = await _financeService.getAllTransactions();
      final accts = await _financeService.getAllAccounts();
      final assets = await _financeService.getAllAssets();
      final budgets = await _financeService.getAllBudgets();
      final recurring = await _financeService.getAllRecurring();

      final accountsBalance = AccountBalance.totalOf(accts, txns);
      final assetsValue = assets.fold<double>(0.0, (sum, a) => sum + a.currentValue);
      final totalWealth = accountsBalance + assetsValue;

      final monthlyIncome = FinanceSummary.monthlyIncome(txns);
      final monthlyExpense = FinanceSummary.monthlyExpense(txns);
      final progress = monthlyIncome > 0
          ? (monthlyExpense / monthlyIncome).clamp(0.0, 1.0)
          : 0.0;

      if (mounted) {
        setState(() {
          _transactions = txns;
          _accounts = accts;
          _assets = assets;
          _budgets = budgets;
          _recurring = recurring;
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

  Future<void> _addTransaction() async {
    if (_accounts.isEmpty) {
      if (mounted) {
        final loc = AppLocales.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('finances_criar_conta_primeiro')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (result == true) _loadData();
  }

  Future<void> _openAccounts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountsScreen()),
    );
    _loadData();
  }

  Future<void> _openAssets() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AssetsScreen()),
    );
    _loadData();
  }

  Future<void> _openBudgets() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BudgetsScreen()),
    );
    _loadData();
  }

  Future<void> _openRecurring() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RecurringTransactionsScreen()),
    );
    _loadData();
  }

  Future<void> _openReports() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReportsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nav = LoahNavigationController.of(context);
    final loc = AppLocales.of(context);
    final colors = context.loahColors;
    final notificationCount = _unreadCount;

    final transactions = _transactions;
    final accounts = _accounts;
    final assets = _assets;
    final budgets = _budgets;
    final recurring = _recurring;

    final total = _totalWealth;
    final distribution = FinanceSummary.expenseDistribution(transactions);
    final recentCapped = transactions.take(10).toList();

    final budgetProgressList = BudgetSummary.all(budgets, transactions);
    final activeRecurring = recurring.where((r) => r.active).toList();

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
              // ── Greeting ──
              Text(
                loc.translate('dashboard_ola').replaceAll(
                  '%s',
                  AuthService().currentUser?.displayName?.split(' ').first ?? 'Utilizador',
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

              // ── Balance Card ──
              BalanceCard(
                available: total,
                progressToGoal: _progressToGoal,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Quick Links Row ──
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _QuickLinkCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: loc.translate('dashboard_contas'),
                      color: colors.accentBlue,
                      onTap: _openAccounts,
                    ),
                    const SizedBox(width: 10),
                    _QuickLinkCard(
                      icon: Icons.account_balance_outlined,
                      label: loc.translate('dashboard_patrimonio'),
                      color: colors.accentBlue,
                      onTap: _openAssets,
                    ),
                    const SizedBox(width: 10),
                    _QuickLinkCard(
                      icon: Icons.pie_chart_outline,
                      label: loc.translate('dashboard_orcamento'),
                      color: colors.accentBlue,
                      onTap: _openBudgets,
                    ),
                    const SizedBox(width: 10),
                    _QuickLinkCard(
                      icon: Icons.autorenew,
                      label: loc.translate('dashboard_recorrentes'),
                      color: colors.accentBlue,
                      onTap: _openRecurring,
                    ),
                    const SizedBox(width: 10),
                    _QuickLinkCard(
                      icon: Icons.bar_chart_outlined,
                      label: loc.translate('dashboard_relatorios'),
                      color: colors.accentBlue,
                      onTap: _openReports,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Expense Distribution ──
              if (distribution.isNotEmpty)
                ExpenseDistributionCard(
                  categories: distribution,
                  onDetails: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExpenseDistributionDetailScreen()),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    loc.translate('finances_sem_despesas'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),

              // ── Accounts Summary ──
              SectionHeader(
                title: loc.translate('dashboard_contas_titulo'),
                trailing: TextButton(
                  onPressed: _openAccounts,
                  child: Text(loc.translate('dashboard_ver_tudo')),
                ),
              ),
              const SizedBox(height: 10),
              if (accounts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    loc.translate('dashboard_sem_contas_resumo'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                for (final a in accounts.take(3)) ...[
                  AccountCard(
                    account: a,
                    allTransactions: transactions,
                    onTap: _openAccounts,
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: AppSpacing.md),

              // ── Assets Summary ──
              SectionHeader(
                title: loc.translate('dashboard_ativos_titulo'),
                trailing: TextButton(
                  onPressed: _openAssets,
                  child: Text(loc.translate('dashboard_ver_tudo')),
                ),
              ),
              const SizedBox(height: 10),
              if (assets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    loc.translate('dashboard_sem_ativos_resumo'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                for (final a in assets.take(3)) ...[
                  AssetCard(
                    asset: a,
                    onTap: _openAssets,
                    onQuickUpdate: () {},
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: AppSpacing.md),

              // ── Budgets Overview ──
              SectionHeader(
                title: loc.translate('dashboard_orcamentos_titulo'),
                trailing: TextButton(
                  onPressed: _openBudgets,
                  child: Text(loc.translate('dashboard_ver_tudo')),
                ),
              ),
              const SizedBox(height: 10),
              if (budgetProgressList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    loc.translate('dashboard_sem_orcamentos_resumo'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                for (final progress in budgetProgressList.take(3)) ...[
                  BudgetCard(
                    progress: progress,
                    onTap: () => _openBudgets(),
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: AppSpacing.md),

              // ── Recurring Transactions ──
              SectionHeader(
                title: loc.translate('dashboard_recorrentes_titulo'),
                trailing: TextButton(
                  onPressed: _openRecurring,
                  child: Text(loc.translate('dashboard_ver_tudo')),
                ),
              ),
              const SizedBox(height: 10),
              if (activeRecurring.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    loc.translate('dashboard_sem_recorrentes_resumo'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                for (final r in activeRecurring.take(3)) ...[
                  RecurringTransactionCard(
                    recurring: r,
                    onTap: _openRecurring,
                    onActiveChanged: (_) {},
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: AppSpacing.lg),

              // ── Recent Transactions ──
              SectionHeader(
                title: loc.translate('dashboard_transacoes_recentes'),
                trailing: TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                    );
                    _loadData();
                  },
                  child: Text(loc.translate('dashboard_ver_tudo')),
                ),
              ),
              const SizedBox(height: 10),
              if (recentCapped.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      loc.translate('dashboard_sem_transacoes'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                for (final t in recentCapped) ...[
                  TransactionListItem(
                    transaction: t,
                    onTap: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(existingTransaction: t),
                        ),
                      );
                      if (result == true) _loadData();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                  );
                  _loadData();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(loc.translate('dashboard_ver_historico')),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Goals Summary ──
              GoalsSummaryCard(
                goals: _goals.take(3).toList(),
                allTasks: _standaloneTasks,
                onSeeAll: () => nav.navigateTo(1),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Pending Tasks ──
              PendingTasksCard(
                tasks: _standaloneTasks,
                onToggle: (i) => _toggleTask(i),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Daily Reflection ──
              DailyReflectionCard(
                quote: _activeReflection?.text ?? 'O que é medido, é gerenciado.',
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
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Compact tappable card used for quick links.
class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 90,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
