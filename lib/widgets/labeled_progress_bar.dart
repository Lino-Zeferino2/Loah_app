import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// A thin rounded progress bar with an optional label row above it,
/// e.g. "Reserva de Emergência ................ 68%".
class LabeledProgressBar extends StatelessWidget {
  final String? label;
  final double progress; // 0..1
  final Color? color;
  final Color? backgroundColor;
  final double height;

  const LabeledProgressBar({
    super.key,
    this.label,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final barColor = color ?? colors.accentBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: Theme.of(context).textTheme.bodySmall),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: height,
            backgroundColor: backgroundColor ?? colors.cardBackgroundAlt,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
      ],
    );
  }
}
