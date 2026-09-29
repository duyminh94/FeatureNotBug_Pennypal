import '../models/learning_content.dart';

enum LessonLanguage { en, vi }

class LessonEditor {
  static const int titleMaxLength = 100;

  static bool isLanguageComplete(String title, String body) => title.trim().isNotEmpty && body.trim().isNotEmpty;

  static List<LessonLanguage> missingLanguages({
    required String titleEn,
    required String bodyEn,
    required String titleVi,
    required String bodyVi,
  }) {
    final List<LessonLanguage> missing = [];
    if (!isLanguageComplete(titleEn, bodyEn)) missing.add(LessonLanguage.en);
    if (!isLanguageComplete(titleVi, bodyVi)) missing.add(LessonLanguage.vi);
    return missing;
  }

  static bool isValidImageUrl(String value) {
    final String url = value.trim();
    if (url.isEmpty) return true;
    final Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  static List<LearningContent> filter(List<LearningContent> lessons, String? topic) {
    final List<LearningContent> result = [];
    for (final LearningContent lesson in lessons) {
      if (topic == null || lesson.topic == topic) result.add(lesson);
    }
    result.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return result;
  }
}
