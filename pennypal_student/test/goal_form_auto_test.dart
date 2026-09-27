import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/recurring_item.dart';
import 'package:pennypal_student/models/savings_goal.dart';
import 'package:pennypal_student/screens/goals/goal_form_screen.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/utils/constants.dart';

void main() {
  final SavingsGoal laptop = SavingsGoal(
    id: 'laptop',
    name: 'Laptop',
    targetAmount: 10000000,
    currentAmount: 2000000,
    targetDate: DateTime.now().add(const Duration(days: 400)).millisecondsSinceEpoch,
    monthlyContribution: 1000000,
  );

  RecurringItem autoItem({bool isActive = true}) {
    return RecurringItem(
      id: 'goal_laptop',
      type: TransactionTypes.expense,
      amount: 1000000,
      categoryId: CategoryKeys.savings,
      goalId: 'laptop',
      dayOfMonth: 5,
      lastCreatedMonth: '2026-09',
      isActive: isActive,
    );
  }

  Future<void> openForm(WidgetTester tester, {SavingsGoal? initial, RecurringItem? existing}) async {
    tester.view.physicalSize = const Size(600, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('vi')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: GoalFormScreen(initial: initial, loadRecurringItem: (itemId) async => existing),
    ));
    await tester.pumpAndSettle();
  }

  Finder monthlyField() => find.byType(TextFormField).at(4);

  testWidgets('new goal: the switch appears only with a monthly amount, off by default, starting next month', (tester) async {
    await openForm(tester);
    expect(find.text('Contribute automatically'), findsNothing);

    await tester.enterText(monthlyField(), '500000');
    await tester.pumpAndSettle();
    expect(find.text('Contribute automatically'), findsOneWidget);
    expect(find.textContaining('starting next month'), findsOneWidget);
    final SwitchListTile autoSwitch = tester.widget(find.byType(SwitchListTile));
    expect(autoSwitch.value, isFalse);

    await tester.enterText(monthlyField(), '');
    await tester.pumpAndSettle();
    expect(find.text('Contribute automatically'), findsNothing);
  });

  testWidgets('editing a goal that already contributes automatically: the switch is on, with its day', (tester) async {
    await openForm(tester, initial: laptop, existing: autoItem());
    final SwitchListTile autoSwitch = tester.widget(find.byType(SwitchListTile));
    expect(autoSwitch.value, isTrue);
    expect(find.textContaining('on day 5 of each month.'), findsOneWidget);
    expect(find.textContaining('starting next month'), findsNothing);
  });

  testWidgets('a stopped auto item loads with the switch off', (tester) async {
    await openForm(tester, initial: laptop, existing: autoItem(isActive: false));
    final SwitchListTile autoSwitch = tester.widget(find.byType(SwitchListTile));
    expect(autoSwitch.value, isFalse);
  });

  testWidgets('a completed goal has no auto contribution switch', (tester) async {
    final SavingsGoal completed = SavingsGoal(
      id: 'laptop',
      name: 'Laptop',
      targetAmount: 10000000,
      currentAmount: 10000000,
      targetDate: laptop.targetDate,
      monthlyContribution: 1000000,
      status: GoalStatuses.completed,
    );
    await openForm(tester, initial: completed, existing: autoItem(isActive: false));
    expect(find.text('Contribute automatically'), findsNothing);
  });
}
