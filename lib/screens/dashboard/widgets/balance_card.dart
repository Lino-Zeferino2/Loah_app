import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/labeled_progress_bar.dart';

/// "Finanças / SALDO DISPONÍVEL / R$ 4.820,50" card with the monthly
/// goal progress bar, shown at the top of the Dashboard.
///
/// Uses a plain [Container] (not [LoahCard]) so its blue background is
/// always painted exactly as given — independent of theme/brightness.
class BalanceCard extends StatelessWidget {
  final double available;
  final double progressToGoal;

  const BalanceCard({
    super.key,
    required this.available,
    required this.progressToGoal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Distinct blue tones per theme: a deep navy for dark mode (blends
    // with the dark surfaces around it) and a vivid, brighter blue for
    // light mode (stands out against the light background).
    final backgroundColor =
        isDark ?  const Color.fromARGB(255, 39, 151, 199) :const Color.fromARGB(255, 39, 151, 199);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const   Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.white70, size: 16),
                  SizedBox(width: 6),
                  Text('Finanças',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
               Icon(Icons.more_horiz, color: Colors.white70, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          const Text('SALDO DISPONÍVEL',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(available),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          LabeledProgressBar(
            progress: progressToGoal,
            color: Colors.white,
            backgroundColor: Colors.white24,
          ),
          const SizedBox(height: 4),
          Text(
            '${(progressToGoal * 100).round()}% da meta mensal',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}