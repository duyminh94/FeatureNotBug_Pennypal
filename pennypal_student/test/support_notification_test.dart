import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/budget.dart';
import 'package:pennypal_student/models/category.dart';
import 'package:pennypal_student/models/savings_goal.dart';
import 'package:pennypal_student/models/support_query.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/models/user_profile.dart';
import 'package:pennypal_student/screens/main_shell.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/notification_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

SupportQuery query(String id, {String status = SupportStatuses.resolved, String? reply = 'Done', bool notified = false}) {
  return SupportQuery(
    id: id,
    userEmail: 's@x.com',
    subject: 'Help',
    message: 'Cannot add budget',
    status: status,
    adminResponse: reply,
    submittedAt: 1,
    respondedAt: 2,
    studentNotified: notified,
  );
}

void main() {
  group('NotificationBuilder.supportRepliesToAnnounce (BR-65)', () {
    test('only answered requests the student was not told about yet', () {
      final List<SupportQuery> result = NotificationBuilder.supportRepliesToAnnounce([
        query('new_reply'),
        query('already_told', notified: true),
        query('still_open', status: SupportStatuses.open, reply: null),
        query('empty_reply', reply: ''),
      ]);

      expect(result.map((item) => item.id), ['new_reply']);
    });

    test('no requests gives nothing to announce', () {
      expect(NotificationBuilder.supportRepliesToAnnounce([]), isEmpty);
    });
  });

  group('MainShell announces a help reply once', () {
    setUp(() => SharedPreferences.setMockInitialValues({'notificationPermissionAsked': true}));

    Future<void> openShell(WidgetTester tester, Stream<List<SupportQuery>> support, List<String> marked) async {
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
          watchSupport: (uid) => support,
          watchCategories: (uid) => Stream.value(<Category>[]),
          markRead: (uid, ids) {},
          markSupportNotified: (uid, queryId) => marked.add(queryId),
          createDueRecurring: (uid) async {},
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('a reply arriving after the other data is marked once, even when the list comes again', (tester) async {
      final StreamController<List<SupportQuery>> support = StreamController();
      final List<String> marked = [];
      await openShell(tester, support.stream, marked);

      support.add([query('q1')]);
      await tester.pumpAndSettle();
      // Same data again before Firebase saved studentNotified: no second announcement.
      support.add([query('q1')]);
      await tester.pumpAndSettle();

      expect(marked, ['q1']);
      await support.close();
    });

    testWidgets('opening the app again after it was announced does nothing', (tester) async {
      final List<String> marked = [];
      await openShell(tester, Stream.value([query('q1', notified: true)]), marked);

      expect(marked, isEmpty);
    });
  });
}
