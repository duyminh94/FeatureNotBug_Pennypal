import '../models/app_settings.dart';
import 'lesson_editor.dart';
import 'validators.dart';

class SettingsValidator {
  static const int minThreshold = 50;
  static const int maxThreshold = 100;
  static const int announcementMaxLength = 200;

  static bool isValidThreshold(int value) {
    return value >= minThreshold && value <= maxThreshold;
  }

  static bool isValidSupportEmail(String value) {
    return Validators.isValidEmail(value);
  }

  static List<LessonLanguage> missingAnnouncement(String english, String vietnamese) {
    final List<LessonLanguage> missing = [];
    if (english.trim().isEmpty) missing.add(LessonLanguage.en);
    if (vietnamese.trim().isEmpty) missing.add(LessonLanguage.vi);
    return missing;
  }

  static bool canSave({
    required int threshold,
    required String supportEmail,
    required bool announcementActive,
    required String announcementEn,
    required String announcementVi,
  }) {
    bool isAnnouncementReady = true;
    if (announcementActive && missingAnnouncement(announcementEn, announcementVi).isNotEmpty) {
      isAnnouncementReady = false;
    }
    return isValidThreshold(threshold) && isValidSupportEmail(supportEmail) && isAnnouncementReady;
  }

  static AppSettings build({
    required int threshold,
    required String supportEmail,
    required bool announcementActive,
    required String announcementEn,
    required String announcementVi,
    required int updatedAt,
  }) {
    return AppSettings(
      defaultAlertThreshold: threshold,
      supportEmail: supportEmail.trim(),
      announcementEn: announcementEn.trim(),
      announcementVi: announcementVi.trim(),
      announcementActive: announcementActive,
      updatedAt: updatedAt,
    );
  }
}
