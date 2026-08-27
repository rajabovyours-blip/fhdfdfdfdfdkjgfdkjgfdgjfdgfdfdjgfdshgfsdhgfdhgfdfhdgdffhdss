import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class AppTypography {
  static TextTheme _buildBaseTheme(Color textColor, Color textMedium) {
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

  static TextTheme get lightTextTheme => _buildBaseTheme(
        AppColorsExtension.light.textHigh,
        AppColorsExtension.light.textMedium,
      );

  static TextTheme get darkTextTheme => _buildBaseTheme(
        AppColorsExtension.dark.textHigh,
        AppColorsExtension.dark.textMedium,
      );

  static TextStyle get priceStyle => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
