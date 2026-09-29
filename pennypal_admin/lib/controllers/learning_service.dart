import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/learning_content.dart';
import '../utils/constants.dart';

class LearningService {
  static const String node = 'learning_contents';

  static const Duration writeTimeout = Duration(seconds: 15);

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

  static Stream<List<LearningContent>> watch() {
    final DatabaseReference lessonsRef = FirebaseDatabase.instance.ref(node);
    return lessonsRef.onValue.map((event) => listFromValue(event.snapshot.value));
  }

  static String newId() {
    final DatabaseReference lessonsRef = FirebaseDatabase.instance.ref(node);
    return lessonsRef.push().key!;
  }

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

  static Future<bool> setActive(String lessonId, bool isActive, int updatedAt) async {
    try {
      final DatabaseReference lessonRef = FirebaseDatabase.instance.ref('$node/$lessonId');
      await lessonRef.update({DbFields.isActive: isActive, DbFields.updatedAt: updatedAt}).timeout(writeTimeout);
      return true;
    } catch (e) {
      debugPrint('LearningService.setActive failed: $e');
      return false;
    }
  }

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
