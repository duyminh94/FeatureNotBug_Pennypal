import '../models/admin_data.dart';
import '../models/feedback_entry.dart';
import '../models/learning_content.dart';
import '../models/support_query.dart';
import '../models/transaction_record.dart';
import '../models/user_profile.dart';
import 'analytics_calculator.dart';
import 'constants.dart';

/// The six numbers shown on the admin overview cards.
class OverviewStats {
  final int totalStudents;
  final int newThisMonth;
  final int transactionsThisMonth;
  final int openSupport;
  final double? averageRating;
  final int activeLessons;
  final int totalLessons;

  const OverviewStats({
    required this.totalStudents,
    required this.newThisMonth,
    required this.transactionsThisMonth,
    required this.openSupport,
    required this.averageRating,
    required this.activeLessons,
    required this.totalLessons,
  });
}

/// One bar of the "new students" chart.
class MonthCount {
  final DateTime month;
  final int count;

  const MonthCount({required this.month, required this.count});
}

/// Calculates the overview numbers from all app data.
class OverviewCalculator {
  /// True when [millis] falls inside the same month and year as [month].
  static bool _isInMonth(int? millis, DateTime month) {
    if (millis == null) return false;
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(millis);
    return date.year == month.year && date.month == month.month;
  }

  /// Only users with the student role (admins are not counted as students).
  static List<UserProfile> students(List<UserProfile> users) {
    final List<UserProfile> result = [];
    for (final UserProfile user in users) {
      if (user.role == UserRoles.student) result.add(user);
    }
    return result;
  }

  /// Support requests the admin has not replied to yet, newest first.
  static List<SupportQuery> openQueries(Map<String, List<SupportQuery>> supportByUser) {
    final List<SupportQuery> result = [];
    for (final List<SupportQuery> queries in supportByUser.values) {
      for (final SupportQuery query in queries) {
        if (!query.isResolved) result.add(query);
      }
    }
    result.sort((a, b) => (b.submittedAt ?? 0).compareTo(a.submittedAt ?? 0));
    return result;
  }

  /// Average star rating of all feedbacks, or null when there is no feedback yet.
  static double? averageRating(List<FeedbackEntry> feedbacks) {
    if (feedbacks.isEmpty) return null;

    int totalStars = 0;
    for (final FeedbackEntry feedback in feedbacks) {
      totalStars += feedback.rating;
    }
    return totalStars / feedbacks.length;
  }

  /// Builds the overview numbers for the month that contains [now].
  static OverviewStats compute(AdminData data, DateTime now) {
    final DateTime month = DateTime(now.year, now.month);
    final List<UserProfile> studentList = students(data.users);

    int newThisMonth = 0;
    for (final UserProfile student in studentList) {
      if (_isInMonth(student.createdAt, month)) newThisMonth++;
    }

    int transactionsThisMonth = 0;
    for (final List<TransactionRecord> records in data.transactionsByUser.values) {
      for (final TransactionRecord record in records) {
        if (_isInMonth(record.date, month)) transactionsThisMonth++;
      }
    }

    int activeLessons = 0;
    for (final LearningContent lesson in data.lessons) {
      if (lesson.isActive) activeLessons++;
    }

    return OverviewStats(
      totalStudents: studentList.length,
      newThisMonth: newThisMonth,
      transactionsThisMonth: transactionsThisMonth,
      openSupport: openQueries(data.supportByUser).length,
      averageRating: averageRating(data.feedbacks),
      activeLessons: activeLessons,
      totalLessons: data.lessons.length,
    );
  }

  /// New students per month for the last [months] months, the current month included.
  static List<MonthCount> newStudentsPerMonth(List<UserProfile> users, DateTime now, {int months = 6}) {
    final DateTime firstMonth = DateTime(now.year, now.month - (months - 1));
    final DateTime currentMonth = DateTime(now.year, now.month);
    final List<DateTime> monthList = AnalyticsCalculator.months(firstMonth, currentMonth);
    final List<int> counts = AnalyticsCalculator.newUsersPerMonth(users, monthList);

    final List<MonthCount> result = [];
    for (int index = 0; index < monthList.length; index++) {
      result.add(MonthCount(month: monthList[index], count: counts[index]));
    }
    return result;
  }
}
