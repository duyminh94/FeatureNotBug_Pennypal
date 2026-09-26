import '../models/transaction_record.dart';
import '../models/user_profile.dart';
import 'constants.dart';

enum MonthRangeError { none, reversed, tooLong }

class MonthlyTransactions {
  final DateTime month;
  final double income;
  final double expense;
  final int count;

  const MonthlyTransactions({required this.month, required this.income, required this.expense, required this.count});
}

class CategoryShare {
  final String key;
  final double amount;
  final double percent;

  const CategoryShare({required this.key, required this.amount, required this.percent});
}

class AnalyticsCalculator {
  static const int maxMonths = 12;
  static const int defaultMonths = 6;
  static const String customKey = 'custom';

  static const List<String> defaultSpendingCategories = [
    CategoryKeys.food,
    CategoryKeys.transport,
    CategoryKeys.education,
    CategoryKeys.shopping,
    CategoryKeys.entertainment,
    CategoryKeys.bills,
    CategoryKeys.miscellaneous,
  ];

  static DateTime monthOf(DateTime date) => DateTime(date.year, date.month);

  static DateTime defaultFrom(DateTime now) => DateTime(now.year, now.month - (defaultMonths - 1));

  static int monthCount(DateTime from, DateTime to) => (to.year - from.year) * 12 + to.month - from.month + 1;

  static MonthRangeError checkRange(DateTime from, DateTime to) {
    final int count = monthCount(from, to);
    if (count < 1) return MonthRangeError.reversed;
    return count > maxMonths ? MonthRangeError.tooLong : MonthRangeError.none;
  }

  static List<DateTime> months(DateTime from, DateTime to) {
    final int count = monthCount(from, to);
    return [for (int index = 0; index < count; index++) DateTime(from.year, from.month + index)];
  }

  static List<int> newUsersPerMonth(List<UserProfile> users, List<DateTime> months) {
    final Map<DateTime, int> counts = {for (final DateTime month in months) month: 0};
    for (final UserProfile user in users) {
      final int? created = user.createdAt;
      if (user.role != UserRoles.student || created == null) continue;
      final DateTime key = monthOf(DateTime.fromMillisecondsSinceEpoch(created));
      if (counts.containsKey(key)) counts[key] = counts[key]! + 1;
    }
    return months.map((month) => counts[month]!).toList();
  }

  static List<MonthlyTransactions> transactionsPerMonth(Map<String, List<TransactionRecord>> transactionsByUser, List<DateTime> months) {
    final Map<DateTime, double> income = {for (final DateTime month in months) month: 0};
    final Map<DateTime, double> expense = {...income};
    final Map<DateTime, int> count = {for (final DateTime month in months) month: 0};

    for (final List<TransactionRecord> records in transactionsByUser.values) {
      for (final TransactionRecord record in records) {
        final DateTime key = monthOf(DateTime.fromMillisecondsSinceEpoch(record.date));
        if (!count.containsKey(key)) continue;
        count[key] = count[key]! + 1;
        if (record.type == TransactionTypes.income) {
          income[key] = income[key]! + record.amount;
        } else {
          expense[key] = expense[key]! + record.amount;
        }
      }
    }

    return months
        .map((month) => MonthlyTransactions(month: month, income: income[month]!, expense: expense[month]!, count: count[month]!))
        .toList();
  }

  static List<CategoryShare> spendingByCategory(Map<String, List<TransactionRecord>> transactionsByUser, List<DateTime> months) {
    final Set<DateTime> monthSet = months.toSet();
    final Map<String, double> byDefault = {for (final String key in defaultSpendingCategories) key: 0};
    double totalSpending = 0;

    for (final List<TransactionRecord> records in transactionsByUser.values) {
      for (final TransactionRecord record in records) {
        final bool isSpending = record.type == TransactionTypes.expense && record.categoryId != CategoryKeys.savings;
        if (!isSpending || !monthSet.contains(monthOf(DateTime.fromMillisecondsSinceEpoch(record.date)))) continue;
        totalSpending += record.amount;
        if (byDefault.containsKey(record.categoryId)) byDefault[record.categoryId] = byDefault[record.categoryId]! + record.amount;
      }
    }
    if (totalSpending == 0) return [];

    final double defaultTotal = byDefault.values.fold(0, (sum, amount) => sum + amount);
    final double custom = totalSpending - defaultTotal;
    final Map<String, double> amounts = {...byDefault, customKey: custom < 0 ? 0 : custom};

    final List<CategoryShare> result = amounts.entries
        .where((entry) => entry.value > 0)
        .map((entry) => CategoryShare(key: entry.key, amount: entry.value, percent: entry.value / totalSpending * 100))
        .toList();
    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }
}
