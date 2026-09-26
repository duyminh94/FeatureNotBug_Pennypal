import '../models/user_profile.dart';
import 'constants.dart';
import 'text_normalizer.dart';

/// Account filter on the Users screen.
enum UserStatusFilter { all, active, locked }

/// Searching, filtering and paging the student list.
class UserFilter {
  // Rows per page in the tablet table.
  static const int pageSize = 8;

  /// Only students (the admin account is hidden), newest sign-up first.
  static List<UserProfile> students(List<UserProfile> users) {
    final List<UserProfile> result = [];
    for (final UserProfile user in users) {
      if (user.role == UserRoles.student) result.add(user);
    }
    result.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return result;
  }

  /// Search by name or email; case and Vietnamese accents are ignored ("Nguyen" finds "Nguyễn").
  static bool matchesQuery(UserProfile user, String query) {
    final String keyword = TextNormalizer.normalize(query.trim());
    if (keyword.isEmpty) return true;

    final bool nameMatches = TextNormalizer.normalize(user.fullName).contains(keyword);
    final bool emailMatches = TextNormalizer.normalize(user.email).contains(keyword);
    return nameMatches || emailMatches;
  }

  /// True when the account fits the Active / Locked filter.
  static bool matchesStatus(UserProfile user, UserStatusFilter status) {
    return switch (status) {
      UserStatusFilter.all => true,
      UserStatusFilter.active => user.isActive,
      UserStatusFilter.locked => !user.isActive,
    };
  }

  /// Students that match both the search text and the status filter.
  static List<UserProfile> apply(List<UserProfile> students, {String query = '', UserStatusFilter status = UserStatusFilter.all}) {
    final List<UserProfile> result = [];
    for (final UserProfile user in students) {
      if (matchesQuery(user, query) && matchesStatus(user, status)) result.add(user);
    }
    return result;
  }

  /// Number of pages; an empty list still has 1 page so the table can show "0 of 0".
  static int pageCount(int total) {
    if (total == 0) return 1;
    return (total / pageSize).ceil();
  }

  /// Students on one page (pageIndex starts at 0); the last page may have fewer than 8.
  static List<UserProfile> page(List<UserProfile> users, int pageIndex) {
    final int start = pageIndex * pageSize;
    if (start >= users.length) return [];

    int end = start + pageSize;
    if (end > users.length) end = users.length;
    return users.sublist(start, end);
  }

  /// Copy of a profile with a new lock state; everything else stays the same.
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
