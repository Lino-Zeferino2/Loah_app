import 'package:flutter/material.dart';
import '../core/constants/app_spacing.dart';
import '../core/theme/app_theme.dart';

/// Base surface container: consistent radius, border and padding for
/// every "card" seen across the four screens.
class LoahCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  const LoahCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return Material(
      color: color ?? colors.cardBackground,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}
