import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;

  // Screen dimensions
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  // Responsive breakpoints
  bool get isTablet => screenWidth >= 600;
  bool get isDesktop => screenWidth >= 1024;
  bool get isMobile => screenWidth < 600;

  // Dark mode
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Snackbars
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : colors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showErrorSnackBar(String message) => showSnackBar(message, isError: true);

  // Navigation
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
}
