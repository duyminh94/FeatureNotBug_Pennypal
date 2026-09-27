import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/screens/transactions/history_screen.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/transaction_filter.dart';

// 3 expenses a day, day 0 is today, day 11 is 11 days ago: 36 transactions.
List<TransactionRecord> threePerDay(int days) {
  final DateTime today = DateTime.now();
  final List<TransactionRecord> transactions = [];
  for (int day = 0; day < days; day++) {
    for (int i = 1; i <= 3; i++) {
      final DateTime date = DateTime(today.year, today.month, today.day - day, 10 + i);
      transactions.add(TransactionRecord(
        id: 'd$day-$i',
        type: TransactionTypes.expense,
        amount: 1000,
        categoryId: CategoryKeys.food,
        description: 'Day$day-$i',
        date: date.millisecondsSinceEpoch,
      ));
    }
  }
  return transactions;
}

void main() {
  group('TransactionFilter.firstGroups', () {
    final List<DayGroup> groups = TransactionFilter.groupByDay(threePerDay(12));

    test('whole days are added until there are at least 20: 7 days = 21', () {
      final List<DayGroup> shown = TransactionFilter.firstGroups(groups, 20);
      expect(shown.length, 7);
      expect(TransactionFilter.countTransactions(shown), 21);
    });

    test('a day is never cut: its total stays the full day', () {
      final List<DayGroup> shown = TransactionFilter.firstGroups(groups, 20);
      expect(shown.last.transactions.length, 3);
      expect(shown.last.netTotal, -3000);
    });

    test('asking for more than there is gives everything; an empty list gives nothing', () {
      expect(TransactionFilter.countTransactions(TransactionFilter.firstGroups(groups, 100)), 36);
      expect(TransactionFilter.firstGroups([], 20), isEmpty);
    });
  });

  testWidgets('History shows 20+ first, Show more adds the rest, a new filter starts again', (tester) async {
    tester.view.physicalSize = const Size(600, 9000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('vi')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: HistoryScreen(initialTransactions: threePerDay(12)),
    ));
    await tester.pumpAndSettle();

    // The screen starts on this month only; a search with no result shows "Clear filters", which also removes the dates.
    await tester.enterText(find.byType(TextField), 'nothing matches');
    await tester.pump();
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('Day6-3'), findsOneWidget);
    expect(find.text('Day7-1'), findsNothing);
    expect(find.text('Show more (15 left)'), findsOneWidget);

    await tester.tap(find.text('Show more (15 left)'));
    await tester.pumpAndSettle();
    expect(find.text('Day11-1'), findsOneWidget);
    expect(find.textContaining('Show more'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Day');
    await tester.pumpAndSettle();
    expect(find.text('Show more (15 left)'), findsOneWidget);
  });
}
