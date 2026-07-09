import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/loah_card.dart';

/// "SALDO TOTAL" card with income/expense pills, shown at the top of
/// the Finanças screen.
class TotalBalanceCard extends StatelessWidget {
  final double total;
  final double income;
  final double expense;

  const TotalBalanceCard({
    super.key,
    required this.total,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return LoahCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SALDO TOTAL',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(total),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Pill(
                icon: Icons.arrow_upward_rounded,
                label: 'RECEITAS',
                value: CurrencyFormatter.format(income),
                color: colors.positive,
              ),
              const SizedBox(width: 10),
              _Pill(
                icon: Icons.arrow_downward_rounded,
                label: 'DESPESAS',
                value: CurrencyFormatter.format(expense),
                color: colors.negative,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Pill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
