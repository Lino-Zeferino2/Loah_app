import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Compact pill switch showing a moon and a sun icon; the active side
/// is highlighted depending on [isDark].
class ThemeToggleSwitch extends StatelessWidget {
  final bool isDark;
  final VoidCallback onChanged;

  const ThemeToggleSwitch({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return GestureDetector(
      onTap: onChanged,
      child: Container(
        width: 64,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colors.cardBackgroundAlt,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: isDark ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: colors.accentBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.dark_mode_rounded,
                  size: 15,
                  color: isDark ? Colors.white : context.textSecondary,
                ),
                Icon(
                  Icons.light_mode_rounded,
                  size: 15,
                  color: !isDark ? Colors.white : context.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
