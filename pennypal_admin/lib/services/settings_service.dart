import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';

/// Reads and saves the global app settings at app_settings.
/// The student app reads the same node: support email, budget alert threshold and the announcement banner.
class SettingsService {
  static const String node = 'app_settings';

  // Without a time limit the screen would wait forever when there is no internet.
  static const Duration readTimeout = Duration(seconds: 10);
  static const Duration writeTimeout = Duration(seconds: 15);

  /// Reads the settings once. When the node does not exist yet the default values are used
  /// (threshold 80%, empty email, banner off). Returns null when the read fails.
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

  /// Replaces the whole node with the new settings. Returns false when the write fails.
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
