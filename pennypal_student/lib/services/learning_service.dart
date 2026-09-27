import 'package:firebase_database/firebase_database.dart';

import '../models/learning_content.dart';
import '../utils/sample_lessons.dart';

/// Reads the financial lessons at learning_contents/{contentId}.
class LearningService {
  static const String node = 'learning_contents';

  /// Turns the raw value of learning_contents into a list of lessons.
  static List<LearningContent> listFromValue(Object? value) {
    final List<LearningContent> lessons = [];
    if (value is! Map) return lessons;

    for (final key in value.keys) {
      final lessonValue = value[key];
      if (lessonValue is Map) {
        lessons.add(LearningContent.fromMap(key.toString(), lessonValue));
      }
    }
    return lessons;
  }

  /// Live list of all lessons from Firebase; if empty in database, uses the default lessons.
  static Stream<List<LearningContent>> watch() {
    final DatabaseReference ref = FirebaseDatabase.instance.ref(node);
    return ref.onValue.map((event) {
      final List<LearningContent> fromDb = listFromValue(event.snapshot.value);
      if (fromDb.isNotEmpty) return fromDb;
      return SampleLessons.all();
    });
  }
}
