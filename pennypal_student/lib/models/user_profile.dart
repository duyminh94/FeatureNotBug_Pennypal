import '../utils/constants.dart';

class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String? studentStatus;
  final String role;
  final bool isActive;
  final String currency;
  final bool notificationsEnabled;
  final int? createdAt;
  final int? lastLogin;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    this.studentStatus,
    this.role = UserRoles.student,
    this.isActive = true,
    this.currency = AppDefaults.currency,
    this.notificationsEnabled = true,
    this.createdAt,
    this.lastLogin,
  });

  factory UserProfile.fromMap(String uid, Map<dynamic, dynamic> map) {
    return UserProfile(
      uid: uid,
      fullName: map[DbFields.fullName] ?? '',
      email: map[DbFields.email] ?? '',
      mobileNumber: map[DbFields.mobileNumber] ?? '',
      studentStatus: map[DbFields.studentStatus],
      role: map[DbFields.role] ?? UserRoles.student,
      isActive: map[DbFields.isActive] ?? true,
      currency: map[DbFields.currency] ?? AppDefaults.currency,
      notificationsEnabled: map[DbFields.notificationsEnabled] ?? true,
      createdAt: map[DbFields.createdAt],
      lastLogin: map[DbFields.lastLogin],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DbFields.fullName: fullName,
      DbFields.email: email,
      DbFields.mobileNumber: mobileNumber,
      DbFields.studentStatus: studentStatus,
      DbFields.role: role,
      DbFields.isActive: isActive,
      DbFields.currency: currency,
      DbFields.notificationsEnabled: notificationsEnabled,
      DbFields.createdAt: createdAt,
      DbFields.lastLogin: lastLogin,
    };
  }

  String get initial => fullName.isEmpty ? '?' : fullName[0].toUpperCase();

  bool get isAdmin => role == UserRoles.admin;
}
