import 'package:flutter/material.dart';

/// Centralised error types for cleaner error messages in the UI.
class AppError {
  const AppError({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;

  /// Parse a raw exception into a readable AppError.
  factory AppError.from(Object error) {
    final str = error.toString().toLowerCase();

    if (str.contains('network') || str.contains('socket')) {
      return const AppError(
        message: 'No internet connection. Please check your network.',
        code: 'network_error',
      );
    }
    if (str.contains('permission') || str.contains('unauthorized')) {
      return const AppError(
        message: 'You don\'t have permission to do that.',
        code: 'permission_denied',
      );
    }
    if (str.contains('not-found') || str.contains('no such')) {
      return const AppError(
        message: 'The requested item could not be found.',
        code: 'not_found',
      );
    }
    if (str.contains('timeout')) {
      return const AppError(
        message: 'Request timed out. Please try again.',
        code: 'timeout',
      );
    }

    return const AppError(
      message: 'Something went wrong. Please try again.',
      code: 'unknown',
    );
  }
}

/// Show a standardised error snackbar from anywhere with a context.
void showErrorSnackbar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

/// Show a success snackbar.
void showSuccessSnackbar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
