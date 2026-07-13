import 'package:flutter/material.dart';
import '../../../core/mock/budget_summary.dart';
import '../../../core/mock/transaction_categories.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/labeled_progress_bar.dart';
import '../../../widgets/loah_card.dart';

/// One row in the Orçamento list: category icon, name, a colored
/// progress bar (green/orange/red depending on [BudgetStatus]), and
/// "R$ spent de R$ limit" — or an overshoot message if over budget.
class BudgetCard extends StatelessWidget {
  final BudgetProgress progress;
  final VoidCallback onTap;

  const BudgetCard({super.key, required this.progress, required this.onTap});

  Color _statusColor(BuildContext context) {
    final colors = context.loahColors;
    return switch (progress.status) {
      BudgetStatus.ok => colors.positive,
      BudgetStatus.near => Colors.orange,
      BudgetStatus.over => colors.negative,
    };
  }

  @override
  Widget build(BuildContext context) {
    final budget = progress.budget;
    final color = _statusColor(context);
    final icon = TransactionCategories.iconFor(budget.category);

    return LoahCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(budget.category, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              Text(
                '${(progress.progress * 100).round()}%',
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LabeledProgressBar(progress: progress.progress, color: color),
          const SizedBox(height: 6),
          Text(
            progress.isOverBudget
                ? '${CurrencyFormatter.format(progress.spent)} de ${CurrencyFormatter.format(budget.monthlyLimit)} — '
                    '${CurrencyFormatter.format(progress.spent - budget.monthlyLimit)} acima do limite'
                : '${CurrencyFormatter.format(progress.spent)} de ${CurrencyFormatter.format(budget.monthlyLimit)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: progress.isOverBudget ? color : null,
                  fontWeight: progress.isOverBudget ? FontWeight.w600 : null,
                ),
          ),
        ],
      ),
    );
  }
}