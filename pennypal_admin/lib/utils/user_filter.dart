import '../models/user_profile.dart';
import 'constants.dart';
import 'text_normalizer.dart';

enum UserStatusFilter { all, active, locked }

class UserFilter {
  static const int pageSize = 8;

  static List<UserProfile> students(List<UserProfile> users) {
    final List<UserProfile> result = users.where((user) => user.role == UserRoles.student).toList();
    result.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return result;
  }

  static bool matchesQuery(UserProfile user, String query) {
    final String keyword = TextNormalizer.normalize(query.trim());
    if (keyword.isEmpty) return true;
    return TextNormalizer.normalize(user.fullName).contains(keyword) || TextNormalizer.normalize(user.email).contains(keyword);
  }

  static bool matchesStatus(UserProfile user, UserStatusFilter status) {
    return switch (status) {
      UserStatusFilter.all => true,
      UserStatusFilter.active => user.isActive,
      UserStatusFilter.locked => !user.isActive,
    };
  }

  static List<UserProfile> apply(List<UserProfile> students, {String query = '', UserStatusFilter status = UserStatusFilter.all}) {
    return students.where((user) => matchesQuery(user, query) && matchesStatus(user, status)).toList();
  }

  static int pageCount(int total) => total == 0 ? 1 : (total / pageSize).ceil();

  static List<UserProfile> page(List<UserProfile> users, int pageIndex) {
    final int start = pageIndex * pageSize;
    if (start >= users.length) return [];
    final int end = start + pageSize > users.length ? users.length : start + pageSize;
    return users.sublist(start, end);
  }

  static UserProfile withActive(UserProfile user, bool isActive) {
    return UserProfile(
      uid: user.uid,
      fullName: user.fullName,
      email: user.email,
      mobileNumber: user.mobileNumber,
      studentStatus: user.studentStatus,
      role: user.role,
      isActive: isActive,
      currency: user.currency,
      notificationsEnabled: user.notificationsEnabled,
      createdAt: user.createdAt,
      lastLogin: user.lastLogin,
    );
  }
}
