import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/budget.dart';
import 'package:pennypal_student/models/category.dart';
import 'package:pennypal_student/models/recurring_item.dart';
import 'package:pennypal_student/models/savings_goal.dart';
import 'package:pennypal_student/models/support_query.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/models/user_profile.dart';
import 'package:pennypal_student/screens/main_shell.dart';
import 'package:pennypal_student/services/recurring_service.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/recurring_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';

RecurringItem item(String id, {String type = TransactionTypes.expense, int day = 5, String lastCreatedMonth = '2026-09', bool isActive = true}) {
  return RecurringItem(
    id: id,
    type: type,
    amount: 1000000,
    categoryId: CategoryKeys.miscellaneous,
    dayOfMonth: day,
    lastCreatedMonth: lastCreatedMonth,
    isActive: isActive,
  );
}

void main() {
  group('RecurringCalculator.dueChanges', () {
    test('missed months become transactions and lastCreatedMonth moves to the newest one', () {
      final Map<String, Object?> changes = RecurringCalculator.dueChanges(
        'u1',
        [item('rent', lastCreatedMonth: '2026-07'), item('allowance', type: TransactionTypes.income, day: 1, lastCreatedMonth: '2026-10')],
        DateTime(2026, 10, 10),
      );

      expect(changes.keys.toSet(), {
        'transactions/u1/rec_rent_2026-08',
        'transactions/u1/rec_rent_2026-09',
        'transactions/u1/rec_rent_2026-10',
        'recurring/u1/rent/lastCreatedMonth',
      });
      expect(changes['recurring/u1/rent/lastCreatedMonth'], '2026-10');
      final Map transaction = changes['transactions/u1/rec_rent_2026-08'] as Map;
      expect(transaction[DbFields.amount], 1000000);
      expect(transaction[DbFields.date], DateTime(2026, 8, 5).millisecondsSinceEpoch);
    });

    test('nothing due, stopped items or no items give no changes', () {
      expect(RecurringCalculator.dueChanges('u1', [item('rent')], DateTime(2026, 10, 4)), isEmpty);
      expect(RecurringCalculator.dueChanges('u1', [item('rent', isActive: false)], DateTime(2026, 12, 20)), isEmpty);
      expect(RecurringCalculator.dueChanges('u1', [], DateTime(2026, 12, 20)), isEmpty);
    });
  });

  test('RecurringService.listFromValue skips broken entries', () {
    final List<RecurringItem> items = RecurringService.listFromValue({
      'rent': item('rent').toMap(),
      'broken': 'not a map',
    });
    expect(items.map((recurring) => recurring.id), ['rent']);
    expect(RecurringService.listFromValue(null), isEmpty);
  });

  testWidgets('MainShell checks fixed items once when the app opens, for the signed-in student', (tester) async {
    SharedPreferences.setMockInitialValues({'notificationPermissionAsked': true});
    final List<String> calledFor = [];

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('vi')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: MainShell(
        profile: UserProfile(uid: 'student1', fullName: 'Minh', email: 's@x.com', mobileNumber: '0900000000'),
        watchTransactions: (uid) => Stream.value(<TransactionRecord>[]),
        watchBudgets: (uid) => Stream.value(<Budget>[]),
        watchGoals: (uid) => Stream.value(<SavingsGoal>[]),
        watchReadIds: (uid) => Stream.value(<String>{}),
        watchSupport: (uid) => Stream.value(<SupportQuery>[]),
        watchCategories: (uid) => Stream.value(<Category>[]),
        markRead: (uid, ids) {},
        markSupportNotified: (uid, queryId) {},
        createDueRecurring: (uid) async => calledFor.add(uid),
      ),
    ));
    await tester.pumpAndSettle();

    // Switching tabs rebuilds the screen but must not run the check again.
    await tester.tap(find.byIcon(Icons.flag_outlined).first);
    await tester.pumpAndSettle();
    expect(calledFor, ['student1']);
  });
}
