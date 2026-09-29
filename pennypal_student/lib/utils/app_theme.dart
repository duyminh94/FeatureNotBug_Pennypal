import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFFF6F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFF1E7E2);
  static const Color fill = Color(0xFFF3EAE5);

  static const Color textPrimary = Color(0xFF1F1A24);
  static const Color textSecondary = Color(0xFF5A5363);
  static const Color textMuted = Color(0xFF6B6473);
  static const Color textOnDark = Color(0xFFD9D2CC);

  static const Color primary = Color(0xFF0A7F58);
  static const Color primaryDark = Color(0xFF06583D);
  static const Color mint = Color(0xFF2EE6A8);
  static const Color mintSoft = Color(0xFFD9FBEE);

  static const Color income = Color(0xFF0A7F58);
  static const Color expense = Color(0xFFC2255C);
  static const Color expenseSoft = Color(0xFFFFE4EB);
  static const Color pink = Color(0xFFFF8FAB);
  static const Color error = Color(0xFFD1344F);

  static const Color honey = Color(0xFFFFD43B);
  static const Color honeySoft = Color(0xFFFFF3C4);
  static const Color honeyText = Color(0xFF7A5D00);
  static const Color warning = Color(0xFF8A5A00);

  static const Color info = Color(0xFF1F6FB2);
  static const Color infoSoft = Color(0xFFDDF0FF);

  static const Color orange = Color(0xFFB4531F);
  static const Color orangeSoft = Color(0xFFFFE6D5);
  static const Color purple = Color(0xFF5B4BC4);
  static const Color purpleSoft = Color(0xFFE9E4FF);
  static const Color teal = Color(0xFF2F6F63);
  static const Color tealSoft = Color(0xFFE3F2EF);

  static const Color gold = Color(0xFFB8860B);
  static const Color goldSoft = Color(0xFFFDF1D6);
}

class AppFonts {
  static const String heading = 'Baloo2';
  static const String body = 'BeVietnamPro';
}

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
    );
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppFonts.body,
    );
    final textTheme = baseTheme.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme.copyWith(
        headlineLarge: _heading(textTheme.headlineLarge, FontWeight.w800),
        headlineMedium: _heading(textTheme.headlineMedium, FontWeight.w800),
        headlineSmall: _heading(textTheme.headlineSmall, FontWeight.w700),
        titleLarge: _heading(textTheme.titleLarge, FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.heading,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 54),
          textStyle: const TextStyle(fontFamily: AppFonts.body, fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(48, 54),
          side: const BorderSide(color: AppColors.textPrimary, width: 1.5),
          textStyle: const TextStyle(fontFamily: AppFonts.body, fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontFamily: AppFonts.body, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.primary),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error),
        border: _inputBorder(AppColors.border),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.textPrimary,
        side: BorderSide(color: AppColors.border),
        shape: StadiumBorder(),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      navigationBarTheme: const NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontFamily: AppFonts.body, fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  static TextStyle? _heading(TextStyle? style, FontWeight weight) {
    return style?.copyWith(fontFamily: AppFonts.heading, fontWeight: weight);
  }

  static OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}
