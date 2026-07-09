import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/transaction_model.dart';
import '../../../widgets/loah_card.dart';

/// One card in the "Transações Recentes" list: icon, title/subtitle and
/// a signed, color-coded amount. Each transaction is its own bordered
/// card, matching the reference design.
class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final amountColor = transaction.isIncome ? colors.positive : colors.negative;
    final sign = transaction.isIncome ? '+ ' : '- ';

    return LoahCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: amountColor.withValues(alpha: 0.12),
            child: Icon(transaction.icon, size: 18, color: amountColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(transaction.subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '$sign${CurrencyFormatter.format(transaction.amount)}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}