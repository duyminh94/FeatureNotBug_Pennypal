import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/support_query.dart';

/// Reads and writes student support queries stored at support_queries/{uid}/{queryId}.
class SupportService {
  static const String node = 'support_queries';
  static const Duration writeTimeout = Duration(seconds: 15);

  /// Converts the raw RTDB map at support_queries/{uid} into a list of queries.
  static List<SupportQuery> listFromValue(Object? value) {
    final List<SupportQuery> queries = [];
    if (value is! Map) return queries;

    for (final key in value.keys) {
      final queryValue = value[key];
      if (queryValue is Map) {
        queries.add(SupportQuery.fromMap(key.toString(), queryValue));
      }
    }
    queries.sort((a, b) => (b.submittedAt ?? 0).compareTo(a.submittedAt ?? 0));
    return queries;
  }

  /// Live stream of support queries for a specific student.
  static Stream<List<SupportQuery>> watch(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    final DatabaseReference ref = FirebaseDatabase.instance.ref('$node/$uid');
    return ref.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  /// Sends a new support query for a student.
  static Future<bool> send(String uid, SupportQuery query) async {
    if (uid.isEmpty) return false;
    try {
      final DatabaseReference queryRef = FirebaseDatabase.instance.ref('$node/$uid/${query.id}');
      await queryRef.set(query.toMap()).timeout(writeTimeout);
      return true;
    } catch (e) {
      debugPrint('SupportService.send failed: $e');
      return false;
    }
  }
}
