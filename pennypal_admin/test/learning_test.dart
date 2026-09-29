import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_admin/models/learning_content.dart';
import 'package:pennypal_admin/screens/learning/lesson_form_screen.dart';
import 'package:pennypal_admin/utils/app_theme.dart';
import 'package:pennypal_admin/utils/constants.dart';
import 'package:pennypal_admin/utils/lesson_editor.dart';
import 'sample_data.dart';

Widget buildApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('en'),
    supportedLocales: const [Locale('en'), Locale('vi')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: home),
  );
}

void useScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

LearningContent lesson(String id, String topic, int createdAt) {
  return LearningContent(id: id, titleEn: id, titleVi: id, bodyEn: 'b', bodyVi: 'b', topic: topic, createdAt: createdAt);
}

void main() {
  group('LessonEditor', () {
    test('LN-04 / BR-63: both languages need a title and a body', () {
      expect(LessonEditor.missingLanguages(titleEn: '', bodyEn: '', titleVi: '', bodyVi: ''), [LessonLanguage.en, LessonLanguage.vi]);
      expect(LessonEditor.missingLanguages(titleEn: 'A', bodyEn: 'B', titleVi: '  ', bodyVi: 'C'), [LessonLanguage.vi]);
      expect(LessonEditor.missingLanguages(titleEn: 'A', bodyEn: 'B', titleVi: 'C', bodyVi: 'D'), isEmpty);
    });

    test('image URL is optional but must be http or https', () {
      expect(LessonEditor.isValidImageUrl(''), isTrue);
      expect(LessonEditor.isValidImageUrl('https://cdn.test/a.png'), isTrue);
      expect(LessonEditor.isValidImageUrl('http://cdn.test/a.png'), isTrue);
      expect(LessonEditor.isValidImageUrl('ftp://cdn.test/a.png'), isFalse);
      expect(LessonEditor.isValidImageUrl('picture.png'), isFalse);
      expect(LessonEditor.isValidImageUrl('https://'), isFalse);
    });

    test('filter by topic, newest first, and toggling keeps the text', () {
      final List<LearningContent> lessons = [
        lesson('old', LearningTopics.saving, 1),
        lesson('new', LearningTopics.saving, 3),
        lesson('other', LearningTopics.income, 2),
      ];

      expect(LessonEditor.filter(lessons, null).map((item) => item.id), ['new', 'other', 'old']);
      expect(LessonEditor.filter(lessons, LearningTopics.saving).map((item) => item.id), ['new', 'old']);
    });
  });

  group('Lesson form (A07)', () {
    FilledButton saveButton(WidgetTester tester) => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save lesson'));

    testWidgets('a bad image link blocks saving an otherwise complete lesson', (tester) async {
      useScreen(tester, const Size(420, 1600));
      await tester.pumpWidget(buildApp(LessonFormScreen(lessonId: 'lesson_1', initial: SampleData.adminData().lessons.first)));

      expect(find.text('Edit lesson'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNotNull);

      await tester.enterText(find.byType(TextField).last, 'picture.png');
      await tester.pump();
      expect(find.text('Enter a link that starts with http:// or https://'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);
    });

    testWidgets('a lesson with an unknown topic opens with the first topic instead of crashing', (tester) async {
      useScreen(tester, const Size(420, 1600));
      final LearningContent oddLesson = LearningContent(
        id: 'odd', titleEn: 'Odd', titleVi: 'La', bodyEn: 'b', bodyVi: 'b', topic: 'crypto', level: 'expert', createdAt: 1);
      await tester.pumpWidget(buildApp(LessonFormScreen(lessonId: 'odd', initial: oddLesson)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Edit lesson'), findsOneWidget);
    });

    Future<List<bool?>> openForm(WidgetTester tester, Future<bool> Function(LearningContent lesson) saveLesson) async {
      final List<bool?> results = [];
      useScreen(tester, const Size(420, 1600));
      await tester.pumpWidget(buildApp(Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final bool? isSaved = await Navigator.of(context).push<bool>(MaterialPageRoute(
              builder: (context) => LessonFormScreen(lessonId: 'lesson_1', initial: SampleData.adminData().lessons.first, saveLesson: saveLesson),
            ));
            results.add(isSaved);
          },
          child: const Text('Open form'),
        ),
      )));
      await tester.tap(find.text('Open form'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('a failed save keeps the form open with what was typed', (tester) async {
      await openForm(tester, (lesson) async => false);
      await tester.enterText(find.byType(TextField).first, 'My new title');
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Save lesson'));
      await tester.pumpAndSettle();

      expect(find.text('Edit lesson'), findsOneWidget);
      expect(find.text('My new title'), findsOneWidget);
      expect(find.text('Could not save the change. Check the connection and try again.'), findsOneWidget);
    });

    testWidgets('a successful save closes the form and returns true', (tester) async {
      final List<LearningContent> saved = [];
      final List<bool?> results = await openForm(tester, (lesson) async {
        saved.add(lesson);
        return true;
      });

      await tester.tap(find.widgetWithText(FilledButton, 'Save lesson'));
      await tester.pumpAndSettle();

      expect(find.text('Edit lesson'), findsNothing);
      expect(results, [true]);
      expect(saved.single.id, 'lesson_1');
    });
  });
}
