import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction_model.dart';
import '../../../widgets/loah_card.dart';
import '../../../widgets/section_header.dart';
import 'donut_chart.dart';

/// "Distribuição de Gastos" card: a vertical legend (dot + category +
/// amount, with a thin proportional bar) followed by a donut chart with
/// the total centered inside it.
class ExpenseDistributionCard extends StatelessWidget {
  final List<ExpenseCategoryModel> categories;
  final VoidCallback onDetails;

  const ExpenseDistributionCard({
    super.key,
    required this.categories,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final total = categories.fold<double>(0, (sum, c) => sum + c.amount);
    return LoahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Distribuição de Gastos',
            trailing: GestureDetector(
              onTap: onDetails,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('DETALHES', style: Theme.of(context).textTheme.labelSmall),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ),
          Text(
            'Este mês vs. Anterior',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          for (final c in categories) ...[
            _LegendRow(category: c, total: total),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 4),
          Center(
            child: DonutChart(
              categories: categories,
              size: 130,
              centerChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    CurrencyFormatter.format(total),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text('gasto total', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One legend row: colored dot + category name (top), a thin
/// proportional bar (bottom-left) and the formatted amount (top-right).
class _LegendRow extends StatelessWidget {
  final ExpenseCategoryModel category;
  final double total;

  const _LegendRow({required this.category, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final share = total == 0 ? 0.0 : (category.amount / total).clamp(0, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: category.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  category.label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
            Text(
              CurrencyFormatter.format(category.amount),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: share.toDouble(),
            minHeight: 5,
            backgroundColor: colors.cardBackgroundAlt,
            valueColor: AlwaysStoppedAnimation(category.color),
          ),
        ),
      ],
    );
  }
}
