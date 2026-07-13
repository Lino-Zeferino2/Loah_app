import 'package:flutter/material.dart';
import '../../../core/mock/account_balance.dart';
import '../../../core/mock/account_visuals.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/account_model.dart';
import '../../../models/transaction_model.dart';
import '../../../widgets/loah_card.dart';

/// One row in the Contas list: type icon badge, name, and the live
/// balance (initial balance + linked transactions).
class AccountCard extends StatelessWidget {
  final AccountModel account;
  final List<TransactionModel> allTransactions;
  final VoidCallback onTap;

  const AccountCard({
    super.key,
    required this.account,
    required this.allTransactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = account.type.color;
    final balance = AccountBalance.of(account, allTransactions);

    return LoahCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(account.type.icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(account.type.label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(balance),
            style: TextStyle(
              color: balance < 0 ? context.loahColors.negative : color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18, color: context.textSecondary),
        ],
      ),
    );
  }
}