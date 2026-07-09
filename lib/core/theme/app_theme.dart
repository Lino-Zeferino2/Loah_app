import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Custom design tokens that don't map cleanly onto [ThemeData] fields
/// (e.g. "card" surface vs "scaffold" surface, positive/negative amounts).
/// Exposed via `Theme.of(context).extension<LoahColors>()`.
class LoahColors extends ThemeExtension<LoahColors> {
  final Color cardBackground;
  final Color cardBackgroundAlt;
  final Color border;
  final Color positive;
  final Color negative;
  final Color accentBlue;

  const LoahColors({
    required this.cardBackground,
    required this.cardBackgroundAlt,
    required this.border,
    required this.positive,
    required this.negative,
    required this.accentBlue,
  });

  static const light = LoahColors(
    cardBackground: AppColors.lightSurface,
    cardBackgroundAlt: AppColors.lightSurfaceAlt,
    border: AppColors.lightBorder,
    positive: AppColors.success,
    negative: AppColors.danger,
    accentBlue: AppColors.primary,
  );

  static const dark = LoahColors(
    cardBackground: AppColors.darkSurface,
    cardBackgroundAlt: AppColors.darkSurfaceAlt,
    border: AppColors.darkBorder,
    positive: AppColors.success,
    negative: AppColors.danger,
    accentBlue: AppColors.primaryLight,
  );

  @override
  LoahColors copyWith({
    Color? cardBackground,
    Color? cardBackgroundAlt,
    Color? border,
    Color? positive,
    Color? negative,
    Color? accentBlue,
  }) {
    return LoahColors(
      cardBackground: cardBackground ?? this.cardBackground,
      cardBackgroundAlt: cardBackgroundAlt ?? this.cardBackgroundAlt,
      border: border ?? this.border,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      accentBlue: accentBlue ?? this.accentBlue,
    );
  }

  @override
  LoahColors lerp(ThemeExtension<LoahColors>? other, double t) {
    if (other is! LoahColors) return this;
    return LoahColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBackgroundAlt:
          Color.lerp(cardBackgroundAlt, other.cardBackgroundAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
    );
  }
}

/// Builds the light and dark [ThemeData] for the app.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: surface,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      iconTheme: IconThemeData(color: textSecondary),
      extensions: [isDark ? LoahColors.dark : LoahColors.light],
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
      ),
    );
  }
}

/// Convenience accessors so widgets can write
/// `context.loahColors.positive` instead of the verbose lookup.
extension LoahThemeContext on BuildContext {
  LoahColors get loahColors =>
      Theme.of(this).extension<LoahColors>() ?? LoahColors.dark;
  Color get textSecondary => Theme.of(this).brightness == Brightness.dark
      ? AppColors.darkTextSecondary
      : AppColors.lightTextSecondary;
}
