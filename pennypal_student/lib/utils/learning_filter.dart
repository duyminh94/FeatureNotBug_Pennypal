import '../models/learning_content.dart';

class LearningFilter {
  static const int wordsPerMinute = 200;

  static List<LearningContent> visible(List<LearningContent> lessons, {String? topic}) {
    final List<LearningContent> result = lessons
        .where((lesson) => lesson.isActive && (topic == null || lesson.topic == topic))
        .toList();
    result.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return result;
  }

  static int readingMinutes(String body) {
    final int words = body.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    final int minutes = (words / wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  static List<String> paragraphs(String body) {
    return body.split(RegExp(r'\n\s*\n')).map((part) => part.trim()).where((part) => part.isNotEmpty).toList();
  }
}
