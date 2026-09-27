import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_admin/models/app_settings.dart';
import 'package:pennypal_admin/screens/app_settings_screen.dart';
import 'package:pennypal_admin/utils/app_theme.dart';
import 'package:pennypal_admin/utils/lesson_editor.dart';
import 'sample_data.dart';
import 'package:pennypal_admin/utils/settings_validator.dart';

Widget buildApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('en'),
    supportedLocales: const [Locale('en'), Locale('vi')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: home),
  );
}

void useScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(420, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('SettingsValidator (BR-104)', () {
    bool canSave({int threshold = 80, String email = 'support@pennypal.app', bool active = true, String en = 'Hi', String vi = 'Chào'}) {
      return SettingsValidator.canSave(
        threshold: threshold,
        supportEmail: email,
        announcementActive: active,
        announcementEn: en,
        announcementVi: vi,
      );
    }

    test('ST-02: threshold must be 50 to 100 and the email must be valid', () {
      expect(SettingsValidator.isValidThreshold(49), isFalse);
      expect(SettingsValidator.isValidThreshold(50), isTrue);
      expect(SettingsValidator.isValidThreshold(100), isTrue);
      expect(SettingsValidator.isValidThreshold(101), isFalse);
      expect(canSave(email: 'support@pennypal'), isFalse);
      expect(canSave(threshold: 101), isFalse);
      expect(canSave(), isTrue);
    });

    test('ST-03: an active announcement needs both languages, an inactive one does not', () {
      expect(SettingsValidator.missingAnnouncement('Hi', '  '), [LessonLanguage.vi]);
      expect(SettingsValidator.missingAnnouncement('', ''), [LessonLanguage.en, LessonLanguage.vi]);
      expect(canSave(vi: ''), isFalse);
      expect(canSave(active: false, en: '', vi: ''), isTrue);
    });

    test('build trims the text and stamps the time', () {
      final AppSettings saved = SettingsValidator.build(
        threshold: 70,
        supportEmail: '  help@pennypal.app ',
        announcementActive: true,
        announcementEn: ' Hello ',
        announcementVi: ' Xin chào ',
        updatedAt: 42,
      );
      expect(saved.defaultAlertThreshold, 70);
      expect(saved.supportEmail, 'help@pennypal.app');
      expect(saved.announcementFor('vi'), 'Xin chào');
      expect(saved.updatedAt, 42);
    });
  });

  group('App settings screen (A11)', () {
    FilledButton saveButton(WidgetTester tester) => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save settings'));

    testWidgets('ST-02: a bad email disables saving', (tester) async {
      useScreen(tester);
      await tester.pumpWidget(buildApp(AppSettingsForm(settings: SampleData.adminData().settings)));

      expect(find.text('80%'), findsOneWidget);
      expect(find.text('English and Vietnamese both filled'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNotNull);

      await tester.enterText(find.byType(TextField).first, 'support@pennypal');
      await tester.pump();
      expect(find.text('Invalid email address'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);
    });

    testWidgets('ST-03: clearing the Vietnamese message blocks saving until the banner is off', (tester) async {
      useScreen(tester);
      await tester.pumpWidget(buildApp(AppSettingsForm(settings: SampleData.adminData().settings)));

      await tester.tap(find.text('Tiếng Việt'));
      await tester.pumpAndSettle();
      expect(find.text('Message (VI)'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '');
      await tester.pump();

      expect(find.text('Add the Vietnamese message before turning the announcement on'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(saveButton(tester).onPressed, isNotNull);
    });
  });
}
