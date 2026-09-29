import 'package:firebase_database/firebase_database.dart';

import '../models/learning_content.dart';
import '../utils/constants.dart';

class LearningService {
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

  static Stream<List<LearningContent>> watch() {
    try {
      final DatabaseReference lessonsRef = FirebaseDatabase.instance.ref(DbNodes.learningContents);
      return lessonsRef.onValue.map((event) => listFromValue(event.snapshot.value));
    } catch (e) {
      return Stream.error(e);
    }
  }
}
