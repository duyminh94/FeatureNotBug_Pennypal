import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_admin/models/app_settings.dart';
import 'package:pennypal_admin/models/feedback_entry.dart';
import 'package:pennypal_admin/models/support_query.dart';
import 'package:pennypal_admin/models/transaction_record.dart';
import 'package:pennypal_admin/models/user_profile.dart';
import 'package:pennypal_admin/screens/admin_shell.dart';
import 'package:pennypal_admin/screens/app_settings_screen.dart';
import 'package:pennypal_admin/screens/login_screen.dart';
import 'package:pennypal_admin/screens/support/support_screen.dart';
import 'package:pennypal_admin/services/admin_auth_service.dart';
import 'package:pennypal_admin/utils/app_theme.dart';
import 'package:pennypal_admin/utils/constants.dart';
import 'package:pennypal_admin/utils/overview_calculator.dart';
import 'package:pennypal_admin/utils/sample_data.dart';

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

UserProfile makeUser(String uid, {String role = UserRoles.student, required DateTime created}) {
  return UserProfile(uid: uid, fullName: uid, email: '$uid@test.vn', mobileNumber: '0900000000', role: role, createdAt: created.millisecondsSinceEpoch);
}

TransactionRecord makeRecord(String id, DateTime date) {
  return TransactionRecord(id: id, type: TransactionTypes.expense, amount: 1000, categoryId: CategoryKeys.food, date: date.millisecondsSinceEpoch);
}

void main() {
  group('AdminAuthService', () {
    test('Firebase error codes become the login messages', () {
      expect(AdminAuthService.problemFromCode('invalid-credential'), AdminLoginProblem.wrongCredentials);
      expect(AdminAuthService.problemFromCode('user-not-found'), AdminLoginProblem.wrongCredentials);
      expect(AdminAuthService.problemFromCode('too-many-requests'), AdminLoginProblem.tooManyRequests);
      expect(AdminAuthService.problemFromCode('network-request-failed'), AdminLoginProblem.network);
      expect(AdminAuthService.problemFromCode('permission-denied'), AdminLoginProblem.notAdmin);
      expect(AdminAuthService.problemFromCode('other'), AdminLoginProblem.unknown);
    });

    test('only an active admin profile may enter', () {
      final List<UserProfile> users = SampleData.adminData().users;
      expect(AdminAuthService.isAdmin(users.first), isTrue);
      expect(AdminAuthService.isAdmin(users[1]), isFalse);
      expect(
        AdminAuthService.isAdmin(UserProfile(uid: 'x', fullName: 'x', email: 'x', mobileNumber: '', role: UserRoles.admin, isActive: false)),
        isFalse,
      );
    });
  });

  group('OverviewCalculator (BR-101)', () {
    final DateTime now = DateTime(2026, 9, 25, 10);
    final AdminData data = AdminData(
      users: [
        makeUser('admin', role: UserRoles.admin, created: DateTime(2026, 9, 1)),
        makeUser('a', created: DateTime(2026, 9, 2)),
        makeUser('b', created: DateTime(2026, 8, 31, 23)),
        makeUser('c', created: DateTime(2026, 4, 10)),
      ],
      transactionsByUser: {
        'a': [makeRecord('1', DateTime(2026, 9, 1)), makeRecord('2', DateTime(2026, 9, 30, 23))],
        'b': [makeRecord('3', DateTime(2026, 8, 31, 23)), makeRecord('4', DateTime(2026, 9, 5))],
      },
      supportByUser: {
        'a': [
          SupportQuery(id: 'old', userEmail: 'a', subject: 'Old', message: 'm', submittedAt: 1),
          SupportQuery(id: 'done', userEmail: 'a', subject: 'Done', message: 'm', status: SupportStatuses.resolved, submittedAt: 5),
        ],
        'b': [SupportQuery(id: 'new', userEmail: 'b', subject: 'New', message: 'm', submittedAt: 9)],
      },
      feedbacks: [
        FeedbackEntry(id: 'f1', userId: 'a', name: 'a', email: 'a', rating: 5),
        FeedbackEntry(id: 'f2', userId: 'b', name: 'b', email: 'b', rating: 4),
      ],
      lessons: const [],
      settings: AppSettings(),
    );

    test('AD-02: counts students, this month and open support, averages rating', () {
      final OverviewStats stats = OverviewCalculator.compute(data, now);

      expect(stats.totalStudents, 3);
      expect(stats.newThisMonth, 1);
      expect(stats.transactionsThisMonth, 3);
      expect(stats.openSupport, 2);
      expect(stats.averageRating, 4.5);
      expect(stats.totalLessons, 0);
    });

    test('open queries are newest first, no feedback gives no average', () {
      expect(OverviewCalculator.openQueries(data.supportByUser).map((query) => query.id), ['new', 'old']);
      expect(OverviewCalculator.averageRating([]), isNull);
    });

    test('new students per month has 6 months, empty months are 0', () {
      final List<MonthCount> counts = OverviewCalculator.newStudentsPerMonth(data.users, now);

      expect(counts.map((item) => item.month.month), [4, 5, 6, 7, 8, 9]);
      expect(counts.map((item) => item.count), [1, 0, 0, 0, 1, 1]);
    });

    test('sample data gives the numbers shown in the demo', () {
      final OverviewStats stats = OverviewCalculator.compute(SampleData.adminData(), DateTime.now());

      expect(stats.totalStudents, 10);
      expect(stats.newThisMonth, 2);
      expect(stats.openSupport, 4);
      expect(stats.averageRating, closeTo(4.33, 0.01));
      expect(stats.activeLessons, 6);
      expect(stats.totalLessons, 7);
    });
  });

  group('Login (A01)', () {
    Future<AdminLoginResult> fakeSignIn(String email, String password) async {
      if (email == SampleData.adminEmail) return AdminLoginResult.success(SampleData.adminData().users.first);
      if (email == 'minhan@student.edu.vn') return const AdminLoginResult.failure(AdminLoginProblem.notAdmin);
      return const AdminLoginResult.failure(AdminLoginProblem.wrongCredentials);
    }

    Future<void> signIn(WidgetTester tester, String email) async {
      await tester.enterText(find.byType(TextFormField).at(0), email);
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
    }

    testWidgets('empty fields show errors', (tester) async {
      await tester.pumpWidget(buildApp(LoginScreen(signIn: fakeSignIn)));
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      expect(find.text('This field is required'), findsNWidgets(2));
    });

    testWidgets('AD-01: a student account cannot sign in', (tester) async {
      await tester.pumpWidget(buildApp(LoginScreen(signIn: fakeSignIn)));
      await signIn(tester, 'minhan@student.edu.vn');

      expect(find.text('This account cannot access Admin'), findsOneWidget);
      expect(find.byType(AdminShell), findsNothing);
    });

    testWidgets('an unknown email gets a neutral error', (tester) async {
      await tester.pumpWidget(buildApp(LoginScreen(signIn: fakeSignIn)));
      await signIn(tester, 'nobody@test.vn');
      expect(find.text('Email or password is incorrect'), findsOneWidget);
    });

    testWidgets('the admin account opens the Overview', (tester) async {
      useScreen(tester, const Size(1400, 1000));
      await tester.pumpWidget(buildApp(LoginScreen(signIn: fakeSignIn, data: SampleData.adminData())));
      await signIn(tester, 'admin@pennypal.app');

      expect(find.byType(AdminShell), findsOneWidget);
      expect(find.text('Total students'), findsOneWidget);
    });
  });

  group('Shell (A02) and Overview (A03)', () {
    Widget shell() {
      final AdminData data = SampleData.adminData();
      return AdminShell(data: data, admin: data.users.first, signOut: () async {});
    }

    testWidgets('AD-07: wide screens use the navigation rail, the chart and the support table', (tester) async {
      useScreen(tester, const Size(1440, 1000));
      await tester.pumpWidget(buildApp(shell()));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('admin@pennypal.app'), findsOneWidget);
      expect(find.text('New students per month'), findsOneWidget);
      expect(find.text('Want to export report to Excel'), findsOneWidget);
      expect(find.text('4 open'), findsOneWidget);
      expect(find.text('Reply'), findsNWidgets(4));

      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(find.byType(AppSettingsScreen), findsOneWidget);
    });

    testWidgets('AD-08: narrow screens use a drawer with the support badge and do not overflow', (tester) async {
      useScreen(tester, const Size(360, 800));
      await tester.pumpWidget(buildApp(shell()));

      expect(find.byType(NavigationRail), findsNothing);
      expect(find.textContaining('Admin'), findsWidgets);
      await tester.scrollUntilVisible(find.text('View all'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('View all'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Total students'), -200, scrollable: find.byType(Scrollable).first);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('ADMIN CONSOLE'), findsOneWidget);
      expect(find.descendant(of: find.byType(Badge), matching: find.text('4')), findsOneWidget);

      await tester.tap(find.text('Support'));
      await tester.pumpAndSettle();
      expect(find.byType(SupportScreen), findsOneWidget);
    });

    testWidgets('"View all" opens Support and log out returns to the login screen', (tester) async {
      useScreen(tester, const Size(360, 800));
      await tester.pumpWidget(buildApp(shell()));

      await tester.scrollUntilVisible(find.text('View all'), 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('View all'));
      await tester.pump();
      expect(find.byType(SupportScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('a phone turned sideways (800x360) uses the drawer, does not overflow and can log out', (tester) async {
      useScreen(tester, const Size(800, 360));
      await tester.pumpWidget(buildApp(shell()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationRail), findsNothing);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('a wide but not very tall window (1280x700) still uses the rail', (tester) async {
      useScreen(tester, const Size(1280, 700));
      await tester.pumpWidget(buildApp(shell()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationRail), findsOneWidget);
    });
  });
}
