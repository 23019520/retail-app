/// Design tokens for the BrightDev Store — clean white light theme.
/// Every visual decision flows from here — nothing is hardcoded elsewhere.
library app_tokens;

import 'package:flutter/material.dart';

// ── Palette ──────────────────────────────────────────────────────────────────

class _Palette {
  _Palette._();

  // Backgrounds
  static const base     = Color(0xFFFFFFFF); // scaffold — pure white
  static const surface  = Color(0xFFF7F8FA); // cards — very light grey
  static const elevated = Color(0xFFFFFFFF); // dialogs, sheets
  static const border   = Color(0xFFE4E7EC); // dividers, outlines

  // Text
  static const textPrimary   = Color(0xFF0F1117); // near-black
  static const textSecondary = Color(0xFF4B5263); // mid-grey
  static const textMuted     = Color(0xFF9299A6); // light grey

  // Accents — unchanged
  static const sageTeal      = Color(0xFF5FAE8C);
  static const sageTealLight = Color(0xFF9FE6C6);
  static const amber         = Color(0xFFD4952A); // slightly richer on white

  // Condition grades — unchanged
  static const gradeNew       = Color(0xFF2E9E6A);
  static const gradeExcellent = Color(0xFF5FAE8C);
  static const gradeGood      = Color(0xFFD4952A);
  static const gradeFair      = Color(0xFFC0623A);

  // Utility
  static const error   = Color(0xFFD93025);
  static const success = Color(0xFF5FAE8C);
}

/// Semantic colour aliases — reference this class throughout the app.
class AppColors {
  AppColors._();

  static const backgroundBase  = _Palette.base;
  static const backgroundCard  = _Palette.surface;
  static const backgroundSheet = _Palette.elevated;
  static const divider         = _Palette.border;

  static const textPrimary   = _Palette.textPrimary;
  static const textSecondary = _Palette.textSecondary;
  static const textMuted     = _Palette.textMuted;

  static const primary      = _Palette.sageTeal;
  static const primaryLight = _Palette.sageTealLight;
  static const secondary    = _Palette.amber;

  static const error   = _Palette.error;
  static const success = _Palette.success;

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
      case ConditionGrade.likeNew:   return 'Like New';
      case ConditionGrade.excellent: return 'Excellent';
      case ConditionGrade.good:      return 'Good';
      case ConditionGrade.fair:      return 'Fair';
    }
  }

  Color get color {
    switch (this) {
      case ConditionGrade.likeNew:   return AppColors.gradeNew;
      case ConditionGrade.excellent: return AppColors.gradeExcellent;
      case ConditionGrade.good:      return AppColors.gradeGood;
      case ConditionGrade.fair:      return AppColors.gradeFair;
    }
  }

  double get meterValue {
    switch (this) {
      case ConditionGrade.likeNew:   return 1.0;
      case ConditionGrade.excellent: return 0.80;
      case ConditionGrade.good:      return 0.60;
      case ConditionGrade.fair:      return 0.35;
    }
  }
}

// ── Spacing ───────────────────────────────────────────────────────────────────

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

// ── Elevation ─────────────────────────────────────────────────────────────────

class AppElevation {
  AppElevation._();

  static List<BoxShadow> cardGlow({Color? color, double intensity = 0.08}) => [
    BoxShadow(
      color: (color ?? AppColors.primary).withValues(alpha: intensity),
      blurRadius: 16,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> sheetGlow() => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, -4),
    ),
  ];
}

// ── Motion ────────────────────────────────────────────────────────────────────

class AppMotion {
  AppMotion._();

  static const Duration micro    = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration page     = Duration(milliseconds: 320);
  static const Duration shimmer  = Duration(milliseconds: 1400);

  static const Curve easeStandard = Curves.easeInOutCubic;
  static const Curve easeEnter    = Curves.easeOutCubic;
  static const Curve easeExit     = Curves.easeInCubic;
  static const Curve spring       = Curves.elasticOut;

  static const double pressedScale = 0.96;
}