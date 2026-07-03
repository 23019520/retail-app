/// Custom ThemeExtensions.
/// Access via Theme.of(context).extension<AppConditionTheme>()!
library theme_extensions;

import 'package:flutter/material.dart';
import 'app_tokens.dart';

// ── Condition Theme ───────────────────────────────────────────────────────────

@immutable
class AppConditionTheme extends ThemeExtension<AppConditionTheme> {
  const AppConditionTheme({
    required this.likeNew,
    required this.excellent,
    required this.good,
    required this.fair,
  });

  final Color likeNew;
  final Color excellent;
  final Color good;
  final Color fair;

  static const defaultTheme = AppConditionTheme(
    likeNew:   AppColors.gradeNew,
    excellent: AppColors.gradeExcellent,
    good:      AppColors.gradeGood,
    fair:      AppColors.gradeFair,
  );

  Color forGrade(ConditionGrade grade) {
    switch (grade) {
      case ConditionGrade.likeNew:    return likeNew;
      case ConditionGrade.excellent:  return excellent;
      case ConditionGrade.good:       return good;
      case ConditionGrade.fair:       return fair;
    }
  }

  @override
  AppConditionTheme copyWith({
    Color? likeNew,
    Color? excellent,
    Color? good,
    Color? fair,
  }) {
    return AppConditionTheme(
      likeNew:   likeNew   ?? this.likeNew,
      excellent: excellent ?? this.excellent,
      good:      good      ?? this.good,
      fair:      fair      ?? this.fair,
    );
  }

  @override
  AppConditionTheme lerp(AppConditionTheme? other, double t) {
    if (other == null) return this;
    return AppConditionTheme(
      likeNew:   Color.lerp(likeNew,   other.likeNew,   t)!,
      excellent: Color.lerp(excellent, other.excellent, t)!,
      good:      Color.lerp(good,      other.good,      t)!,
      fair:      Color.lerp(fair,      other.fair,      t)!,
    );
  }
}

// ── Elevation Glow Theme ──────────────────────────────────────────────────────

@immutable
class AppElevationTheme extends ThemeExtension<AppElevationTheme> {
  const AppElevationTheme({
    required this.cardShadows,
    required this.sheetShadows,
    required this.primaryGlow,
  });

  final List<BoxShadow> cardShadows;
  final List<BoxShadow> sheetShadows;
  final List<BoxShadow> primaryGlow;

  static const defaultTheme = AppElevationTheme(
    cardShadows: [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
    sheetShadows: [
      BoxShadow(
        color: Color(0x80000000),
        blurRadius: 32,
        offset: Offset(0, -8),
      ),
    ],
    primaryGlow: [
      BoxShadow(
        color: Color(0x145FAE8C), // sageTeal @ 8%
        blurRadius: 24,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
  );

  @override
  AppElevationTheme copyWith({
    List<BoxShadow>? cardShadows,
    List<BoxShadow>? sheetShadows,
    List<BoxShadow>? primaryGlow,
  }) {
    return AppElevationTheme(
      cardShadows:  cardShadows  ?? this.cardShadows,
      sheetShadows: sheetShadows ?? this.sheetShadows,
      primaryGlow:  primaryGlow  ?? this.primaryGlow,
    );
  }

  @override
  AppElevationTheme lerp(AppElevationTheme? other, double t) => this;
}

// ── Spacing Theme ─────────────────────────────────────────────────────────────

@immutable
class AppSpacingTheme extends ThemeExtension<AppSpacingTheme> {
  const AppSpacingTheme({
    required this.xs,
    required this.sm,
    required this.md,
    required this.base,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  final double xs;
  final double sm;
  final double md;
  final double base;
  final double lg;
  final double xl;
  final double xxl;

  static const defaultTheme = AppSpacingTheme(
    xs:   AppSpacing.xs,
    sm:   AppSpacing.sm,
    md:   AppSpacing.md,
    base: AppSpacing.base,
    lg:   AppSpacing.lg,
    xl:   AppSpacing.xl,
    xxl:  AppSpacing.xxl,
  );

  @override
  AppSpacingTheme copyWith({
    double? xs, double? sm, double? md,
    double? base, double? lg, double? xl, double? xxl,
  }) {
    return AppSpacingTheme(
      xs:   xs   ?? this.xs,
      sm:   sm   ?? this.sm,
      md:   md   ?? this.md,
      base: base ?? this.base,
      lg:   lg   ?? this.lg,
      xl:   xl   ?? this.xl,
      xxl:  xxl  ?? this.xxl,
    );
  }

  @override
  AppSpacingTheme lerp(AppSpacingTheme? other, double t) => this;
}

// ── Radius Theme ──────────────────────────────────────────────────────────────

@immutable
class AppRadiusTheme extends ThemeExtension<AppRadiusTheme> {
  const AppRadiusTheme({
    required this.chip,
    required this.button,
    required this.card,
    required this.sheet,
  });

  final double chip;
  final double button;
  final double card;
  final double sheet;

  static const defaultTheme = AppRadiusTheme(
    chip:   AppRadius.chip,
    button: AppRadius.button,
    card:   AppRadius.card,
    sheet:  AppRadius.sheet,
  );

  @override
  AppRadiusTheme copyWith({
    double? chip, double? button, double? card, double? sheet,
  }) {
    return AppRadiusTheme(
      chip:   chip   ?? this.chip,
      button: button ?? this.button,
      card:   card   ?? this.card,
      sheet:  sheet  ?? this.sheet,
    );
  }

  @override
  AppRadiusTheme lerp(AppRadiusTheme? other, double t) => this;
}
