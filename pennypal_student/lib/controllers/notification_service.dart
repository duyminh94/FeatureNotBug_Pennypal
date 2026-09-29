import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';

class NotificationService {
  static Set<String> readIdsFromValue(Object? value) {
    final Set<String> readIds = {};
    if (value is! Map) return readIds;

    for (final id in value.keys) {
      final item = value[id];
      if (item is Map && item[DbFields.isRead] == true) readIds.add(id.toString());
    }
    return readIds;
  }

  static Stream<Set<String>> watchReadIds(String uid) {
    final DatabaseReference notificationsRef = FirebaseDatabase.instance.ref('${DbNodes.notifications}/$uid');
    return notificationsRef.onValue.map((event) => readIdsFromValue(event.snapshot.value));
  }

  static void markRead(String uid, List<String> ids) {
    if (ids.isEmpty) return;
    try {
      final Map<String, Object> updates = {};
      for (final String id in ids) {
        updates['$id/${DbFields.isRead}'] = true;
        updates['$id/readAt'] = ServerValue.timestamp;
      }

      final DatabaseReference notificationsRef = FirebaseDatabase.instance.ref('${DbNodes.notifications}/$uid');
      notificationsRef.update(updates).catchError((Object error) {
        debugPrint('NotificationService.markRead failed: $error');
      });
    } catch (e) {
      debugPrint('NotificationService.markRead failed: $e');
    }
  }
}
