import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/learning_content.dart';

/// Reads and writes the financial lessons at learning_contents/{contentId}.
/// Students read the same node, so every change here shows up in the student app.
class LearningService {
  static const String node = 'learning_contents';

  // Without a time limit a write would wait forever when there is no internet.
  static const Duration writeTimeout = Duration(seconds: 15);

  /// Turns the raw value of learning_contents into a list of lessons.
  /// Broken entries (not a map, or a field with the wrong type) are skipped instead of crashing the screen.
  static List<LearningContent> listFromValue(Object? value) {
    final List<LearningContent> lessons = [];
    if (value is! Map) return lessons;

    for (final key in value.keys) {
      final lessonValue = value[key];
      if (lessonValue is! Map) continue;
      try {
        lessons.add(LearningContent.fromMap(key.toString(), lessonValue));
      } catch (e) {
        debugPrint('LearningService skipped lesson $key: $e');
      }
    }
    return lessons;
  }

  /// Live list of all lessons; the admin screen rebuilds whenever a lesson changes.
  static Stream<List<LearningContent>> watch() {
    final DatabaseReference lessonsRef = FirebaseDatabase.instance.ref(node);
    return lessonsRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  /// New unique id for a lesson, created on the device before saving.
  static String newId() {
    final DatabaseReference lessonsRef = FirebaseDatabase.instance.ref(node);
    return lessonsRef.push().key!;
  }

  /// Creates or replaces a lesson. Returns false when the write fails or takes too long.
  static Future<bool> save(LearningContent lesson) async {
    try {
      final DatabaseReference lessonRef = FirebaseDatabase.instance.ref('$node/${lesson.id}');
      await lessonRef.set(lesson.toMap()).timeout(writeTimeout);
      return true;
    } catch (e) {
      debugPrint('LearningService.save failed: $e');
      return false;
    }
  }

  /// Deletes a lesson for every student. Returns false when the write fails.
  static Future<bool> delete(String lessonId) async {
    try {
      final DatabaseReference lessonRef = FirebaseDatabase.instance.ref('$node/$lessonId');
      await lessonRef.remove().timeout(writeTimeout);
      return true;
    } catch (e) {
      debugPrint('LearningService.delete failed: $e');
      return false;
    }
  }
}
