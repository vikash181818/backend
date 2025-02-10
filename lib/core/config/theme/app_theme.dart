import 'package:flutter/material.dart';


class AppTheme {
  static ThemeData get theme {
    // Start with a seed-based color scheme for orange
    final baseScheme = ColorScheme.fromSeed(seedColor: Colors.orange);


    // Override the secondary color with red
    final colorScheme = baseScheme.copyWith(
      secondary: Colors.red,
    );


    return ThemeData(
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      useMaterial3: true,
      // You can customize text styles, button themes, etc., here if needed.
    );
  }
}





