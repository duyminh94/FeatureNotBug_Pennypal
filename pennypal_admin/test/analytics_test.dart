import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_admin/models/transaction_record.dart';
import 'package:pennypal_admin/models/user_profile.dart';
import 'package:pennypal_admin/screens/analytics_screen.dart';
import 'package:pennypal_admin/utils/analytics_calculator.dart';
import 'package:pennypal_admin/utils/app_theme.dart';
import 'package:pennypal_admin/utils/constants.dart';
import 'package:pennypal_admin/utils/csv_builder.dart';
import 'sample_data.dart';

Widget buildApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('en'),
    supportedLocales: const [Locale('en'), Locale('vi')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: home),
  );
}

void useScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

TransactionRecord record(String id, String type, double amount, String categoryId, DateTime date) {
  return TransactionRecord(id: id, type: type, amount: amount, categoryId: categoryId, date: date.millisecondsSinceEpoch);
}

void main() {
  group('AnalyticsCalculator (BR-100 to BR-102)', () {
    test('AN-01, AN-02, AN-03: default 6 months, no reversed range, at most 12 months', () {
      final DateTime now = DateTime(2026, 9, 25);
      expect(AnalyticsCalculator.defaultFrom(now), DateTime(2026, 4));
      expect(AnalyticsCalculator.checkRange(DateTime(2026, 4), DateTime(2026, 9)), MonthRangeError.none);
      expect(AnalyticsCalculator.checkRange(DateTime(2026, 9), DateTime(2026, 4)), MonthRangeError.reversed);
      expect(AnalyticsCalculator.checkRange(DateTime(2025, 10), DateTime(2026, 9)), MonthRangeError.none);
      expect(AnalyticsCalculator.checkRange(DateTime(2025, 9), DateTime(2026, 9)), MonthRangeError.tooLong);
      expect(AnalyticsCalculator.checkRange(DateTime(2026, 9), DateTime(2026, 9)), MonthRangeError.none);
    });

    test('months cross the year in order', () {
      expect(AnalyticsCalculator.months(DateTime(2025, 11), DateTime(2026, 2)),
          [DateTime(2025, 11), DateTime(2025, 12), DateTime(2026, 1), DateTime(2026, 2)]);
    });

    test('new users count only students inside the range', () {
      final List<UserProfile> users = [
        UserProfile(uid: 'a', fullName: 'a', email: 'a', mobileNumber: '', createdAt: DateTime(2026, 8, 31, 23).millisecondsSinceEpoch),
        UserProfile(uid: 'b', fullName: 'b', email: 'b', mobileNumber: '', createdAt: DateTime(2026, 9, 1).millisecondsSinceEpoch),
        UserProfile(uid: 'c', fullName: 'c', email: 'c', mobileNumber: '', role: UserRoles.admin, createdAt: DateTime(2026, 9, 2).millisecondsSinceEpoch),
        UserProfile(uid: 'd', fullName: 'd', email: 'd', mobileNumber: '', createdAt: DateTime(2026, 1, 2).millisecondsSinceEpoch),
      ];
      expect(AnalyticsCalculator.newUsersPerMonth(users, [DateTime(2026, 8), DateTime(2026, 9)]), [1, 1]);
    });

    final Map<String, List<TransactionRecord>> transactions = {
      'a': [
        record('1', TransactionTypes.income, 3000000, CategoryKeys.allowance, DateTime(2026, 9, 1)),
        record('2', TransactionTypes.expense, 600000, CategoryKeys.food, DateTime(2026, 9, 2)),
        record('3', TransactionTypes.expense, 200000, 'cat_gym', DateTime(2026, 9, 3)),
        record('4', TransactionTypes.expense, 500000, CategoryKeys.savings, DateTime(2026, 9, 4)),
      ],
      'b': [
        record('5', TransactionTypes.expense, 200000, CategoryKeys.transport, DateTime(2026, 7, 5)),
        record('6', TransactionTypes.expense, 999000, CategoryKeys.food, DateTime(2025, 1, 5)),
      ],
    };

    test('AN-04 and AN-06: totals per month, empty months are 0', () {
      final List<MonthlyTransactions> result =
          AnalyticsCalculator.transactionsPerMonth(transactions, [DateTime(2026, 7), DateTime(2026, 8), DateTime(2026, 9)]);

      expect(result.map((item) => item.count), [1, 0, 4]);
      expect(result.last.income, 3000000);
      expect(result.last.expense, 1300000);
      expect(result[1].income, 0);
      expect(result[1].expense, 0);
    });

    test('AN-05: Custom = spending - default categories, savings excluded, never negative', () {
      final List<CategoryShare> shares =
          AnalyticsCalculator.spendingByCategory(transactions, [DateTime(2026, 7), DateTime(2026, 8), DateTime(2026, 9)]);
      final Map<String, double> amounts = {for (final CategoryShare share in shares) share.key: share.amount};

      expect(amounts, {CategoryKeys.food: 600000, CategoryKeys.transport: 200000, AnalyticsCalculator.customKey: 200000});
      expect(shares.fold<double>(0, (sum, share) => sum + share.percent), closeTo(100, 0.0001));
      expect(shares.first.key, CategoryKeys.food);
      expect(AnalyticsCalculator.spendingByCategory(transactions, [DateTime(2026, 8)]), isEmpty);
    });
  });

  group('CsvBuilder (BR-103)', () {
    test('file name follows pennypal_analytics_<from>_<to>.csv', () {
      expect(CsvBuilder.fileName(DateTime(2026, 4), DateTime(2026, 9)), 'pennypal_analytics_2026-04_2026-09.csv');
    });

    test('commas and quotes are escaped', () {
      expect(CsvBuilder.escape('Food'), 'Food');
      expect(CsvBuilder.escape('Ăn, uống'), '"Ăn, uống"');
      expect(CsvBuilder.escape('say "hi"'), '"say ""hi"""');
    });

    test('AN-09: starts with a BOM and only has aggregated numbers', () {
      final String csv = CsvBuilder.build(
        months: [DateTime(2026, 9)],
        newUsers: [2],
        transactions: [MonthlyTransactions(month: DateTime(2026, 9), income: 3000000, expense: 1300000, count: 4)],
        categories: const [CategoryShare(key: CategoryKeys.food, amount: 600000, percent: 75)],
        categoryNames: const {CategoryKeys.food: 'Ăn uống'},
      );

      expect(csv.startsWith('﻿'), isTrue);
      expect(csv, contains('Monthly,2026-09,2,3000000,1300000,4'));
      expect(csv, contains('Category,Ăn uống,600000,75.0'));
      expect(csv.contains('@'), isFalse);
    });
  });

  group('Analytics screen (A10)', () {
    final DateTime now = DateTime(2026, 9, 25);

    testWidgets('AN-01: shows the 3 charts with data tables and exports a CSV', (tester) async {
      useScreen(tester, const Size(420, 2600));
      String? exportedName;
      String? exportedContent;
      await tester.pumpWidget(buildApp(AnalyticsScreen(
        data: SampleData.adminData(),
        now: now,
        exportCsv: (name, content) async {
          exportedName = name;
          exportedContent = content;
          return true;
        },
      )));

      expect(find.text('New users per month'), findsOneWidget);
      expect(find.text('Transactions per month'), findsOneWidget);
      expect(find.text('Spending by category · all users'), findsOneWidget);
      expect(find.text('Income (M ₫)'), findsOneWidget);
      expect(find.textContaining('Custom = total spending'), findsOneWidget);

      await tester.tap(find.text('Show data table'));
      await tester.pump();
      expect(find.text('Users'), findsOneWidget);

      await tester.tap(find.text('Export CSV'));
      await tester.pumpAndSettle();
      expect(exportedName, 'pennypal_analytics_2026-04_2026-09.csv');
      expect(exportedContent, startsWith('﻿'));
      expect(find.text('Exported pennypal_analytics_2026-04_2026-09.csv'), findsOneWidget);
    });

    testWidgets('AN-03: more than 12 months shows an error and hides the charts', (tester) async {
      useScreen(tester, const Size(420, 2600));
      await tester.pumpWidget(buildApp(AnalyticsScreen(data: SampleData.adminData(), now: now, exportCsv: (_, __) async => true)));

      await tester.tap(find.text('Apr 2026').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aug 2025').last);
      await tester.pumpAndSettle();

      expect(find.text('Please choose at most 12 months'), findsOneWidget);
      expect(find.text('New users per month'), findsNothing);
      expect(find.text('Export CSV'), findsNothing);
    });

    testWidgets('a failed export tells the admin', (tester) async {
      useScreen(tester, const Size(420, 2600));
      await tester.pumpWidget(buildApp(AnalyticsScreen(data: SampleData.adminData(), now: now, exportCsv: (_, __) async => false)));

      await tester.tap(find.text('Export CSV'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't export the file. Please try again."), findsOneWidget);
    });
  });
}
