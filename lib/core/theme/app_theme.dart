import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/core/theme/app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.lightTextTheme,
      extensions: const [AppColorsExtension.light],
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF6B00),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFFFF0E5),
        secondary: Color(0xFFFF6B00),
        onSecondary: Colors.white,
        error: Color(0xFFDE3730),
        surface: Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: AppColorsExtension.light.background,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: AppColorsExtension.light.primary,
          foregroundColor: AppColorsExtension.light.onPrimary,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsExtension.light.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColorsExtension.light.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColorsExtension.light.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColorsExtension.light.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColorsExtension.light.danger),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.darkTextTheme,
      extensions: const [AppColorsExtension.dark],
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF6B00),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF331500),
        secondary: Color(0xFFFF6B00),
        onSecondary: Colors.white,
        error: Color(0xFFDE3730),
        surface: Color(0xFF161B22),
      ),
      scaffoldBackgroundColor: AppColorsExtension.dark.background,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: AppColorsExtension.dark.primary,
          foregroundColor: AppColorsExtension.dark.onPrimary,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsExtension.dark.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColorsExtension.dark.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColorsExtension.dark.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColorsExtension.dark.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColorsExtension.dark.danger),
        ),
      ),
    );
  }
}
