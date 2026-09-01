import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextTheme _buildTextTheme(Color textColor, Color textMedium) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    
    return base.copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textMedium,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: textMedium,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: _buildTextTheme(const Color(0xFF11181C), const Color(0xFF687076)),
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
          minimumSize: const Size(0, 48),
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
      textTheme: _buildTextTheme(Colors.white, const Color(0xFF9BA1A6)),
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
          minimumSize: const Size(0, 48),
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
