import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../utils/constants.dart';

class AppSettingsService {
  static const Duration readTimeout = Duration(seconds: 10);

  static Future<AppSettings> load() async {
    try {
      final DataSnapshot snapshot = await FirebaseDatabase.instance.ref(DbNodes.appSettings).get().timeout(readTimeout);
      final Object? value = snapshot.value;
      if (value is Map) return AppSettings.fromMap(value);
    } catch (e) {
      debugPrint('AppSettingsService.load failed: $e');
    }
    return AppSettings.fromMap({});
  }
}
