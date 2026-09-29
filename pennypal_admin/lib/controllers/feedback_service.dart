import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/feedback_entry.dart';

class FeedbackService {
  static const String node = 'feedbacks';

  static List<FeedbackEntry> listFromValue(Object? value) {
    final List<FeedbackEntry> feedbacks = [];
    if (value is! Map) return feedbacks;

    for (final key in value.keys) {
      final feedbackValue = value[key];
      if (feedbackValue is! Map) continue;
      try {
        feedbacks.add(FeedbackEntry.fromMap(key.toString(), feedbackValue));
      } catch (e) {
        debugPrint('FeedbackService skipped feedback $key: $e');
      }
    }
    return feedbacks;
  }

  static Stream<List<FeedbackEntry>> watch() {
    final DatabaseReference feedbacksRef = FirebaseDatabase.instance.ref(node);
    return feedbacksRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }
}
