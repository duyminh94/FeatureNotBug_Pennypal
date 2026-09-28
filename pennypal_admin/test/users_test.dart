import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pennypal_admin/models/user_profile.dart';
import 'package:pennypal_admin/screens/users/detail_screen.dart';
import 'package:pennypal_admin/screens/users/widgets.dart';
import 'package:pennypal_admin/utils/app_theme.dart';
import 'sample_data.dart';
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

  testWidgets('AD-04: detail shows the profile and counts only, never the amounts', (tester) async {
    useScreen(tester, const Size(390, 900));
    final UserProfile locked = SampleData.adminData().users.firstWhere((user) => user.uid == 'u_nghia');
    await tester.pumpWidget(buildApp(UserDetailScreen(user: locked)));
    await tester.pump();

    expect(find.text('Le Minh Nghia'), findsOneWidget);
    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Savings goals'), findsOneWidget);
    expect(find.textContaining('Individual transactions are private'), findsOneWidget);
    expect(find.byType(DataTable), findsNothing);
    expect(find.text('Unlock account'), findsOneWidget);
  });
}
