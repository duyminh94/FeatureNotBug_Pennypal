import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_admin/models/feedback_entry.dart';
import 'package:pennypal_admin/screens/feedbacks/screen.dart';
import 'package:pennypal_admin/utils/app_theme.dart';
import 'package:pennypal_admin/utils/pager.dart';

Widget buildApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('en'),
    supportedLocales: const [Locale('en'), Locale('vi')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}

List<FeedbackEntry> makeFeedbacks(int count) {
  final List<FeedbackEntry> feedbacks = [];
  for (int i = 1; i <= count; i++) {
    final String name = 'Student $i';
    final int rating = i.isEven ? 5 : 3;
    feedbacks.add(FeedbackEntry(id: 'f$i', userId: 'u$i', name: name, email: 'u$i@test.vn', rating: rating, submittedAt: i * 1000));
  }
  return feedbacks;
}

void main() {
  group('Pager', () {
    test('page count', () {
      expect(Pager.pageCount(0), 1);
      expect(Pager.pageCount(1), 1);
      expect(Pager.pageCount(8), 1);
      expect(Pager.pageCount(9), 2);
      expect(Pager.pageCount(20), 3);
    });

    test('last page can be shorter, a page past the end is empty', () {
      final List<int> numbers = List.generate(20, (i) => i);
      expect(Pager.page(numbers, 0), [0, 1, 2, 3, 4, 5, 6, 7]);
      expect(Pager.page(numbers, 2), [16, 17, 18, 19]);
      expect(Pager.page(numbers, 3), isEmpty);
      expect(Pager.page(<int>[], 0), isEmpty);
    });

    test('page index moves back when the list gets shorter', () {
      expect(Pager.safePage(2, 20), 2);
      expect(Pager.safePage(2, 9), 1);
      expect(Pager.safePage(1, 0), 0);
    });
  });

  testWidgets('Feedbacks: 20 feedbacks are split into pages of 8', (tester) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp(Scaffold(body: FeedbackListView(feedbacks: makeFeedbacks(20)))));

    expect(find.text('Showing 1-8 of 20'), findsOneWidget);
    expect(find.text('Student 20'), findsOneWidget);
    expect(find.text('Student 13'), findsOneWidget);
    expect(find.text('Student 12'), findsNothing);

    await tester.tap(find.byTooltip('Next'));
    await tester.pump();
    expect(find.text('Showing 9-16 of 20'), findsOneWidget);
    expect(find.text('Student 12'), findsOneWidget);
    expect(find.text('Student 20'), findsNothing);

    await tester.tap(find.byTooltip('Next'));
    await tester.pump();
    expect(find.text('Showing 17-20 of 20'), findsOneWidget);
    final IconButton nextButton = tester.widget(find.widgetWithIcon(IconButton, Icons.chevron_right));
    expect(nextButton.onPressed, isNull);

    await tester.tap(find.widgetWithText(ChoiceChip, '5★'));
    await tester.pump();
    expect(find.text('Showing 1-8 of 10'), findsOneWidget);
    final IconButton previousButton = tester.widget(find.widgetWithIcon(IconButton, Icons.chevron_left));
    expect(previousButton.onPressed, isNull);
  });

  testWidgets('Feedbacks: fits on a narrow phone (320px)', (tester) async {
    tester.view.physicalSize = const Size(320, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp(Scaffold(body: FeedbackListView(feedbacks: makeFeedbacks(20)))));
    expect(find.text('Showing 1-8 of 20'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Feedbacks: one page only, no page buttons', (tester) async {
    await tester.pumpWidget(buildApp(Scaffold(body: FeedbackListView(feedbacks: makeFeedbacks(8)))));
    expect(find.byTooltip('Next'), findsNothing);
  });
}
