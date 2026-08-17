import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/storage/preferences.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final savedLang = PreferencesManager.getLanguage();
    if (savedLang != null && savedLang.isNotEmpty) {
      if (savedLang == 'uz' || savedLang == 'ru' || savedLang == 'en') {
        return Locale(savedLang);
      }
    }

    // System detection fallback
    final systemLocales = ui.PlatformDispatcher.instance.locales;
    for (var locale in systemLocales) {
      if (locale.languageCode == 'ru') {
        return const Locale('ru');
      }
      if (locale.languageCode == 'en') {
        return const Locale('en');
      }
      if (locale.languageCode == 'uz') {
        return const Locale('uz');
      }
    }

    return const Locale('uz'); // Default fallback
  }

  void setLocale(String languageCode) {
    if (languageCode == 'system') {
      // Clear preference to use system
      PreferencesManager.setLanguage('');
      final systemLocales = ui.PlatformDispatcher.instance.locales;
      Locale newLocale = const Locale('uz'); // Default
      for (var locale in systemLocales) {
        if (locale.languageCode == 'ru') {
          newLocale = const Locale('ru');
          break;
        }
        if (locale.languageCode == 'en') {
          newLocale = const Locale('en');
          break;
        }
        if (locale.languageCode == 'uz') {
          newLocale = const Locale('uz');
          break;
        }
      }
      state = newLocale;
    } else {
      state = Locale(languageCode);
      PreferencesManager.setLanguage(languageCode);
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});
