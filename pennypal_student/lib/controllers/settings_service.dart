import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';

class SettingsService {
  static const String node = 'app_settings';
  static const Duration readTimeout = Duration(seconds: 10);

  static Future<AppSettings> load() async {
    try {
      final DataSnapshot snapshot = await FirebaseDatabase.instance.ref(node).get().timeout(readTimeout);
      final Object? value = snapshot.value;
      if (value is Map) return AppSettings.fromMap(value);
      return AppSettings();
    } catch (e) {
      debugPrint('SettingsService.load failed: $e');
      return AppSettings();
    }
  }

  static Stream<AppSettings> watch() {
    final DatabaseReference ref = FirebaseDatabase.instance.ref(node);
    return ref.onValue.map((event) {
      final Object? value = event.snapshot.value;
      if (value is Map) return AppSettings.fromMap(value);
      return AppSettings();
    });
  }
}
