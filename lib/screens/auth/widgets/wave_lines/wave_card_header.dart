import 'package:flutter/material.dart';

import 'top_wave_clipper.dart';
import 'wave_lines_painter.dart';

class WaveCardHeader extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color lineColor;

  const WaveCardHeader({
    super.key,
    required this.child,
    required this.backgroundColor,
    this.lineColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: Stack(
        children: [
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              color: backgroundColor,
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: WaveLinesPainter(),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

