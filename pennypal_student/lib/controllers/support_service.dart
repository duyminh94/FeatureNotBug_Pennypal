import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/support_query.dart';
import '../utils/constants.dart';

/// Help requests of the signed-in student, stored at support_queries/{uid}/{queryId}.
/// The Admin app reads the same node and writes the reply back into the request.
///
/// Writes are not awaited on purpose (same reason as BudgetService: the app works offline).
class SupportService {
  /// Turns the raw value of support_queries/{uid} into a list, newest first.
  static List<SupportQuery> listFromValue(Object? value) {
    final List<SupportQuery> queries = [];
    if (value is! Map) return queries;

    for (final id in value.keys) {
      final item = value[id];
      if (item is Map) queries.add(SupportQuery.fromMap(id.toString(), item));
    }
    queries.sort((a, b) => (b.submittedAt ?? 0).compareTo(a.submittedAt ?? 0));
    return queries;
  }

  /// Live list of one student's requests; the admin's reply appears without reloading.
  static Stream<List<SupportQuery>> watch(String uid) {
    final DatabaseReference queriesRef = FirebaseDatabase.instance.ref('${DbNodes.supportQueries}/$uid');
    return queriesRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  /// Same list for the signed-in student (used by the Support screen).
  static Stream<List<SupportQuery>> watchMine() {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return Stream.value([]);
      return watch(user.uid);
    } catch (e) {
      return Stream.error(e);
    }
  }

  /// BR-65: the student was told about the admin's reply, so it is not announced again.
  /// Only studentNotified changes; Security Rules do not let the student touch the reply itself.
  static void markNotified(String uid, String queryId) {
    try {
      final DatabaseReference queryRef = FirebaseDatabase.instance.ref('${DbNodes.supportQueries}/$uid/$queryId');
      queryRef.update({DbFields.studentNotified: true}).catchError((Object error) {
        debugPrint('SupportService.markNotified failed: $error');
      });
    } catch (e) {
      debugPrint('SupportService.markNotified failed: $e');
    }
  }

  /// Sends a new request (status "open", no reply yet) and returns it with its new id.
  /// Returns null when nobody is signed in.
  static SupportQuery? send(String subject, String message) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('SupportService.send skipped: no signed-in user');
        return null;
      }

      final DatabaseReference newRef = FirebaseDatabase.instance.ref('${DbNodes.supportQueries}/${user.uid}').push();
      final SupportQuery query = SupportQuery(
        id: newRef.key!,
        userEmail: user.email ?? '',
        subject: subject,
        message: message,
        submittedAt: DateTime.now().millisecondsSinceEpoch,
      );
      newRef.set(query.toMap()).catchError((Object error) {
        debugPrint('SupportService.send failed: $error');
      });
      return query;
    } catch (e) {
      debugPrint('SupportService.send failed: $e');
      return null;
    }
  }
}
