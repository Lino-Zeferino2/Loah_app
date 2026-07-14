import 'package:flutter/material.dart';
import '../../../core/mock/report_summary.dart';
import '../../../core/mock/transaction_categories.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

/// One row comparing a category's spend this month vs. last month:
/// icon, category name, two mini bars (current vs previous) and a
/// colored delta ("+12%" in red if spending more, green if less).
class CategoryComparisonRow extends StatelessWidget {
  final CategoryComparison comparison;

  const CategoryComparisonRow({super.key, required this.comparison});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final icon = TransactionCategories.iconFor(comparison.category);
    final categoryColor = TransactionCategories.colorFor(comparison.category);

    // Spending MORE than last month is "bad" (red); spending LESS is
    // "good" (green) — the inverse of how gains usually read.
    final isWorse = comparison.delta > 0;
    final deltaColor = comparison.deltaPercent == null
        ? context.textSecondary
        : (isWorse ? colors.negative : colors.positive);

    final maxValue = comparison.current > comparison.previous ? comparison.current : comparison.previous;
    final safeMax = maxValue == 0 ? 1.0 : maxValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: categoryColor.withValues(alpha: 0.15),
            child: Icon(icon, size: 16, color: categoryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(comparison.category, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (comparison.deltaPercent != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isWorse ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 12,
                            color: deltaColor,
                          ),
                          Text(
                            '${comparison.deltaPercent!.abs().toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: deltaColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                _MiniBar(
                  label: 'Este mês',
                  value: comparison.current,
                  fraction: comparison.current / safeMax,
                  color: categoryColor,
                ),
                const SizedBox(height: 4),
                _MiniBar(
                  label: 'Mês anterior',
                  value: comparison.previous,
                  fraction: comparison.previous / safeMax,
                  color: categoryColor.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final double fraction;
  final Color color;

  const _MiniBar({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction.clamp(0, 1),
              minHeight: 6,
              backgroundColor: colors.cardBackgroundAlt,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(
            CurrencyFormatter.format(value),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}