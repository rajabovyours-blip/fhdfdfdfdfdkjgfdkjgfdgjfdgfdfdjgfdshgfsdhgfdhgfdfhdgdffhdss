import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setLanguage(String lang) async {
    await _prefs.setString('language', lang);
  }

  static String? getLanguage() {
    return _prefs.getString('language');
  }


  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  static List<String> getStringList(String key) {
    return _prefs.getStringList(key) ?? [];
  }

  static Future<void> setThemeMode(String theme) async {
    await _prefs.setString('theme_mode', theme);
  }

  static String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'system';
  }
}
