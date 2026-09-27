import '../models/learning_content.dart';

/// The two languages every lesson must be written in.
enum LessonLanguage { en, vi }

/// Rules for creating and listing lessons.
class LessonEditor {
  static const int titleMaxLength = 100;

  /// A language is complete when both its title and body are filled.
  static bool isLanguageComplete(String title, String body) => title.trim().isNotEmpty && body.trim().isNotEmpty;

  /// Languages that are not complete yet; empty means the lesson can be saved.
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

  /// Empty is allowed; otherwise it must be an http or https link with a host.
  static bool isValidImageUrl(String value) {
    final String url = value.trim();
    if (url.isEmpty) return true;
    final Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  /// Lessons of one topic (or all topics when [topic] is null), newest first.
  static List<LearningContent> filter(List<LearningContent> lessons, String? topic) {
    final List<LearningContent> result = [];
    for (final LearningContent lesson in lessons) {
      if (topic == null || lesson.topic == topic) result.add(lesson);
    }
    result.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return result;
  }
}
