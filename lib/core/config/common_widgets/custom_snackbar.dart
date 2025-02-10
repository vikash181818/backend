// lib/src/core/utils/widgets/custom_snackbar.dart

import 'package:flutter/material.dart';

class CustomSnackbar {
  /// Shows a SnackBar using BuildContext.
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor, // Make nullable to derive from theme
    Color? textColor, // Make nullable to derive from theme
    Duration duration = const Duration(seconds: 3),
    double fontSize = 16.0,
    double borderRadius = 8.0,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.secondary; // Default to secondary color
    final effectiveTextColor =
        textColor ?? colorScheme.onSecondary; // Default to onSecondary text color

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: effectiveTextColor,
          fontSize: fontSize,
        ),
      ),
      backgroundColor: effectiveBackgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      duration: duration,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Shows a SnackBar using a global ScaffoldMessengerKey.
  static void showWithKey({
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required String message,
    Color? backgroundColor, // Make nullable to derive from theme
    Color? textColor, // Make nullable to derive from theme
    Duration duration = const Duration(seconds: 3),
    double fontSize = 16.0,
    double borderRadius = 8.0,
  }) {
    final context = scaffoldMessengerKey.currentContext;
    if (context == null) {
      debugPrint('ScaffoldMessengerState context is null. Cannot show SnackBar.');
      return;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.secondary; // Default to secondary color
    final effectiveTextColor =
        textColor ?? colorScheme.onSecondary; // Default to onSecondary text color

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: effectiveTextColor,
          fontSize: fontSize,
        ),
      ),
      backgroundColor: effectiveBackgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      duration: duration,
    );

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}



