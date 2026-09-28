import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/feedback_entry.dart';
import '../utils/constants.dart';

/// Sends app feedback to feedbacks/{feedbackId}; only the Admin app can read this node.
/// Security Rules allow a student to create a new entry with their own userId, never to change one.
class FeedbackService {
  /// Returns false when nobody is signed in. The write is not awaited so it also works offline.
  static bool send(String name, String email, int rating, String comments) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('FeedbackService.send skipped: no signed-in user');
        return false;
      }

      final DatabaseReference newRef = FirebaseDatabase.instance.ref(DbNodes.feedbacks).push();
      final FeedbackEntry entry = FeedbackEntry(
        id: newRef.key!,
        userId: user.uid,
        name: name,
        email: email,
        rating: rating,
        comments: comments,
        submittedAt: DateTime.now().millisecondsSinceEpoch,
      );
      newRef.set(entry.toMap()).catchError((Object error) {
        debugPrint('FeedbackService.send failed: $error');
      });
      return true;
    } catch (e) {
      debugPrint('FeedbackService.send failed: $e');
      return false;
    }
  }
}
