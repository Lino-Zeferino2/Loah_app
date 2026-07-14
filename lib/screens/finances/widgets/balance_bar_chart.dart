import 'package:flutter/material.dart';
import '../../../core/mock/report_summary.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

/// A simple vertical bar chart for [MonthlyBalancePoint]s — each bar's
/// height is proportional to its value relative to the tallest bar in
/// the set. Built with plain `Column`/`Container` sizing (no
/// `CustomPainter`, no charting dependency) since a handful of bars
/// don't need anything fancier.
class BalanceBarChart extends StatelessWidget {
  final List<MonthlyBalancePoint> points;
  final double height;

  const BalanceBarChart({super.key, required this.points, this.height = 140});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    if (points.isEmpty) return const SizedBox.shrink();

    final maxValue = points.map((p) => p.balance.abs()).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1.0 : maxValue;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final point in points)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _compactValue(point.balance),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      child: Container(
                        height: (height - 46) * (point.balance.abs() / safeMax).clamp(0.04, 1.0),
                        color: point.balance < 0 ? colors.negative : colors.accentBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(point.label, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Compact form for the tiny label above each bar, e.g. "R$ 4,2k".
  String _compactValue(double value) {
    if (value.abs() >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}k';
    }
    return CurrencyFormatter.format(value);
  }
}