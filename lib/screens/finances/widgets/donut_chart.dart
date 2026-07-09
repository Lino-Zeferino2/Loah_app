import 'package:flutter/material.dart';
import '../../../models/transaction_model.dart';

/// Lightweight donut chart rendered with a [CustomPainter] — avoids
/// pulling in a heavy charting dependency for a single simple visual.
class DonutChart extends StatelessWidget {
  final List<ExpenseCategoryModel> categories;
  final double size;
  final Widget? centerChild;

  const DonutChart({
    super.key,
    required this.categories,
    this.size = 110,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(categories),
          ),
          if (centerChild != null) centerChild!,
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<ExpenseCategoryModel> categories;
  _DonutPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final total = categories.fold<double>(0, (sum, c) => sum + c.amount);
    if (total <= 0) return;

    final strokeWidth = size.width * 0.16;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    var startAngle = -1.5708; // -90deg, start at top
    for (final category in categories) {
      final sweep = (category.amount / total) * 6.28319;
      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.categories != categories;
}
