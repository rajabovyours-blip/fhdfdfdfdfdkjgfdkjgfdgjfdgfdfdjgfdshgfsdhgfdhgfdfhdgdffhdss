import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/storage/preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final themeStr = PreferencesManager.getThemeMode();
    return _parseTheme(themeStr);
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    PreferencesManager.setThemeMode(mode.name);
  }

  ThemeMode _parseTheme(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
