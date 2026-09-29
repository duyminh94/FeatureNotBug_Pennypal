import '../utils/constants.dart';

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

  String announcementFor(String languageCode) {
    if (!announcementActive) return '';
    return languageCode == 'vi' ? announcementVi : announcementEn;
  }
}
