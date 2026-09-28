import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:pennypal_student/models/budget.dart';
import 'package:pennypal_student/models/savings_goal.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/screens/dashboard/screen.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/utils/budget_calculator.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/goal_calculator.dart';

void main() {
  final DateTime now = DateTime.now();
  final String month = BudgetCalculator.monthKey(now);

  TransactionRecord expense(String id, double amount, String categoryId) {
    return TransactionRecord(id: id, type: TransactionTypes.expense, amount: amount, categoryId: categoryId, date: now.millisecondsSinceEpoch);
  }

  Future<void> openDashboard(WidgetTester tester, List<TransactionRecord> transactions, List<Budget> budgets) async {
    // Tests draw every letter as a 16px box (Ahem font), so the month bar needs a wider screen than a real phone.
    tester.view.physicalSize = const Size(600, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('vi')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: DashboardScreen(
          transactions: transactions,
          budgets: budgets,
          goals: const <SavingsGoal>[],
          userName: 'Khoa',
          onOpenTab: (tab) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('only a category budget: the home screen shows it instead of "No budget yet"', (tester) async {
    await openDashboard(
      tester,
      [expense('t1', 820400, CategoryKeys.food), expense('t2', 10200, CategoryKeys.bills)],
      [Budget(month: month, categoryId: CategoryKeys.food, limitAmount: 1000000)],
    );

    expect(find.text('Food'), findsWidgets);
    expect(find.text('82% used'), findsOneWidget);
    expect(find.text('No budget yet'), findsNothing);
  });

  testWidgets('with several category budgets the one closest to its limit is shown', (tester) async {
    await openDashboard(
      tester,
      [expense('t1', 100000, CategoryKeys.food), expense('t2', 450000, CategoryKeys.transport)],
      [
        Budget(month: month, categoryId: CategoryKeys.food, limitAmount: 1000000),
        Budget(month: month, categoryId: CategoryKeys.transport, limitAmount: 500000),
      ],
    );

    expect(find.text('90% used'), findsOneWidget);
  });

  test('"Saved" counts the money in running goals, starting amount included', () {
    SavingsGoal goal(String id, double current, String status) {
      return SavingsGoal(
          id: id, name: id, targetAmount: 25000000, initialAmount: current, currentAmount: current, targetDate: 1, status: status);
    }

    final double saved = GoalCalculator.savedInActiveGoals([
      goal('latop', 2000000, GoalStatuses.active),
      goal('go_shopping', 0, GoalStatuses.active),
      goal('old_trip', 700000, GoalStatuses.cancelled),
    ]);

    expect(saved, 2000000);
    expect(GoalCalculator.savedInActiveGoals([]), 0);
  });

  testWidgets('no budget at all still shows the create card', (tester) async {
    await openDashboard(tester, [expense('t1', 50000, CategoryKeys.food)], []);

    expect(find.text('No budget yet'), findsOneWidget);
  });
}
