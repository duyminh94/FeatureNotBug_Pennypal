import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_admin/models/feedback_entry.dart';
import 'package:pennypal_admin/models/support_query.dart';
import 'package:pennypal_admin/screens/feedbacks/feedbacks_screen.dart';
import 'package:pennypal_admin/screens/support/support_detail_screen.dart';
import 'package:pennypal_admin/utils/app_theme.dart';
import 'package:pennypal_admin/utils/constants.dart';
import 'package:pennypal_admin/utils/sample_data.dart';
import 'package:pennypal_admin/utils/support_manager.dart';

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

FeedbackEntry feedback(String id, int rating, int submittedAt) {
  return FeedbackEntry(id: id, userId: id, name: id, email: '$id@test.vn', rating: rating, submittedAt: submittedAt);
}

void main() {
  group('SupportManager (BR-60, BR-61)', () {
    test('open and resolved lists are newest first', () {
      final Map<String, List<SupportQuery>> support = SampleData.adminData().supportByUser;

      final List<SupportQuery> open = SupportManager.withStatus(support, SupportStatuses.open);
      expect(open.map((query) => query.subject).first, 'Want to export report to Excel');
      expect(open, hasLength(4));
      expect(SupportManager.withStatus(support, SupportStatuses.resolved), hasLength(2));
    });

    test('SP-04: an empty or blank reply cannot be sent', () {
      expect(SupportManager.canSendReply(''), isFalse);
      expect(SupportManager.canSendReply('   \n'), isFalse);
      expect(SupportManager.canSendReply('Hi'), isTrue);
    });

    test('a reply resolves the request and asks the app to notify the student once', () {
      final SupportQuery open = SupportQuery(id: 'q', userEmail: 'a@test.vn', subject: 'S', message: 'M', submittedAt: 1, studentNotified: true);
      final SupportQuery replied = SupportManager.reply(open, '  Please update the app.  ', 50);

      expect(replied.status, SupportStatuses.resolved);
      expect(replied.adminResponse, 'Please update the app.');
      expect(replied.respondedAt, 50);
      expect(replied.studentNotified, isFalse);
      expect(replied.submittedAt, 1);

      expect(SupportManager.ownerOf({'u': [open]}, 'q'), 'u');
      expect(SupportManager.ownerOf({'u': [open]}, 'missing'), isNull);
    });

    test('feedback filter by rating, newest first', () {
      final List<FeedbackEntry> feedbacks = [feedback('a', 5, 1), feedback('b', 2, 2), feedback('c', 1, 3), feedback('d', 5, 4)];

      expect(FeedbackFilter.apply(feedbacks, RatingFilter.all).map((item) => item.id), ['d', 'c', 'b', 'a']);
      expect(FeedbackFilter.apply(feedbacks, RatingFilter.five).map((item) => item.id), ['d', 'a']);
      expect(FeedbackFilter.apply(feedbacks, RatingFilter.lowest).map((item) => item.id), ['c', 'b']);
      expect(FeedbackFilter.apply(feedbacks, RatingFilter.three), isEmpty);
    });
  });

  testWidgets('A resolved request shows the reply read-only', (tester) async {
    useScreen(tester, const Size(420, 1200));
    final Map<String, List<SupportQuery>> support = SampleData.adminData().supportByUser;
    final SupportQuery resolved = SupportManager.withStatus(support, SupportStatuses.resolved)
        .firstWhere((query) => query.subject == 'Currency does not change');
    final String uid = SupportManager.ownerOf(support, resolved.id)!;
    await tester.pumpWidget(buildApp(SupportDetailScreen(uid: uid, query: resolved)));

    expect(find.textContaining('changing the currency only changes'), findsOneWidget);
    expect(find.text('Student notified once in the app'), findsOneWidget);
    expect(find.text('Send reply'), findsNothing);
  });

  testWidgets('Feedbacks show the average and filter by stars', (tester) async {
    useScreen(tester, const Size(420, 1600));
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(buildApp(Scaffold(body: FeedbackListView(feedbacks: SampleData.adminData().feedbacks))));

    expect(find.text('4.3'), findsOneWidget);
    expect(find.text('from 6 feedbacks'), findsOneWidget);
    expect(find.text('No comment'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '5★'));
    await tester.pump();
    expect(find.bySemanticsLabel('5 out of 5 stars'), findsNWidgets(3));

    await tester.tap(find.widgetWithText(ChoiceChip, '≤2★'));
    await tester.pump();
    expect(find.text('No feedback with this rating.'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('No feedback at all shows an empty message', (tester) async {
    await tester.pumpWidget(buildApp(const Scaffold(body: FeedbackListView(feedbacks: []))));
    expect(find.text('No feedback yet.'), findsOneWidget);
  });
}
