// ignore_for_file: avoid_types_as_parameter_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/mock/account_balance.dart';
import '../../core/mock/budget_summary.dart';
import '../../core/mock/finance_summary.dart';
import '../../core/mock/goal_progress.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/account_model.dart';
import '../../models/asset_model.dart';
import '../../models/budget_model.dart';
import '../../models/goal_model.dart';
import '../../models/recurring_transaction_model.dart';
import '../../models/transaction_model.dart';
import '../../models/task_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_drawer.dart';
import '../../widgets/section_header.dart';
import '../../core/services/finance_service.dart';
import '../../core/services/goal_service.dart';
import '../../core/services/task_service.dart';
import 'accounts_screen.dart';
import 'add_transaction_screen.dart';
import 'assets_screen.dart';
import 'budgets_screen.dart';
import 'recurring_transactions_screen.dart';
import 'reports_screen.dart';
import 'widgets/emergency_goal_card.dart';
import 'widgets/expense_distribution_card.dart';
import 'widgets/total_balance_card.dart';
import 'widgets/transaction_list_item.dart';
import 'expense_distribution_detail_screen.dart';
import 'transaction_history_screen.dart';

/// "Loah - Finanças": total balance, quick links to Contas/Patrimônio,
/// the emergency-fund goal, expense distribution donut chart and
/// recent transaction history.
///
/// All figures are derived live from Firebase via [FinanceService].
class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  final FinanceService _financeService = FinanceService();
  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];
  List<AssetModel> _assets = [];
  List<BudgetModel> _budgets = [];
  List<GoalModel> _goals = [];
  List<RecurringTransactionModel> _recurring = [];
  List<TaskModel> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final txns = await _financeService.getAllTransactions();
      final accts = await _financeService.getAllAccounts();
      final assets = await _financeService.getAllAssets();
      final budgets = await _financeService.getAllBudgets();
      final recurring = await _financeService.getAllRecurring();
      final goalsSnapshot = await GoalService().getGoalsStream().first;
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

      final tasksSnapshot = await TaskService().getTasksStream().first;
      final tasks = tasksSnapshot.docs.map((doc) {
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
      }).toList();

      if (mounted) {
        setState(() {
          _transactions = txns;
          _accounts = accts;
          _assets = assets;
          _budgets = budgets;
          _recurring = recurring;
          _goals = goals;
          _tasks = tasks;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addTransaction() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (result == true) _loadData();
  }

  Future<void> _editTransaction(TransactionModel transaction) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(existingTransaction: transaction),
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _openAssets() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AssetsScreen()),
    );
    _loadData();
  }

  Future<void> _openAccounts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountsScreen()),
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
    final colors = context.loahColors;
    final nav = LoahNavigationController.of(context);

    final transactions = _transactions;
    final accounts = _accounts;

    final total = AccountBalance.totalOf(accounts, transactions);
    final income = FinanceSummary.monthlyIncome(transactions);
    final expense = FinanceSummary.monthlyExpense(transactions);
    final distribution = FinanceSummary.expenseDistribution(transactions);

    final recent = transactions;
    final recentCapped = recent.take(10).toList();

    final emergencyGoal =
        _goals.where((g) => g.id == 'goal_emergency_fund').firstOrNull;

    return Scaffold(
      drawer: LoahDrawer(currentIndex: nav.currentIndex, onNavigate: nav.navigateTo),
      appBar: LoahAppBar(
        title: 'Loah',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    TotalBalanceCard(total: total, income: income, expense: expense),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: 150,
                            child: _FinanceEntryCard(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Contas',
                              value: CurrencyFormatter.format(total),
                              onTap: _openAccounts,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: _FinanceEntryCard(
                              icon: Icons.account_balance_outlined,
                              label: 'Patrimônio',
                              value: CurrencyFormatter.format(
                                _assets.fold<double>(0, (sum, a) => sum + a.currentValue),
                              ),
                              onTap: _openAssets,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: _FinanceEntryCard(
                              icon: Icons.pie_chart_outline,
                              label: 'Orçamento',
                              value:
                                  '${CurrencyFormatter.format(BudgetSummary.totalSpent(_budgets, transactions))} '
                                  'de ${CurrencyFormatter.format(BudgetSummary.totalBudgeted(_budgets))}',
                              onTap: _openBudgets,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: _FinanceEntryCard(
                              icon: Icons.autorenew,
                              label: 'Recorrentes',
                              value: '${_recurring.where((r) => r.active).length} ativas',
                              onTap: _openRecurring,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: _FinanceEntryCard(
                              icon: Icons.bar_chart_outlined,
                              label: 'Relatórios',
                              value: 'Ver evolução',
                              onTap: _openReports,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (emergencyGoal != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      EmergencyGoalCard(
                        target: emergencyGoal.target ?? 0,
                        progress: GoalProgress.of(emergencyGoal, _tasks),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    if (distribution.isEmpty)
                      _EmptyDistributionHint(colors: colors)
                    else
                    ExpenseDistributionCard(
                        categories: distribution,
                        onDetails: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ExpenseDistributionDetailScreen()),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    SectionHeader(
                      title: 'Transações Recentes',
                      trailing: Icon(Icons.filter_list, color: colors.accentBlue, size: 18),
                    ),
                    const SizedBox(height: 10),
                    if (recentCapped.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Nenhuma transação ainda. Toque no + para adicionar a primeira.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      for (final t in recentCapped) ...[
                        TransactionListItem(transaction: t, onTap: () => _editTransaction(t)),
                        const SizedBox(height: AppSpacing.sm),
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
                      child: const Text('VER TODO O HISTÓRICO'),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary ,
        heroTag: 'finances_fab',
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyDistributionHint extends StatelessWidget {
  final LoahColors colors;
  const _EmptyDistributionHint({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        'Nenhuma despesa registrada este mês ainda — a distribuição de '
        'gastos aparece aqui assim que você adicionar transações.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Compact tappable card used for both the "Contas" and "Patrimônio"
/// quick-link entries — icon, label, value, chevron.
class _FinanceEntryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _FinanceEntryCard({
    required this.icon,
    required this.label,
    required this.value,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: colors.accentBlue),
                  const Spacer(),
                  Icon(Icons.chevron_right, size: 16, color: context.textSecondary),
                ],
              ),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
