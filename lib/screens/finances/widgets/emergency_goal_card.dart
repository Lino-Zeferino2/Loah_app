import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/labeled_progress_bar.dart';

/// Highlighted "META: RESERVA DE EMERGÊNCIA" card with a tinted
/// background, shown below the total balance on the Finanças screen.
class EmergencyGoalCard extends StatelessWidget {
  final double target;
  final double progress;

  const EmergencyGoalCard({
    super.key,
    required this.target,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.accentBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.accentBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'META: RESERVA DE EMERGÊNCIA',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.accentBlue,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 8),
          LabeledProgressBar(progress: progress, color: colors.accentBlue),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).round()}% concluído • Falta R\$ ${(target * (1 - progress)).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
