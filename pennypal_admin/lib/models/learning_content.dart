import '../utils/constants.dart';

/// A bilingual financial lesson, stored at learning_contents/{contentId}.
class LearningContent {
  final String id;
  final String titleEn;
  final String titleVi;
  final String bodyEn;
  final String bodyVi;
  final String topic;
  final String level;
  final String? imageUrl;
  final bool isActive;
  final int? createdAt;
  final int? updatedAt;

  LearningContent({
    required this.id,
    required this.titleEn,
    required this.titleVi,
    required this.bodyEn,
    required this.bodyVi,
    required this.topic,
    this.level = LearningLevels.beginner,
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Builds a lesson from the map read at learning_contents/{contentId}.
  factory LearningContent.fromMap(String id, Map<dynamic, dynamic> map) {
    return LearningContent(
      id: id,
      titleEn: map[DbFields.titleEn] ?? '',
      titleVi: map[DbFields.titleVi] ?? '',
      bodyEn: map[DbFields.bodyEn] ?? '',
      bodyVi: map[DbFields.bodyVi] ?? '',
      topic: map[DbFields.topic] ?? LearningTopics.budgeting,
      level: map[DbFields.level] ?? LearningLevels.beginner,
      imageUrl: map[DbFields.imageUrl],
      isActive: map[DbFields.isActive] ?? true,
      createdAt: map[DbFields.createdAt],
      updatedAt: map[DbFields.updatedAt],
    );
  }

  /// Converts the lesson to a map for writing.
  Map<String, dynamic> toMap() {
    return {
      DbFields.titleEn: titleEn,
      DbFields.titleVi: titleVi,
      DbFields.bodyEn: bodyEn,
      DbFields.bodyVi: bodyVi,
      DbFields.topic: topic,
      DbFields.level: level,
      DbFields.imageUrl: imageUrl,
      DbFields.isActive: isActive,
      DbFields.createdAt: createdAt,
      DbFields.updatedAt: updatedAt,
    };
  }

  /// Title in the given language code ("vi" or "en").
  String titleFor(String languageCode) =>
      languageCode == 'vi' ? titleVi : titleEn;

  /// Body in the given language code ("vi" or "en").
  String bodyFor(String languageCode) => languageCode == 'vi' ? bodyVi : bodyEn;
}
