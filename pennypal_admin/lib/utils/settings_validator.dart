import '../models/app_settings.dart';
import 'lesson_editor.dart';
import 'validators.dart';

class SettingsValidator {
  static const int minThreshold = 50;
  static const int maxThreshold = 100;
  static const int announcementMaxLength = 200;

  static bool isValidThreshold(int value) => value >= minThreshold && value <= maxThreshold;

  static bool isValidSupportEmail(String value) => Validators.isValidEmail(value);

  static List<LessonLanguage> missingAnnouncement(String english, String vietnamese) {
    return [
      if (english.trim().isEmpty) LessonLanguage.en,
      if (vietnamese.trim().isEmpty) LessonLanguage.vi,
    ];
  }

  static bool canSave({
    required int threshold,
    required String supportEmail,
    required bool announcementActive,
    required String announcementEn,
    required String announcementVi,
  }) {
    final bool isAnnouncementReady = !announcementActive || missingAnnouncement(announcementEn, announcementVi).isEmpty;
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
