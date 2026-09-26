import '../models/app_settings.dart';
import 'lesson_editor.dart';
import 'validators.dart';

/// Rules of the App Settings form.
class SettingsValidator {
  static const int minThreshold = 50;
  static const int maxThreshold = 100;
  static const int announcementMaxLength = 200;

  /// Budget alert threshold must stay between 50% and 100%.
  static bool isValidThreshold(int value) {
    return value >= minThreshold && value <= maxThreshold;
  }

  /// Students contact this address, so it must be a real email shape.
  static bool isValidSupportEmail(String value) {
    return Validators.isValidEmail(value);
  }

  /// Languages whose announcement text is still empty.
  static List<LessonLanguage> missingAnnouncement(String english, String vietnamese) {
    final List<LessonLanguage> missing = [];
    if (english.trim().isEmpty) missing.add(LessonLanguage.en);
    if (vietnamese.trim().isEmpty) missing.add(LessonLanguage.vi);
    return missing;
  }

  /// Save is allowed when the threshold and email are valid, and an active banner has both languages.
  /// A banner that is turned off may keep empty text.
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

  /// The settings to save, with spaces trimmed and the save time stamped.
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
