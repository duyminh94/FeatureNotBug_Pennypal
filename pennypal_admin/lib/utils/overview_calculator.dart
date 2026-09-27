import '../models/feedback_entry.dart';
import '../models/learning_content.dart';
import '../models/support_query.dart';
import '../models/transaction_record.dart';
import '../models/user_profile.dart';
import 'analytics_calculator.dart';
import 'constants.dart';
import '../models/admin_data.dart';

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

class MonthCount {
  final DateTime month;
  final int count;

  const MonthCount({required this.month, required this.count});
}

class OverviewCalculator {
  static bool _isInMonth(int? millis, DateTime month) {
    if (millis == null) return false;
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(millis);
    return date.year == month.year && date.month == month.month;
  }

  static List<UserProfile> students(List<UserProfile> users) {
    return users.where((user) => user.role == UserRoles.student).toList();
  }

  static List<SupportQuery> openQueries(Map<String, List<SupportQuery>> supportByUser) {
    final List<SupportQuery> result = [
      for (final List<SupportQuery> queries in supportByUser.values)
        ...queries.where((query) => !query.isResolved),
    ];
    result.sort((a, b) => (b.submittedAt ?? 0).compareTo(a.submittedAt ?? 0));
    return result;
  }

  static double? averageRating(List<FeedbackEntry> feedbacks) {
    if (feedbacks.isEmpty) return null;
    final int total = feedbacks.fold(0, (sum, feedback) => sum + feedback.rating);
    return total / feedbacks.length;
  }

  static OverviewStats compute(AdminData data, DateTime now) {
    final DateTime month = DateTime(now.year, now.month);
    final List<UserProfile> studentList = students(data.users);

    int transactionsThisMonth = 0;
    for (final List<TransactionRecord> records in data.transactionsByUser.values) {
      transactionsThisMonth += records.where((record) => _isInMonth(record.date, month)).length;
    }

    final List<LearningContent> activeLessons = data.lessons.where((lesson) => lesson.isActive).toList();

    return OverviewStats(
      totalStudents: studentList.length,
      newThisMonth: studentList.where((user) => _isInMonth(user.createdAt, month)).length,
      transactionsThisMonth: transactionsThisMonth,
      openSupport: openQueries(data.supportByUser).length,
      averageRating: averageRating(data.feedbacks),
      activeLessons: activeLessons.length,
      totalLessons: data.lessons.length,
    );
  }

  static List<MonthCount> newStudentsPerMonth(List<UserProfile> users, DateTime now, {int months = 6}) {
    final List<DateTime> keys = AnalyticsCalculator.months(DateTime(now.year, now.month - (months - 1)), DateTime(now.year, now.month));
    final List<int> counts = AnalyticsCalculator.newUsersPerMonth(users, keys);
    return [for (int index = 0; index < keys.length; index++) MonthCount(month: keys[index], count: counts[index])];
  }
}
