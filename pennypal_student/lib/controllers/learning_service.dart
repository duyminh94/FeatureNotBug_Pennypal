import 'package:firebase_database/firebase_database.dart';

import '../models/learning_content.dart';
import '../utils/constants.dart';

/// Reads the lessons the admin writes at learning_contents/{lessonId}.
/// The student app never writes here (Security Rules: only an admin can).
class LearningService {
  /// Turns the raw value of learning_contents into a list, newest first.
  static List<LearningContent> listFromValue(Object? value) {
    final List<LearningContent> lessons = [];
    if (value is! Map) return lessons;

    for (final id in value.keys) {
      final item = value[id];
      if (item is Map) lessons.add(LearningContent.fromMap(id.toString(), item));
    }
    lessons.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return lessons;
  }

  /// Live list: a lesson the admin adds, edits or turns off changes here without reloading.
  static Stream<List<LearningContent>> watch() {
    try {
      final DatabaseReference lessonsRef = FirebaseDatabase.instance.ref(DbNodes.learningContents);
      return lessonsRef.onValue.map((event) => listFromValue(event.snapshot.value));
    } catch (e) {
      return Stream.error(e);
    }
  }
}
