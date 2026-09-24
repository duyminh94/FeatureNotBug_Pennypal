import '../utils/constants.dart';

/// Global settings edited by the admin, stored at app_settings.
class AppSettings {
  final int defaultAlertThreshold;
  final String supportEmail;
  final String announcementEn;
  final String announcementVi;
  final bool announcementActive;
  final int? updatedAt;

  AppSettings({
    this.defaultAlertThreshold = AppDefaults.alertThreshold,
    this.supportEmail = '',
    this.announcementEn = '',
    this.announcementVi = '',
    this.announcementActive = false,
    this.updatedAt,
  });

  /// Builds settings from the map read at app_settings (missing fields use defaults, BR-105).
  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      defaultAlertThreshold:
          map[DbFields.defaultAlertThreshold] ?? AppDefaults.alertThreshold,
      supportEmail: map[DbFields.supportEmail] ?? '',
      announcementEn: map[DbFields.announcementEn] ?? '',
      announcementVi: map[DbFields.announcementVi] ?? '',
      announcementActive: map[DbFields.announcementActive] ?? false,
      updatedAt: map[DbFields.updatedAt],
    );
  }

  /// Converts the settings to a map for writing.
  Map<String, dynamic> toMap() {
    return {
      DbFields.defaultAlertThreshold: defaultAlertThreshold,
      DbFields.supportEmail: supportEmail,
      DbFields.announcementEn: announcementEn,
      DbFields.announcementVi: announcementVi,
      DbFields.announcementActive: announcementActive,
      DbFields.updatedAt: updatedAt,
    };
  }

  /// Announcement text in the given language code, empty when turned off.
  String announcementFor(String languageCode) {
    if (!announcementActive) return '';
    return languageCode == 'vi' ? announcementVi : announcementEn;
  }
}
