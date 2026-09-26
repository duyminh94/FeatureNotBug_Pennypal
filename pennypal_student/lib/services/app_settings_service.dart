import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../utils/constants.dart';

/// Reads app_settings (support email, default alert threshold, announcement) written by the admin.
class AppSettingsService {
  // Offline the phone answers from its cache; this limit only stops a first read from waiting forever.
  static const Duration readTimeout = Duration(seconds: 10);

  /// Reads the settings once. Empty node, no cache or an error gives the default values in code.
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
