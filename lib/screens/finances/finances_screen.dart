import 'package:flutter/material.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/mock/account_balance.dart';
import '../../core/mock/budget_summary.dart';
import '../../core/mock/finance_summary.dart';
import '../../core/mock/goal_progress.dart';
import '../../core/mock/mock_data.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/transaction_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_drawer.dart';
import '../../widgets/section_header.dart';
import 'accounts_screen.dart';
import 'add_transaction_screen.dart';
import 'assets_screen.dart';
import 'budgets_screen.dart';
import '../../core/mock/recurring_engine.dart';
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
/// All figures are derived live from [MockData.transactions] and
/// [MockData.accounts] — nothing here is a hardcoded number anymore.
class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  @override
  void initState() {
    super.initState();
    // Turns any due salary/rent/subscription into a real transaction —
    // safe to call every time the screen loads, since RecurringEngine
    // stamps each item with the month it already generated for.
    RecurringEngine.processDue(MockData.recurringTransactions, MockData.transactions);
  }

  Future<void> _addTransaction() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    setState(() {});
  }

  Future<void> _editTransaction(TransactionModel transaction) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(existingTransaction: transaction),
      ),
    );
    setState(() {});
  }

  Future<void> _openAssets() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AssetsScreen()),
    );
    setState(() {});
  }

  Future<void> _openAccounts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountsScreen()),
    );
    setState(() {});
  }

  Future<void> _openBudgets() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BudgetsScreen()),
    );
    setState(() {});
  }

  Future<void> _openRecurring() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RecurringTransactionsScreen()),
    );
    setState(() {});
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

    final transactions = MockData.transactions;
    final accounts = MockData.accounts;

    // "Saldo total" is now the sum of every account's live balance
    // (initial balance + its linked transactions) rather than a raw
    // sum of all transactions — this correctly accounts for money that
    // was already in an account before Loah started tracking it.
    final total = AccountBalance.totalOf(accounts, transactions);
    final income = FinanceSummary.monthlyIncome(transactions);
    final expense = FinanceSummary.monthlyExpense(transactions);
    final distribution = FinanceSummary.expenseDistribution(transactions);

    // Recent transactions, most recent first, capped to keep the
    // a full paginated list would live once we have more entries.
    final recent = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    final recentCapped = recent.take(10).toList();

    // Reuses the same "Reserva de Emergência" goal already tracked on
    // the Metas screen, so the two screens never disagree with each other.
    final emergencyGoal =
        MockData.goals.where((g) => g.id == 'goal_emergency_fund').firstOrNull;

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
                        MockData.assets.fold<double>(0, (sum, a) => sum + a.currentValue),
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
                          '${CurrencyFormatter.format(BudgetSummary.totalSpent(MockData.budgets, transactions))} '
                          'de ${CurrencyFormatter.format(BudgetSummary.totalBudgeted(MockData.budgets))}',
                      onTap: _openBudgets,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 150,
                    child: _FinanceEntryCard(
                      icon: Icons.autorenew,
                      label: 'Recorrentes',
                      value: '${MockData.recurringTransactions.where((r) => r.active).length} ativas',
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
                progress: GoalProgress.of(emergencyGoal, MockData.tasks),
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
                setState(() {});
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