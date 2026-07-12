import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
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
import 'add_transaction_screen.dart';
import 'assets_screen.dart';
import 'widgets/emergency_goal_card.dart';
import 'widgets/expense_distribution_card.dart';
import 'widgets/total_balance_card.dart';
import 'widgets/transaction_list_item.dart';

/// "Loah - Finanças": total balance, emergency-fund goal, expense
/// distribution donut chart and recent transaction history.
///
/// All figures are derived live from [MockData.transactions] via
/// [FinanceSummary] — nothing here is a hardcoded number anymore.
class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
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

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final nav = LoahNavigationController.of(context);

    final transactions = MockData.transactions;
    final total = FinanceSummary.totalBalance(transactions);
    final income = FinanceSummary.monthlyIncome(transactions);
    final expense = FinanceSummary.monthlyExpense(transactions);
    final distribution = FinanceSummary.expenseDistribution(transactions);

    // Recent transactions, most recent first, capped to keep the
    // screen from growing unbounded — "VER TODO O HISTÓRICO" is where
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
            _PatrimonioEntryCard(onTap: _openAssets),
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
              ExpenseDistributionCard(categories: distribution, onDetails: () {}),
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
              onPressed: () {},
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

/// Compact tappable card summarizing net worth, linking into the full
/// [AssetsScreen] breakdown.
class _PatrimonioEntryCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PatrimonioEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final total = MockData.assets.fold<double>(0, (sum, a) => sum + a.currentValue);

    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.accentBlue.withValues(alpha: 0.15),
                child: Icon(Icons.account_balance_outlined, size: 18, color: colors.accentBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Patrimônio', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      CurrencyFormatter.format(total),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}