import 'package:flutter/material.dart';
import '../../../core/utils/report_summary.dart';
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

  /// Optional linear regression coefficients `[slope, intercept]` to
  /// draw a trend line overlay across the bars.
  final List<double>? trendLine;

  const BalanceBarChart({
    super.key,
    required this.points,
    this.height = 140,
    this.trendLine,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    if (points.isEmpty) return const SizedBox.shrink();

    final maxValue = points.map((p) => p.balance.abs()).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1.0 : maxValue;
    final barAreaHeight = height - 46;

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: trendLine != null && trendLine!.length >= 2
            ? _TrendLinePainter(
                points: points,
                trendLine: trendLine!,
                barAreaHeight: barAreaHeight,
                safeMax: safeMax,
                trendColor: colors.accentBlue.withValues(alpha: 0.6),
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < points.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _compactValue(points[i].balance, context),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        child: Container(
                          height: barAreaHeight * (points[i].balance.abs() / safeMax).clamp(0.04, 1.0),
                          color: points[i].balance < 0 ? colors.negative : colors.accentBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(points[i].label, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Compact form for the tiny label above each bar, e.g. "€ 4,2k".
  String _compactValue(double value, BuildContext context) {
    if (value.abs() >= 1000) {
      return '${CurrencyFormatter.symbol(context: context)} ${(value / 1000).toStringAsFixed(1)}k';
    }
    return CurrencyFormatter.format(value);
  }
}

/// Paints a dashed trend line across the bar chart area.
class _TrendLinePainter extends CustomPainter {
  final List<MonthlyBalancePoint> points;
  final List<double> trendLine;
  final double barAreaHeight;
  final double safeMax;
  final Color trendColor;

  _TrendLinePainter({
    required this.points,
    required this.trendLine,
    required this.barAreaHeight,
    required this.safeMax,
    required this.trendColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final slope = trendLine[0];
    final intercept = trendLine[1];
    final n = points.length;

    // Calculate y-values of the trend line at each x position
    final trendValues = List.generate(n, (i) => slope * i + intercept);

    // Map to pixel coordinates
    final pixels = <Offset>[];
    for (var i = 0; i < n; i++) {
      final x = size.width * (i + 0.5) / n;
      // Map the trend value to pixel height (same scale as bars)
      final normalized = (trendValues[i].abs() / safeMax).clamp(0.0, 1.0);
      final y = barAreaHeight * (1 - normalized) + (size.height - barAreaHeight);
      pixels.add(Offset(x, y));
    }

    // Draw dashed line
    final paint = Paint()
      ..color = trendColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const dashWidth = 6.0;
    const dashGap = 4.0;

    for (var i = 0; i < pixels.length - 1; i++) {
      final start = pixels[i];
      final end = pixels[i + 1];
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final distance = (dx * dx + dy * dy).clamp(0.0001, double.infinity);
      final totalLength = distance; // keep as double

      var drawnLength = 0.0;
      while (drawnLength < totalLength) {
        final tStart = drawnLength / totalLength;
        final tEnd = (drawnLength + dashWidth) / totalLength;
        final segStart = Offset(
          start.dx + dx * tStart,
          start.dy + dy * tStart,
        );
        final segEnd = Offset(
          start.dx + dx * (tEnd.clamp(0.0, 1.0)),
          start.dy + dy * (tEnd.clamp(0.0, 1.0)),
        );
        canvas.drawLine(segStart, segEnd, paint);
        drawnLength += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) =>
      oldDelegate.trendLine != trendLine || oldDelegate.points != points;
}
