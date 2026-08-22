import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF0F3A59),
        onPrimary: Colors.white,
        secondary: Color(0xFFFF6B00),
        onSecondary: Colors.white,
        error: Color(0xFFDE3730),
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF11181C),
        surfaceContainerHighest: Color(0xFFF0F3F5),
        outline: Color(0xFFDCE2E6),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          backgroundColor: const Color(0xFF0F3A59),
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
          borderSide: const BorderSide(color: Color(0xFF0F3A59), width: 2),
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
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF82BDEB),
        onPrimary: Color(0xFF0F3A59),
        secondary: Color(0xFFFF8F3D),
        onSecondary: Colors.white,
        error: Color(0xFFDE3730),
        onError: Colors.white,
        surface: Color(0xFF161B22),
        onSurface: Color(0xFFECF2F8),
        surfaceContainerHighest: Color(0xFF21262D),
        outline: Color(0xFF30363D),
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          backgroundColor: const Color(0xFF82BDEB),
          foregroundColor: const Color(0xFF0F3A59),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF82BDEB), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF161B22),
      ),
    );
  }
}
