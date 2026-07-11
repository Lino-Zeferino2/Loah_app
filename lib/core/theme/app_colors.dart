import 'package:flutter/material.dart';

/// Central color palette for the Loah app.
///
/// Colors are grouped by semantic purpose (not by theme) so that
/// [AppTheme] can pick the right shade per brightness. Keeping this
/// separate from [AppTheme] means designers/devs can tweak the palette
/// without touching ThemeData wiring.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color.fromARGB(255, 29, 77, 167); // Loah blue
  static const Color primaryLight = Color.fromARGB(255, 29, 77, 167);

  // Status / semantic
  static const Color success = Color(0xFF2ECC71);
  static const Color danger = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF5A623);
  static const Color info = Color(0xFF3D8BFD);

  // Category accents (used in charts / tags)
  static const Color foodAccent = Color(0xFF2ECC71);
  static const Color housingAccent = Color(0xFFF5A623);
  static const Color transportAccent = Color(0xFFE74C3C);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF1A1D24);
  static const Color darkSurfaceAlt = Color(0xFF20242C);
  static const Color darkBorder = Color(0xFF2A2E37);
  static const Color darkTextPrimary = Color(0xFFF5F6F8);
  static const Color darkTextSecondary = Color(0xFF9AA1AC);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF4F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color.fromARGB(255, 231, 232, 233);
  static const Color lightBorder = Color.fromARGB(255, 243, 244, 245);
  static const Color lightTextPrimary = Color(0xFF12151B);
  static const Color lightTextSecondary = Color(0xFF6B7280);
}
