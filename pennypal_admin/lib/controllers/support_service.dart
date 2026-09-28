import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/support_query.dart';
import '../utils/constants.dart';

/// Reads the help requests students send and saves the admin's reply.
/// Data is stored per student: support_queries/{uid}/{queryId}.
class SupportService {
  static const String node = 'support_queries';

  // Without a time limit a write would wait forever when there is no internet.
  static const Duration writeTimeout = Duration(seconds: 15);

  /// Turns the raw value of support_queries into requests grouped by student uid.
  /// The uid is kept as the map key because the reply must be written back under it.
  static Map<String, List<SupportQuery>> byUserFromValue(Object? value) {
    final Map<String, List<SupportQuery>> result = {};
    if (value is! Map) return result;

    for (final uid in value.keys) {
      final userQueries = value[uid];
      if (userQueries is! Map) continue;

      final List<SupportQuery> queries = [];
      for (final queryId in userQueries.keys) {
        final queryValue = userQueries[queryId];
        if (queryValue is! Map) continue;
        try {
          queries.add(SupportQuery.fromMap(queryId.toString(), queryValue));
        } catch (e) {
          debugPrint('SupportService skipped query $uid/$queryId: $e');
        }
      }
      result[uid.toString()] = queries;
    }
    return result;
  }

  /// Live list of all requests; a new request from a student appears without reloading.
  static Stream<Map<String, List<SupportQuery>>> watch() {
    final DatabaseReference supportRef = FirebaseDatabase.instance.ref(node);
    return supportRef.onValue.map((event) => byUserFromValue(event.snapshot.value));
  }

  /// Saves the reply and closes the request.
  /// Only the reply fields are updated so the student's subject and message stay untouched.
  /// studentNotified goes back to false so the student app shows the reply once.
  static Future<bool> reply(String uid, SupportQuery repliedQuery) async {
    try {
      final DatabaseReference queryRef = FirebaseDatabase.instance.ref('$node/$uid/${repliedQuery.id}');
      await queryRef.update({
        DbFields.adminResponse: repliedQuery.adminResponse,
        DbFields.status: repliedQuery.status,
        DbFields.respondedAt: repliedQuery.respondedAt,
        DbFields.studentNotified: false,
      }).timeout(writeTimeout);
      return true;
    } catch (e) {
      debugPrint('SupportService.reply failed: $e');
      return false;
    }
  }
}
