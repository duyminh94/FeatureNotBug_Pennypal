import '../models/transaction_record.dart';
import 'constants.dart';

/// Transactions of one day with the net total (income − expense) of that day.
class DayGroup {
  final DateTime day;
  final List<TransactionRecord> transactions;
  final double netTotal;

  const DayGroup({required this.day, required this.transactions, required this.netTotal});
}

/// Search, filter and group logic of the History screen (no Flutter code, easy to test).
class TransactionFilter {
  /// Start of the given month (1st day 00:00:00).
  static DateTime monthStart(DateTime month) => DateTime(month.year, month.month, 1);

  /// End of the given month (last day 23:59:59.999).
  static DateTime monthEnd(DateTime month) => DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);

  /// Returns only transactions belonging to the given month. O(n).
  static List<TransactionRecord> forMonth(List<TransactionRecord> transactions, DateTime month) {
    final int start = monthStart(month).millisecondsSinceEpoch;
    final int end = monthEnd(month).millisecondsSinceEpoch;
    return transactions.where((t) => t.date >= start && t.date <= end).toList();
  }

  /// Keeps transactions that match every filter; null filters are ignored. O(n).
  static List<TransactionRecord> apply(
    List<TransactionRecord> transactions, {
    String query = '',
    String? type,
    String? categoryId,
    DateTime? from,
    DateTime? to,
  }) {
    final String keyword = query.trim().toLowerCase();
    final int? fromMillis = from == null ? null : DateTime(from.year, from.month, from.day).millisecondsSinceEpoch;
    final int? toMillis = to == null ? null : DateTime(to.year, to.month, to.day, 23, 59, 59, 999).millisecondsSinceEpoch;

    return transactions.where((transaction) {
      final bool matchesKeyword = keyword.isEmpty || transaction.description.toLowerCase().contains(keyword);
      final bool matchesType = type == null || transaction.type == type;
      final bool matchesCategory = categoryId == null || transaction.categoryId == categoryId;
      final bool isAfterFrom = fromMillis == null || transaction.date >= fromMillis;
      final bool isBeforeTo = toMillis == null || transaction.date <= toMillis;
      return matchesKeyword && matchesType && matchesCategory && isAfterFrom && isBeforeTo;
    }).toList();
  }

  /// Newest day first, newest transaction first inside a day. O(n log n) for the sort, O(n) for grouping.
  static List<DayGroup> groupByDay(List<TransactionRecord> transactions) {
    final List<TransactionRecord> sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    final Map<DateTime, List<TransactionRecord>> byDay = {};

    for (final TransactionRecord transaction in sorted) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.date);
      final DateTime day = DateTime(date.year, date.month, date.day);
      byDay.putIfAbsent(day, () => []).add(transaction);
    }

    return byDay.entries.map((entry) {
      final double netTotal = entry.value.fold(0, (sum, transaction) {
        final bool isIncome = transaction.type == TransactionTypes.income;
        return isIncome ? sum + transaction.amount : sum - transaction.amount;
      });
      return DayGroup(day: entry.key, transactions: entry.value, netTotal: netTotal);
    }).toList();
  }
}
