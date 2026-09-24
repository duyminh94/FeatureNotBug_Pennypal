import 'package:flutter/material.dart';

/// Brand and status colors (plan.md section 13).
class AppColors {
  static const Color seed = Color(0xFF2E7D32);
  static const Color income = Color(0xFF2E7D32);
  static const Color expense = Color(0xFFC62828);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF1565C0);
}

/// Material 3 theme of the Student app.
class AppTheme {
  /// Light theme built from the green seed color.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.seed);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
