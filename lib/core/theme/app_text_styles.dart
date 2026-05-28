import 'package:flutter/material.dart';

/// Typography scale.
/// Uses Material 3 text theme naming. Reference via Theme.of(context).textTheme
/// — don't reference AppTextStyles directly in most widgets.
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Roboto'; // Replace with custom font if desired

  static TextTheme buildTextTheme() {
    return const TextTheme(
      // Display — hero text, splash screens
      displayLarge: TextStyle(fontFamily: _fontFamily, fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
      displayMedium: TextStyle(fontFamily: _fontFamily, fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: TextStyle(fontFamily: _fontFamily, fontSize: 36, fontWeight: FontWeight.w400),

      // Headline — screen titles, section headers
      headlineLarge: TextStyle(fontFamily: _fontFamily, fontSize: 32, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontFamily: _fontFamily, fontSize: 24, fontWeight: FontWeight.w600),

      // Title — card titles, dialog titles
      titleLarge: TextStyle(fontFamily: _fontFamily, fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      titleSmall: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),

      // Body — main readable content
      bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      bodySmall: TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),

      // Label — buttons, chips, form labels
      labelLarge: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelSmall: TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    );
  }
}
