import 'package:flutter/material.dart';

/// Default color palette.
/// In production these are overridden per business from BusinessModel.
/// Usage: Theme.of(context).colorScheme — don't reference AppColors directly in widgets.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1A1A2E);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFFE94560);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color tertiary = Color(0xFF0F3460);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Surface
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF0F0F0);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onBackground = Color(0xFF1C1B1F);

  // Status
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color info = Color(0xFF0288D1);

  // Neutral
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey900 = Color(0xFF212121);

  // Order status colors
  static const Color statusPending = Color(0xFFF57F17);
  static const Color statusConfirmed = Color(0xFF0288D1);
  static const Color statusPreparing = Color(0xFF7B1FA2);
  static const Color statusReady = Color(0xFF00897B);
  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusCancelled = Color(0xFFB00020);

  /// Build a ColorScheme from brand colors.
  /// Call this in AppTheme to support dynamic business theming.
  static ColorScheme buildColorScheme({
    Color? primaryColor,
    Color? secondaryColor,
    Brightness brightness = Brightness.light,
  }) {
    return ColorScheme.fromSeed(
      seedColor: primaryColor ?? primary,
      secondary: secondaryColor ?? secondary,
      brightness: brightness,
    );
  }
}
