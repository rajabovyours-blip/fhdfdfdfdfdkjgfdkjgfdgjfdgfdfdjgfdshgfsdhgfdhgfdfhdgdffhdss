import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color outline;
  final Color outlineVariant;

  final Color textHigh;
  final Color textMedium;
  final Color textDisabled;

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;

  final Color secondary;
  final Color success;
  final Color warning;
  final Color danger;

  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.textHigh,
    required this.textMedium,
    required this.textDisabled,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.danger,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? textHigh,
    Color? textMedium,
    Color? textDisabled,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      textHigh: textHigh ?? this.textHigh,
      textMedium: textMedium ?? this.textMedium,
      textDisabled: textDisabled ?? this.textDisabled,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      textHigh: Color.lerp(textHigh, other.textHigh, t)!,
      textMedium: Color.lerp(textMedium, other.textMedium, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }

  static const light = AppColorsExtension(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF7F8F7),
    surfaceVariant: Color(0xFFFFFFFF),
    outline: Color(0xFFC4D0D9),
    outlineVariant: Color(0xFFE5E9EC),
    textHigh: Color(0xFF11181C),
    textMedium: Color(0xFF536471),
    textDisabled: Color(0xFF8899A6),
    primary: Color(0xFFFF6B00),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFF0E5),
    secondary: Color(0xFFFF6B00),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFFB800),
    danger: Color(0xFFDE3730),
  );

  static const dark = AppColorsExtension(
    background: Color(0xFF0D1117),
    surface: Color(0xFF161B22),
    surfaceVariant: Color(0xFF21262D),
    outline: Color(0xFF4A5561),
    outlineVariant: Color(0xFF1E232B),
    textHigh: Color(0xFFECF2F8),
    textMedium: Color(0xFFA1AAB3),
    textDisabled: Color(0xFF717D8A),
    primary: Color(0xFFFF6B00),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF331500),
    secondary: Color(0xFFFF6B00),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFFB800),
    danger: Color(0xFFDE3730),
  );
}

extension AppThemeContextExtension on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light;
}
