import '../models/user_profile.dart';
import 'constants.dart';
import 'text_normalizer.dart';

enum UserStatusFilter { all, active, locked }

class UserFilter {
  static const int pageSize = 8;

  static List<UserProfile> students(List<UserProfile> users) {
    final List<UserProfile> result = [];
    for (final UserProfile user in users) {
      if (user.role == UserRoles.student) result.add(user);
    }
    result.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return result;
  }

  static bool matchesQuery(UserProfile user, String query) {
    final String keyword = TextNormalizer.normalize(query.trim());
    if (keyword.isEmpty) return true;

    final bool nameMatches = TextNormalizer.normalize(user.fullName).contains(keyword);
    final bool emailMatches = TextNormalizer.normalize(user.email).contains(keyword);
    return nameMatches || emailMatches;
  }

  static bool matchesStatus(UserProfile user, UserStatusFilter status) {
    return switch (status) {
      UserStatusFilter.all => true,
      UserStatusFilter.active => user.isActive,
      UserStatusFilter.locked => !user.isActive,
    };
  }

  static List<UserProfile> apply(List<UserProfile> students, {String query = '', UserStatusFilter status = UserStatusFilter.all}) {
    final List<UserProfile> result = [];
    for (final UserProfile user in students) {
      if (matchesQuery(user, query) && matchesStatus(user, status)) result.add(user);
    }
    return result;
  }

  static int pageCount(int total) {
    if (total == 0) return 1;
    return (total / pageSize).ceil();
  }

  static List<UserProfile> page(List<UserProfile> users, int pageIndex) {
    final int start = pageIndex * pageSize;
    if (start >= users.length) return [];

    int end = start + pageSize;
    if (end > users.length) end = users.length;
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
