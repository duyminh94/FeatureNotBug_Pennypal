import 'analytics_calculator.dart';

class CsvBuilder {
  static const String byteOrderMark = '﻿';

  static String monthKey(DateTime month) => '${month.year}-${month.month.toString().padLeft(2, '0')}';

  static String fileName(DateTime from, DateTime to) => 'pennypal_analytics_${monthKey(from)}_${monthKey(to)}.csv';

  static String escape(String value) {
    final bool needsQuotes = value.contains(',') || value.contains('"') || value.contains('\n');
    return needsQuotes ? '"${value.replaceAll('"', '""')}"' : value;
  }

  static String row(List<Object> cells) => cells.map((cell) => escape(cell.toString())).join(',');

  static String build({
    required List<DateTime> months,
    required List<int> newUsers,
    required List<MonthlyTransactions> transactions,
    required List<CategoryShare> categories,
    required Map<String, String> categoryNames,
  }) {
    final List<String> lines = [
      row(['Section', 'Month', 'New users', 'Income', 'Expense', 'Transactions']),
      for (int index = 0; index < months.length; index++)
        row([
          'Monthly',
          monthKey(months[index]),
          newUsers[index],
          transactions[index].income.round(),
          transactions[index].expense.round(),
          transactions[index].count,
        ]),
      '',
      row(['Section', 'Category', 'Spending', 'Percent']),
      for (final CategoryShare share in categories)
        row(['Category', categoryNames[share.key] ?? share.key, share.amount.round(), share.percent.toStringAsFixed(1)]),
    ];
    return '$byteOrderMark${lines.join('\r\n')}\r\n';
  }
}
