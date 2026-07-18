import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
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
    final colors = context.loahColors;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Usa cor do tema conforme modo (dark/light).
    final backgroundColor =
        isDark ? colors.cardBackgroundAlt : colors.cardBackground;

    return Container(
      height: 210,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.12,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      color:  isDark ? Colors.white70: Colors.black87, size: 16,fontWeight: FontWeight.bold),
                const  SizedBox(width: 6),
                  Text('Finanças',
                      style: TextStyle(color:  isDark ? Colors.white70: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
               Icon(Icons.more_horiz, color:  isDark ? Colors.white70: Colors.black87, size: 18),
            ],
          ),
          const SizedBox(height: 8),
           Text('SALDO DISPONÍVEL',
              style: TextStyle(
                  color:   isDark ? Colors.white70: Colors.black87,
                  fontSize: 11,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(available),
            style:  TextStyle(
              color:  isDark ? Colors.white70: Colors.black87,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          LabeledProgressBar(
            progress: progressToGoal,
           color:  isDark ? Colors.white70: Colors.black87,
            backgroundColor: Colors.white24,
          ),
          const SizedBox(height: 4),
          Text(
            '${(progressToGoal * 100).round()}% da meta mensal',
            style:  TextStyle(color:  isDark ? Colors.white70: Colors.black87, fontSize: 11),
          ),
        ],
      ),
    );
  }
}