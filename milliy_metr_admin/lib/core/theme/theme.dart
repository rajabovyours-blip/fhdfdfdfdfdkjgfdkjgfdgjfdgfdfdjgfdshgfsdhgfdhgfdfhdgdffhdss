import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF7A00),
        onPrimary: Colors.white,
        secondary: Color(0xFF16181F),
        onSecondary: Colors.white,
        error: Color(0xFFDE3730),
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF11181C),
        surfaceContainerHighest: Color(0xFFF0F3F5),
        outline: Color(0xFFDCE2E6),
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          backgroundColor: const Color(0xFFFF7A00),
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDCE2E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF7A00), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF7A00),
        onPrimary: Colors.white,
        secondary: Color(0xFF0E1015),
        onSecondary: Colors.white,
        error: Color(0xFFDE3730),
        onError: Colors.white,
        surface: Color(0xFF16181F),
        onSurface: Colors.white,
        surfaceContainerHighest: Color(0xFF242731),
        outline: Color(0xFF2A2E39),
      ),
      scaffoldBackgroundColor: const Color(0xFF0E1015),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          backgroundColor: const Color(0xFFFF7A00),
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2A2E39)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF7A00), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF16181F),
      ),
    );
  }
}

