import '../models/user_profile.dart';
import 'constants.dart';

/// Month-based counting used by the admin charts.
class AnalyticsCalculator {
  /// First day of the month that contains [date], used as the key of a month.
  static DateTime monthOf(DateTime date) {
    return DateTime(date.year, date.month);
  }

  /// Every month from [from] to [to], both included. Empty when [to] is before [from].
  static List<DateTime> months(DateTime from, DateTime to) {
    final int monthCount = (to.year - from.year) * 12 + (to.month - from.month) + 1;
    final List<DateTime> result = [];
    for (int index = 0; index < monthCount; index++) {
      result.add(DateTime(from.year, from.month + index));
    }
    return result;
  }

  /// Number of students who registered in each month of [months].
  /// Admins and users without a creation date are not counted.
  static List<int> newUsersPerMonth(List<UserProfile> users, List<DateTime> months) {
    final Map<DateTime, int> countByMonth = {};
    for (final DateTime month in months) {
      countByMonth[month] = 0;
    }

    for (final UserProfile user in users) {
      final int? createdAt = user.createdAt;
      if (user.role != UserRoles.student || createdAt == null) continue;

      final DateTime month = monthOf(DateTime.fromMillisecondsSinceEpoch(createdAt));
      final int? currentCount = countByMonth[month];
      if (currentCount == null) continue;
      countByMonth[month] = currentCount + 1;
    }

    final List<int> result = [];
    for (final DateTime month in months) {
      result.add(countByMonth[month] ?? 0);
    }
    return result;
  }
}
