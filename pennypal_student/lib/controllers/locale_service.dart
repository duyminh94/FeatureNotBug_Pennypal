import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _prefsKey = 'languageCode';
  static const List<Locale> supportedLocales = [Locale('en'), Locale('vi')];

  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

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
