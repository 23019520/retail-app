/// Central theme definition — clean white light theme.
library app_theme;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';
import 'theme_extensions.dart';

export 'app_tokens.dart';
export 'theme_extensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build();
  static ThemeData dark()  => _build(); // app is now light-only

  static ColorScheme get _colorScheme => const ColorScheme(
    brightness: Brightness.light,

    // Surfaces
    surface:                   AppColors.backgroundCard,
    surfaceContainerLowest:    Color(0xFFFFFFFF),
    surfaceContainerLow:       AppColors.backgroundBase,
    surfaceContainer:          AppColors.backgroundCard,
    surfaceContainerHigh:      Color(0xFFEFF1F4),
    surfaceContainerHighest:   Color(0xFFE8EBF0),

    // Primary — sage-teal
    primary:              AppColors.primary,
    onPrimary:            Color(0xFFFFFFFF),
    primaryContainer:     Color(0xFFD4F0E4),
    onPrimaryContainer:   Color(0xFF0A3D25),

    // Secondary — amber
    secondary:            AppColors.secondary,
    onSecondary:          Color(0xFFFFFFFF),
    secondaryContainer:   Color(0xFFF9EDD4),
    onSecondaryContainer: Color(0xFF3D2400),

    // Tertiary
    tertiary:             Color(0xFF4A90C4),
    onTertiary:           Color(0xFFFFFFFF),

    // Error
    error:                AppColors.error,
    onError:              Color(0xFFFFFFFF),
    errorContainer:       Color(0xFFFFDAD6),
    onErrorContainer:     Color(0xFF410002),

    // On-* tokens
    onSurface:            AppColors.textPrimary,
    onSurfaceVariant:     AppColors.textSecondary,
    outline:              AppColors.divider,
    outlineVariant:       Color(0xFFD0D5DC),

    // Scrim
    scrim:                Color(0x52000000),
    shadow:               Colors.black,
    inverseSurface:       Color(0xFF1F2228),
    onInverseSurface:     Color(0xFFF1F2F4),
    inversePrimary:       Color(0xFF9FE6C6),
  );

  static TextTheme get _textTheme {
    final base = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    return base.copyWith(
      displayLarge:  base.displayLarge?.copyWith(fontSize: 40, fontWeight: FontWeight.w700, height: 1.1,  letterSpacing: -1.5, color: AppColors.textPrimary),
      displayMedium: base.displayMedium?.copyWith(fontSize: 32, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -1.0, color: AppColors.textPrimary),
      displaySmall:  base.displaySmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w600, height: 1.2,  letterSpacing: -0.5, color: AppColors.textPrimary),

      headlineLarge:  base.headlineLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3, color: AppColors.textPrimary),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3,  letterSpacing: -0.2, color: AppColors.textPrimary),
      headlineSmall:  base.headlineSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3,  color: AppColors.textPrimary),

      titleLarge:  base.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.textPrimary),
      titleMedium: base.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4,  color: AppColors.textPrimary),
      titleSmall:  base.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4,  color: AppColors.textPrimary),

      bodyLarge:   base.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.55, color: AppColors.textSecondary),
      bodyMedium:  base.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.55, color: AppColors.textSecondary),
      bodySmall:   base.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.55, color: AppColors.textMuted),

      labelLarge:  base.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: AppColors.textPrimary),
      labelMedium: base.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: AppColors.textSecondary),
      labelSmall:  base.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: AppColors.textMuted),
    );
  }

  static ThemeData _build() {
    final cs = _colorScheme;
    final tt = _textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: tt,
      scaffoldBackgroundColor: AppColors.backgroundBase,
      canvasColor: AppColors.backgroundCard,
      dividerColor: AppColors.divider,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundBase,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.divider,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // dark icons on white
        titleTextStyle: tt.titleLarge?.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Filled Button ──────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: tt.labelLarge
              ?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: tt.labelLarge
              ?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle:
              tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),

      // ── Input Decoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: tt.bodyMedium?.copyWith(color: AppColors.textMuted),
        labelStyle:
            tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle:
            tt.labelMedium?.copyWith(color: AppColors.primary),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        errorStyle: tt.bodySmall?.copyWith(color: AppColors.error),
      ),

      // ── Navigation Bar ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        shadowColor: AppColors.divider,
        elevation: 1,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 22);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          );
        }),
        surfaceTintColor: Colors.transparent,
        height: 72,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
        space: 1,
      ),

      // ── Tab Bar ───────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        labelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F2F5),
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        checkmarkColor: AppColors.primary,
        labelStyle: tt.labelMedium,
        side: const BorderSide(color: AppColors.divider, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        elevation: 0,
        modalElevation: 8,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        titleTextStyle: tt.titleLarge,
        contentTextStyle: tt.bodyMedium,
        elevation: 4,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle:
            tt.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return AppColors.primary;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return AppColors.primary.withValues(alpha: 0.35);
          return const Color(0xFFD0D5DC);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return Colors.transparent;
          return const Color(0xFFB0B7C3);
        }),
      ),

      // ── List Tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: tt.bodyMedium?.copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        subtitleTextStyle:
            tt.bodySmall?.copyWith(color: AppColors.textMuted),
        iconColor: AppColors.textMuted,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
      ),

      // ── Icon ─────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
          color: AppColors.textSecondary, size: 22),

      // ── Theme Extensions ──────────────────────────────────────────────────
      extensions: const [
        AppConditionTheme.defaultTheme,
        AppElevationTheme.defaultTheme,
        AppSpacingTheme.defaultTheme,
        AppRadiusTheme.defaultTheme,
      ],
    );
  }
}