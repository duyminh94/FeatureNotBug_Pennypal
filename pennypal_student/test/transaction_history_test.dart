import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/screens/transactions/history_screen.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/transaction_filter.dart';

void main() {
  final DateTime sept2026 = DateTime(2026, 9, 15);
  final DateTime aug2026 = DateTime(2026, 8, 20);
  final DateTime oct2026 = DateTime(2026, 10, 5);

  final TransactionRecord txSept1 = TransactionRecord(
    id: 'tx_s1',
    type: TransactionTypes.expense,
    amount: 50000,
    categoryId: CategoryKeys.food,
    description: 'Pho bo',
    date: sept2026.millisecondsSinceEpoch,
  );

  final TransactionRecord txSept2 = TransactionRecord(
    id: 'tx_s2',
    type: TransactionTypes.income,
    amount: 200000,
    categoryId: CategoryKeys.allowance,
    description: 'Tien tieu vat',
    date: sept2026.millisecondsSinceEpoch,
  );

  final TransactionRecord txAug = TransactionRecord(
    id: 'tx_a1',
    type: TransactionTypes.expense,
    amount: 120000,
    categoryId: CategoryKeys.education,
    description: 'Sach giao khoa',
    date: aug2026.millisecondsSinceEpoch,
  );

  final TransactionRecord txOct = TransactionRecord(
    id: 'tx_o1',
    type: TransactionTypes.expense,
    amount: 30000,
    categoryId: CategoryKeys.transport,
    description: 'Xe buyt',
    date: oct2026.millisecondsSinceEpoch,
  );

  group('TransactionFilter forMonth', () {
    test('strictly filters transactions belonging to the target month', () {
      final all = [txSept1, txSept2, txAug, txOct];
      final septList = TransactionFilter.forMonth(all, DateTime(2026, 9));
      expect(septList.length, 2);
      expect(septList.map((t) => t.id), containsAll(['tx_s1', 'tx_s2']));

      final augList = TransactionFilter.forMonth(all, DateTime(2026, 8));
      expect(augList.length, 1);
      expect(augList.first.id, 'tx_a1');

      final octList = TransactionFilter.forMonth(all, DateTime(2026, 10));
      expect(octList.length, 1);
      expect(octList.first.id, 'tx_o1');
    });

    test('groupByDay groups transactions by calendar date and calculates net total', () {
      final groups = TransactionFilter.groupByDay([txSept1, txSept2]);
      expect(groups.length, 1);
      expect(groups.first.transactions.length, 2);
      expect(groups.first.netTotal, 150000);
    });
  });

  group('HistoryScreen widget', () {
    Future<void> openHistory(
      WidgetTester tester, {
      required List<TransactionRecord> transactions,
      DateTime? initialMonth,
    }) async {
      tester.view.physicalSize = const Size(600, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('vi')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: HistoryScreen(
            initialTransactions: transactions,
            initialMonth: initialMonth ?? DateTime(2026, 9),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('shows month picker and only transactions of selected month', (tester) async {
      final all = [txSept1, txSept2, txAug, txOct];
      await openHistory(tester, transactions: all, initialMonth: DateTime(2026, 9));

      expect(find.textContaining('September 2026'), findsOneWidget);

      expect(find.text('Pho bo'), findsOneWidget);
      expect(find.text('Tien tieu vat'), findsOneWidget);

      expect(find.text('Sach giao khoa'), findsNothing);
      expect(find.text('Xe buyt'), findsNothing);
    });

    testWidgets('switching month via previous button shows only that month transactions', (tester) async {
      final all = [txSept1, txSept2, txAug, txOct];
      await openHistory(tester, transactions: all, initialMonth: DateTime(2026, 9));

      expect(find.text('Pho bo'), findsOneWidget);

      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();

      expect(find.textContaining('August 2026'), findsOneWidget);
      expect(find.text('Sach giao khoa'), findsOneWidget);

      expect(find.text('Pho bo'), findsNothing);
      expect(find.text('Tien tieu vat'), findsNothing);
    });

    testWidgets('clearing search filter preserves the currently selected month', (tester) async {
      final all = [txSept1, txSept2, txAug, txOct];
      await openHistory(tester, transactions: all, initialMonth: DateTime(2026, 9));

      await tester.enterText(find.byType(TextField), 'Pho');
      await tester.pumpAndSettle();

      expect(find.text('Pho bo'), findsOneWidget);
      expect(find.text('Tien tieu vat'), findsNothing);

      await tester.tap(find.byTooltip('Clear filters'));
      await tester.pumpAndSettle();

      expect(find.textContaining('September 2026'), findsOneWidget);
      expect(find.text('Pho bo'), findsOneWidget);
      expect(find.text('Tien tieu vat'), findsOneWidget);
      expect(find.text('Sach giao khoa'), findsNothing);
    });

    testWidgets('filtering by type using segmented buttons shows only matching transactions', (tester) async {
      final all = [txSept1, txSept2, txAug, txOct];
      await openHistory(tester, transactions: all, initialMonth: DateTime(2026, 9));

      expect(find.text('Pho bo'), findsOneWidget);
      expect(find.text('Tien tieu vat'), findsOneWidget);

      final segmentedFinder = find.byType(SegmentedButton<String?>);
      expect(segmentedFinder, findsOneWidget);

      await tester.tap(find.descendant(of: segmentedFinder, matching: find.text('Expense')));
      await tester.pumpAndSettle();

      expect(find.text('Pho bo'), findsOneWidget);
      expect(find.text('Tien tieu vat'), findsNothing);

      await tester.tap(find.descendant(of: segmentedFinder, matching: find.text('Income')));
      await tester.pumpAndSettle();

      expect(find.text('Pho bo'), findsNothing);
      expect(find.text('Tien tieu vat'), findsOneWidget);

      await tester.tap(find.descendant(of: segmentedFinder, matching: find.text('All')));
      await tester.pumpAndSettle();

      expect(find.text('Pho bo'), findsOneWidget);
      expect(find.text('Tien tieu vat'), findsOneWidget);
    });
  });
}

