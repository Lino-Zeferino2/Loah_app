import 'package:flutter/material.dart';
import '../../../core/mock/transaction_categories.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/recurring_transaction_model.dart';
import '../../../models/transaction_model.dart';
import '../../../widgets/loah_card.dart';

/// One row in the Recorrentes list: category icon, name, "Todo dia X"
/// caption, signed amount, and a switch to pause/resume it without
/// deleting.
class RecurringTransactionCard extends StatelessWidget {
  final RecurringTransactionModel recurring;
  final VoidCallback onTap;
  final ValueChanged<bool> onActiveChanged;

  const RecurringTransactionCard({
    super.key,
    required this.recurring,
    required this.onTap,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final isIncome = recurring.type == TransactionType.income;
    final amountColor = isIncome ? colors.positive : colors.negative;
    final icon = TransactionCategories.iconFor(recurring.category);

    return LoahCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: amountColor.withValues(alpha: 0.12),
            child: Icon(icon, size: 18, color: amountColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recurring.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  'Todo dia ${recurring.dayOfMonth}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+ ' : '- '}${CurrencyFormatter.format(recurring.amount)}',
                style: TextStyle(
                  color: recurring.active ? amountColor : context.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Switch(
                value: recurring.active,
                onChanged: onActiveChanged,
                activeTrackColor: colors.accentBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}