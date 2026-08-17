import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class AppTypography {
  static const String fontFamily = 'Inter';

  static TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: AppColorsExtension.light.textHigh,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: AppColorsExtension.light.textHigh,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: AppColorsExtension.light.textHigh,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: AppColorsExtension.light.textHigh,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: AppColorsExtension.light.textHigh,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: AppColorsExtension.light.textMedium,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: AppColorsExtension.light.textHigh,
    ),
  );

  static TextTheme darkTextTheme = lightTextTheme.copyWith(
    displayLarge: lightTextTheme.displayLarge
        ?.copyWith(color: AppColorsExtension.dark.textHigh),
    headlineSmall: lightTextTheme.headlineSmall
        ?.copyWith(color: AppColorsExtension.dark.textHigh),
    titleLarge: lightTextTheme.titleLarge
        ?.copyWith(color: AppColorsExtension.dark.textHigh),
    titleMedium: lightTextTheme.titleMedium
        ?.copyWith(color: AppColorsExtension.dark.textHigh),
    bodyLarge: lightTextTheme.bodyLarge
        ?.copyWith(color: AppColorsExtension.dark.textHigh),
    bodyMedium: lightTextTheme.bodyMedium
        ?.copyWith(color: AppColorsExtension.dark.textMedium),
    labelLarge: lightTextTheme.labelLarge
        ?.copyWith(color: AppColorsExtension.dark.textHigh),
  );
}
