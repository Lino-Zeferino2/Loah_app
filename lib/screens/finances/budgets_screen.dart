import 'package:flutter/material.dart';
import '../../core/mock/budget_summary.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/budget_model.dart';
import '../../widgets/labeled_progress_bar.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import 'add_budget_screen.dart';
import 'widgets/budget_card.dart';

/// "Loah - Orçamento": a monthly spending limit per expense category,
/// compared against what's actually been spent this month.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  Future<void> _addBudget() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
    );
    setState(() {});
  }

  Future<void> _editBudget(BudgetModel budget) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddBudgetScreen(existingBudget: budget)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final budgets = MockData.budgets;
    final transactions = MockData.transactions;
    final progressList = BudgetSummary.all(budgets, transactions);
    final totalBudgeted = BudgetSummary.totalBudgeted(budgets);
    final totalSpent = BudgetSummary.totalSpent(budgets, transactions);
    final overallProgress = totalBudgeted == 0 ? 0.0 : (totalSpent / totalBudgeted).clamp(0, 1);

    return Scaffold(
      appBar: const LoahAppBarSimple(title: 'Orçamento'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LoahCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GASTO DO MÊS (CATEGORIAS ORÇADAS)',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.4,
                          color: context.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${CurrencyFormatter.format(totalSpent)} de ${CurrencyFormatter.format(totalBudgeted)}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  LabeledProgressBar(
                    progress: overallProgress.toDouble(),
                    color: overallProgress >= 1
                        ? colors.negative
                        : overallProgress >= 0.8
                            ? Colors.orange
                            : colors.positive,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (progressList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Nenhum orçamento definido ainda. Toque no + para criar o primeiro.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              for (final progress in progressList) ...[
                BudgetCard(progress: progress, onTap: () => _editBudget(progress.budget)),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'budgets_fab',
        onPressed: _addBudget,
        child: const Icon(Icons.add),
      ),
    );
  }
}