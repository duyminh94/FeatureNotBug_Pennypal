import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:pennypal_student/models/budget.dart';
import 'package:pennypal_student/models/category.dart';
import 'package:pennypal_student/models/savings_goal.dart';
import 'package:pennypal_student/models/support_query.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/models/user_profile.dart';
import 'package:pennypal_student/screens/auth/login_screen.dart';
import 'package:pennypal_student/screens/main_shell.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MainShell when the admin locks the account', () {
    setUp(() => SharedPreferences.setMockInitialValues({'notificationPermissionAsked': true}));

    Future<void> openShell(WidgetTester tester, Stream<bool> isActive, List<String> events) async {
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
          watchIsActive: (uid) => isActive,
          signOut: () async => events.add('signOut'),
          markRead: (uid, ids) {},
          markSupportNotified: (uid, queryId) {},
          createDueRecurring: (uid) async {},
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('isActive turns false: signs out and shows the login screen with the locked message', (tester) async {
      final StreamController<bool> isActive = StreamController();
      final List<String> events = [];
      await openShell(tester, isActive.stream, events);
      expect(find.byType(MainShell), findsOneWidget);

      isActive.add(false);
      await tester.pumpAndSettle();

      expect(events, ['signOut']);
      expect(find.byType(MainShell), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Your account has been locked'), findsOneWidget);
    });

    testWidgets('isActive stays true: the student keeps using the app', (tester) async {
      final StreamController<bool> isActive = StreamController();
      final List<String> events = [];
      await openShell(tester, isActive.stream, events);

      isActive.add(true);
      await tester.pumpAndSettle();

      expect(events, isEmpty);
      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('the stream sending false twice signs out only once', (tester) async {
      final StreamController<bool> isActive = StreamController();
      final List<String> events = [];
      await openShell(tester, isActive.stream, events);

      isActive.add(false);
      isActive.add(false);
      await tester.pumpAndSettle();

      expect(events, ['signOut']);
    });
  });
}
