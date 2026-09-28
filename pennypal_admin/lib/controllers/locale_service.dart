import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the current app language and saves the choice on the device.
class LocaleService {
  static const String _prefsKey = 'languageCode';
  static const List<Locale> supportedLocales = [Locale('en'), Locale('vi')];

  /// Current language; MaterialApp rebuilds when it changes.
  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  /// Loads the saved language, keeps English when nothing is saved or reading fails.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedCode = prefs.getString(_prefsKey);
      if (savedCode == 'vi' || savedCode == 'en') {
        locale.value = Locale(savedCode!);
      }
    } catch (e) {
      debugPrint('LocaleService.load failed: $e');
    }
  }

  /// Switches the language right away and saves it for next launch.
  static Future<void> change(String languageCode) async {
    if (languageCode != 'vi' && languageCode != 'en') return;
    locale.value = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, languageCode);
    } catch (e) {
      debugPrint('LocaleService.change failed to save: $e');
    }
  }
}
