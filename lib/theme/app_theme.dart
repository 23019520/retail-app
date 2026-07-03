/// Central theme definition.
/// Import this file and pass [AppTheme.dark()] to [MaterialApp.theme].
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

  // ── ColorScheme ────────────────────────────────────────────────────────────

  static ColorScheme get _colorScheme => const ColorScheme(
    brightness: Brightness.dark,

    // Backgrounds / surfaces
    surface:              AppColors.backgroundCard,
    surfaceContainerLowest:  AppColors.backgroundBase,
    surfaceContainerLow:     AppColors.backgroundBase,
    surfaceContainer:        AppColors.backgroundCard,
    surfaceContainerHigh:    AppColors.backgroundSheet,
    surfaceContainerHighest: AppColors.backgroundSheet,

    // Primary (sage-teal)
    primary:        AppColors.primary,
    onPrimary:      Color(0xFF0E2419),
    primaryContainer:     Color(0xFF1B3D2C),
    onPrimaryContainer:   AppColors.primaryLight,

    // Secondary (amber)
    secondary:      AppColors.secondary,
    onSecondary:    Color(0xFF211500),
    secondaryContainer:   Color(0xFF3A2900),
    onSecondaryContainer: Color(0xFFFFDEA0),

    // Tertiary — unused but required
    tertiary:       Color(0xFF7EB2D4),
    onTertiary:     Color(0xFF003549),

    // Error
    error:          AppColors.error,
    onError:        Color(0xFF1A0000),

    // On-* tokens
    onSurface:      AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline:        AppColors.divider,
    outlineVariant: Color(0xFF2C3038),

    // Scrim / shadow
    scrim:          Color(0x99000000),
    shadow:         Colors.black,
    inverseSurface:      AppColors.textPrimary,
    onInverseSurface:    AppColors.backgroundBase,
    inversePrimary:      Color(0xFF1B3D2C),
  );

  // ── TextTheme ──────────────────────────────────────────────────────────────

  static TextTheme get _textTheme {
    final base = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return base.copyWith(
      displayLarge:  base.displayLarge?.copyWith(fontSize: 40, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -1.5, color: AppColors.textPrimary),
      displayMedium: base.displayMedium?.copyWith(fontSize: 32, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -1.0, color: AppColors.textPrimary),
      displaySmall:  base.displaySmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.5, color: AppColors.textPrimary),

      headlineLarge:  base.headlineLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.3, color: AppColors.textPrimary),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.2, color: AppColors.textPrimary),
      headlineSmall:  base.headlineSmall?.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textPrimary),

      titleLarge:  base.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.textPrimary),
      titleMedium: base.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.textPrimary),
      titleSmall:  base.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.textPrimary),

      bodyLarge:   base.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.55, color: AppColors.textSecondary),
      bodyMedium:  base.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.55, color: AppColors.textSecondary),
      bodySmall:   base.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w400, height: 1.55, color: AppColors.textMuted),

      labelLarge:  base.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: AppColors.textPrimary),
      labelMedium: base.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: AppColors.textSecondary),
      labelSmall:  base.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: AppColors.textMuted),
    );
  }

  // ── Component Themes ───────────────────────────────────────────────────────

  static ThemeData dark() {
    final cs = _colorScheme;
    final tt = _textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: tt,
      scaffoldBackgroundColor: AppColors.backgroundBase,
      canvasColor: AppColors.backgroundCard,
      dividerColor: AppColors.divider,

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundBase,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: tt.titleLarge?.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
      ),

      // ── Card ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Filled Button ────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF0E2419),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: tt.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),

      // ── Outlined Button ──────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: tt.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Text Button ──────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),

      // ── Input Decoration ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSheet,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: tt.bodyMedium?.copyWith(color: AppColors.textMuted),
        labelStyle: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle: tt.labelMedium?.copyWith(color: AppColors.primary),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        errorStyle: tt.bodySmall?.copyWith(color: AppColors.error),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      // ── Navigation Bar ────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.backgroundCard,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
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
        elevation: 0,
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
        labelColor: const Color(0xFF0E2419),
        unselectedLabelColor: AppColors.textSecondary,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundSheet,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: tt.labelMedium,
        side: const BorderSide(color: AppColors.divider, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.backgroundSheet,
        modalBackgroundColor: AppColors.backgroundSheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        elevation: 0,
        modalElevation: 0,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.backgroundSheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        titleTextStyle: tt.titleLarge,
        contentTextStyle: tt.bodyMedium,
        elevation: 0,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.backgroundSheet,
        contentTextStyle: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          side: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),

      // ── Floating Action Button ────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: const Color(0xFF0E2419),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.25);
          }
          return AppColors.backgroundSheet;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return AppColors.divider;
        }),
      ),

      // ── List Tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: tt.bodyMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        subtitleTextStyle: tt.bodySmall?.copyWith(color: AppColors.textMuted),
        iconColor: AppColors.textMuted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      ),

      // ── Icon ─────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),

      // ── Theme Extensions ─────────────────────────────────────────────────
      extensions: const [
        AppConditionTheme.defaultTheme,
        AppElevationTheme.defaultTheme,
        AppSpacingTheme.defaultTheme,
        AppRadiusTheme.defaultTheme,
      ],
    );
  }
}
