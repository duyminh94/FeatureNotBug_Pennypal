import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';

class SettingsService {
  static const String node = 'app_settings';

  static const Duration readTimeout = Duration(seconds: 10);
  static const Duration writeTimeout = Duration(seconds: 15);

  static Future<AppSettings?> load() async {
    try {
      final DataSnapshot snapshot = await FirebaseDatabase.instance.ref(node).get().timeout(readTimeout);
      final Object? value = snapshot.value;
      if (value is Map) return AppSettings.fromMap(value);
      return AppSettings();
    } catch (e) {
      debugPrint('SettingsService.load failed: $e');
      return null;
    }
  }

  static Future<bool> save(AppSettings settings) async {
    try {
      await FirebaseDatabase.instance.ref(node).set(settings.toMap()).timeout(writeTimeout);
      return true;
    } catch (e) {
      debugPrint('SettingsService.save failed: $e');
      return false;
    }
  }
}
