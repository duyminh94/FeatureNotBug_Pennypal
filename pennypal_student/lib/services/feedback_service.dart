import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/feedback_entry.dart';

/// Sends student app feedback stored at feedbacks/{feedbackId}.
class FeedbackService {
  static const String node = 'feedbacks';
  static const Duration writeTimeout = Duration(seconds: 15);

  /// Submits feedback to Firebase RTDB.
  static Future<bool> send(FeedbackEntry feedback) async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('$node/${feedback.id}');
      await ref.set(feedback.toMap()).timeout(writeTimeout);
      return true;
    } catch (e) {
      debugPrint('FeedbackService.send failed: $e');
      return false;
    }
  }
}
