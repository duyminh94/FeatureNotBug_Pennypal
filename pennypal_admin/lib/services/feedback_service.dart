import 'package:firebase_database/firebase_database.dart';

import '../models/feedback_entry.dart';

/// Reads the app feedback students send, stored at feedbacks/{feedbackId}.
/// The admin only reads feedback; students are the only ones who write it.
class FeedbackService {
  static const String node = 'feedbacks';

  /// Turns the raw value of feedbacks into a list.
  /// Entries that are not maps (broken data) are skipped instead of crashing the screen.
  static List<FeedbackEntry> listFromValue(Object? value) {
    final List<FeedbackEntry> feedbacks = [];
    if (value is! Map) return feedbacks;

    for (final key in value.keys) {
      final feedbackValue = value[key];
      if (feedbackValue is Map) {
        feedbacks.add(FeedbackEntry.fromMap(key.toString(), feedbackValue));
      }
    }
    return feedbacks;
  }

  /// Live list of all feedback; new ratings appear without reloading the screen.
  static Stream<List<FeedbackEntry>> watch() {
    final DatabaseReference feedbacksRef = FirebaseDatabase.instance.ref(node);
    return feedbacksRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }
}
