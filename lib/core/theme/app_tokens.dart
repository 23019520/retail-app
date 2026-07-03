/// Design tokens for the Laptops resale app.
/// Every visual decision flows from here — nothing is hardcoded elsewhere.
library app_tokens;

import 'package:flutter/material.dart';

// ── Palette ──────────────────────────────────────────────────────────────────

/// Raw colour swatches. Use [AppColors] for semantic names.
class _Palette {
  _Palette._();

  // Backgrounds
  static const base       = Color(0xFF16181C); // scaffold
  static const surface    = Color(0xFF1F2228); // cards
  static const elevated   = Color(0xFF282C33); // dialogs, sheets
  static const border     = Color(0xFF383C44); // dividers, outlines

  // Text
  static const textPrimary   = Color(0xFFF1F2F4);
  static const textSecondary = Color(0xFFA8ADB4);
  static const textMuted     = Color(0xFF7D838B);

  // Accents
  static const sageTeal      = Color(0xFF5FAE8C); // primary
  static const sageTealLight = Color(0xFF9FE6C6); // Like New badge
  static const amber         = Color(0xFFE0B25B); // ratings / Good grade

  // Condition grades
  static const gradeNew       = Color(0xFF9FE6C6);
  static const gradeExcellent = Color(0xFF5FAE8C);
  static const gradeGood      = Color(0xFFE0B25B);
  static const gradeFair      = Color(0xFFD08868);

  // Utility
  static const error   = Color(0xFFE05B5B);
  static const success = Color(0xFF5FAE8C);
}

/// Semantic colour aliases — reference this class throughout the app.
class AppColors {
  AppColors._();

  static const backgroundBase    = _Palette.base;
  static const backgroundCard    = _Palette.surface;
  static const backgroundSheet   = _Palette.elevated;
  static const divider           = _Palette.border;

  static const textPrimary   = _Palette.textPrimary;
  static const textSecondary = _Palette.textSecondary;
  static const textMuted     = _Palette.textMuted;

  static const primary       = _Palette.sageTeal;
  static const primaryLight  = _Palette.sageTealLight;
  static const secondary     = _Palette.amber;

  static const error         = _Palette.error;
  static const success       = _Palette.success;

  // Condition grade colours
  static const gradeNew       = _Palette.gradeNew;
  static const gradeExcellent = _Palette.gradeExcellent;
  static const gradeGood      = _Palette.gradeGood;
  static const gradeFair      = _Palette.gradeFair;
}

// ── Condition Grade ───────────────────────────────────────────────────────────

enum ConditionGrade { likeNew, excellent, good, fair }

extension ConditionGradeX on ConditionGrade {
  String get label {
    switch (this) {
      case ConditionGrade.likeNew:    return 'Like New';
      case ConditionGrade.excellent:  return 'Excellent';
      case ConditionGrade.good:       return 'Good';
      case ConditionGrade.fair:       return 'Fair';
    }
  }

  Color get color {
    switch (this) {
      case ConditionGrade.likeNew:    return AppColors.gradeNew;
      case ConditionGrade.excellent:  return AppColors.gradeExcellent;
      case ConditionGrade.good:       return AppColors.gradeGood;
      case ConditionGrade.fair:       return AppColors.gradeFair;
    }
  }

  /// 0.0 – 1.0 for the condition meter arc.
  double get meterValue {
    switch (this) {
      case ConditionGrade.likeNew:    return 1.0;
      case ConditionGrade.excellent:  return 0.80;
      case ConditionGrade.good:       return 0.60;
      case ConditionGrade.fair:       return 0.35;
    }
  }
}

// ── Spacing ───────────────────────────────────────────────────────────────────

/// 4px grid spacing scale.
class AppSpacing {
  AppSpacing._();

  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 24;
  static const double xl   = 32;
  static const double xxl  = 48;
  static const double xxxl = 64;
}

// ── Radius ────────────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static const double chip   = 8;
  static const double button = 12;
  static const double card   = 16;
  static const double sheet  = 24;
  static const double circle = 999;
}

// ── Elevation / Glow ─────────────────────────────────────────────────────────

class AppElevation {
  AppElevation._();

  /// Subtle inner-glow shadow used instead of drop shadows on dark surfaces.
  static List<BoxShadow> cardGlow({Color? color, double intensity = 0.08}) => [
    BoxShadow(
      color: (color ?? AppColors.primary).withValues(alpha: intensity),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> sheetGlow() => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 32,
      offset: const Offset(0, -8),
    ),
  ];
}

// ── Motion ────────────────────────────────────────────────────────────────────

class AppMotion {
  AppMotion._();

  static const Duration micro     = Duration(milliseconds: 180);
  static const Duration standard  = Duration(milliseconds: 280);
  static const Duration page      = Duration(milliseconds: 320);
  static const Duration shimmer   = Duration(milliseconds: 1400);

  static const Curve easeStandard = Curves.easeInOutCubic;
  static const Curve easeEnter    = Curves.easeOutCubic;
  static const Curve easeExit     = Curves.easeInCubic;
  static const Curve spring       = Curves.elasticOut;

  static const double pressedScale = 0.96;
}