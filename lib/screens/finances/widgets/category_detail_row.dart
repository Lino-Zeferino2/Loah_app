import 'package:flutter/material.dart';
import '../../../core/mock/transaction_categories.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction_model.dart';
import '../../../widgets/labeled_progress_bar.dart';
import '../../../widgets/loah_card.dart';

/// One row in "Detalhamento por Categoria": icon, name, "X% do total",
/// the amount, and a colored progress bar showing that category's
/// share of the month's total spend.
class CategoryDetailRow extends StatelessWidget {
  final ExpenseCategoryModel category;
  final double totalSpend;

  const CategoryDetailRow({super.key, required this.category, required this.totalSpend});

  @override
  Widget build(BuildContext context) {
    final share = totalSpend == 0 ? 0.0 : (category.amount / totalSpend).clamp(0, 1);
    final icon = TransactionCategories.iconFor(category.label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LoahCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: category.color.withValues(alpha: 0.15),
                  child: Icon(icon, size: 18, color: category.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        '${(share * 100).round()}% do total',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(category.amount),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LabeledProgressBar(progress: share.toDouble(), color: category.color),
          ],
        ),
      ),
    );
  }
}
