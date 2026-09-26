import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pennypal_admin/models/user_profile.dart';
import 'package:pennypal_admin/screens/admin_shell.dart';
import 'package:pennypal_admin/screens/users/user_detail_screen.dart';
import 'package:pennypal_admin/screens/users/user_widgets.dart';
import 'package:pennypal_admin/utils/app_theme.dart';
import 'package:pennypal_admin/utils/sample_data.dart';
import 'package:pennypal_admin/utils/user_filter.dart';

Widget buildApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('en'),
    supportedLocales: const [Locale('en'), Locale('vi')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}

void useScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> openUsers(WidgetTester tester, Size size) async {
  useScreen(tester, size);
  final AdminData data = SampleData.adminData();
  await tester.pumpWidget(buildApp(AdminShell(data: data, admin: data.users.first, signOut: () async {})));
  if (size.width < 600) {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('Users').last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting());

  group('UserFilter', () {
    final List<UserProfile> students = UserFilter.students(SampleData.adminData().users);

    test('students exclude the admin and are newest first', () {
      expect(students.length, 10);
      expect(students.first.fullName, 'Vu Thanh Son');
      expect(students.any((user) => user.email == SampleData.adminEmail), isFalse);
    });

    test('AD-05: search by name or email ignores case and accents', () {
      List<String> names(String query) => UserFilter.apply(students, query: query).map((user) => user.fullName).toList();

      expect(names('MINH'), containsAll(['Nguyen Minh An', 'Le Minh Nghia']));
      expect(names('Lê Thu Hà'), ['Le Thu Ha']);
      expect(names('fpt.edu'), hasLength(2));
      expect(names('zzz'), isEmpty);
      expect(names('   '), hasLength(10));
    });

    test('status filter and paging', () {
      expect(UserFilter.apply(students, status: UserStatusFilter.locked).single.fullName, 'Le Minh Nghia');
      expect(UserFilter.apply(students, status: UserStatusFilter.active), hasLength(9));
      expect(UserFilter.pageCount(10), 2);
      expect(UserFilter.pageCount(0), 1);
      expect(UserFilter.page(students, 0), hasLength(8));
      expect(UserFilter.page(students, 1), hasLength(2));
      expect(UserFilter.page(students, 2), isEmpty);
    });

    test('withActive only changes the lock state', () {
      final UserProfile locked = UserFilter.withActive(students.first, false);
      expect(locked.isActive, isFalse);
      expect(locked.email, students.first.email);
      expect(locked.createdAt, students.first.createdAt);
    });

    test('last login labels', () async {
      final AppLocalizations l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final DateTime now = DateTime(2026, 9, 25, 15);
      String label(DateTime time) => UserLabels.lastLogin(l10n, time.millisecondsSinceEpoch, 'en', now: now);

      expect(label(DateTime(2026, 9, 25, 8, 40)), 'Today 08:40');
      expect(label(DateTime(2026, 9, 24, 23)), 'Yesterday');
      expect(label(DateTime(2026, 9, 22, 10)), '3 days ago');
      expect(label(DateTime(2026, 9, 1)), '01 Sep');
      expect(UserLabels.lastLogin(l10n, null, 'en', now: now), 'Never');
    });
  });

  testWidgets('Wide table pages 8 students and filters locked accounts', (tester) async {
    await openUsers(tester, const Size(1500, 1100));

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Showing 1–8 of 10 students'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Showing 9–10 of 10 students'), findsOneWidget);

    await tester.tap(find.text('Locked · 1'));
    await tester.pump();
    expect(find.text('Le Minh Nghia'), findsOneWidget);
    expect(find.text('Unlock'), findsOneWidget);
  });

  testWidgets('AD-03: locking a student asks first and updates the counts', (tester) async {
    await openUsers(tester, const Size(390, 900));

    await tester.tap(find.text('Lock').first);
    await tester.pumpAndSettle();
    expect(find.text('Lock Vu Thanh Son?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Locked · 1'), findsOneWidget);

    await tester.tap(find.text('Lock').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lock account'));
    await tester.pumpAndSettle();
    expect(find.text('Vu Thanh Son is now locked'), findsOneWidget);
    expect(find.text('Locked · 2'), findsOneWidget);
  });

  testWidgets('AD-04 and AD-06: detail shows counts only and can unlock', (tester) async {
    useScreen(tester, const Size(390, 900));
    final AdminData data = SampleData.adminData();
    UserProfile? changed;
    await tester.pumpWidget(buildApp(UserDetailScreen(userId: 'u_nghia', data: data, onUserChanged: (user) => changed = user)));

    expect(find.text('Le Minh Nghia'), findsOneWidget);
    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Savings goals'), findsOneWidget);
    expect(find.textContaining('Individual transactions are private'), findsOneWidget);
    expect(find.byType(DataTable), findsNothing);

    await tester.ensureVisible(find.text('Unlock account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unlock account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock account').last);
    await tester.pumpAndSettle();

    expect(changed?.isActive, isTrue);
    expect(find.text('Active'), findsOneWidget);
  });
}
