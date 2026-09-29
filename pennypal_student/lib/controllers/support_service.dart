import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/support_query.dart';
import '../utils/constants.dart';

class SupportService {
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

  static Stream<List<SupportQuery>> watch(String uid) {
    final DatabaseReference queriesRef = FirebaseDatabase.instance.ref('${DbNodes.supportQueries}/$uid');
    return queriesRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  static Stream<List<SupportQuery>> watchMine() {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return Stream.value([]);
      return watch(user.uid);
    } catch (e) {
      return Stream.error(e);
    }
  }

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
