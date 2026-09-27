import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/recurring_item.dart';
import 'package:pennypal_student/screens/recurring/recurring_screen.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/recurring_calculator.dart';

RecurringItem item(String id, {String description = 'Room rent', int day = 5, String lastCreatedMonth = '2026-09', bool isActive = true}) {
  return RecurringItem(
    id: id,
    type: TransactionTypes.expense,
    amount: 2000000,
    categoryId: CategoryKeys.miscellaneous,
    description: description,
    dayOfMonth: day,
    lastCreatedMonth: lastCreatedMonth,
    isActive: isActive,
  );
}

void main() {
  group('RecurringCalculator.monthKeyOnResume', () {
    test('day already passed this month: continue from next month, stopped months are skipped', () {
      final RecurringItem stopped = item('rent', day: 5, isActive: false);
      expect(RecurringCalculator.monthKeyOnResume(stopped, DateTime(2026, 12, 10)), '2026-12');
    });

    test('day still ahead this month: this month is still created, nothing before it', () {
      final RecurringItem stopped = item('rent', day: 20, isActive: false);
      final String month = RecurringCalculator.monthKeyOnResume(stopped, DateTime(2026, 12, 10));
      expect(month, '2026-11');

      final RecurringItem resumed = item('rent', day: 20, lastCreatedMonth: month);
      expect(RecurringCalculator.datesToCreate(resumed, DateTime(2026, 12, 20)), [DateTime(2026, 12, 20)]);
    });

    test('never moves the month backwards', () {
      final RecurringItem stopped = item('rent', day: 20, lastCreatedMonth: '2026-12', isActive: false);
      expect(RecurringCalculator.monthKeyOnResume(stopped, DateTime(2026, 12, 3)), '2026-12');
    });
  });

  group('RecurringScreen', () {
    late List<String> deleted;
    late List<MapEntry<String, Map<String, Object?>>> updates;

    Future<void> openScreen(WidgetTester tester, List<RecurringItem> items) async {
      deleted = [];
      updates = [];
      tester.view.physicalSize = const Size(600, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('vi')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: RecurringScreen(
          uid: 'u1',
          watchItems: (uid) => Stream.value(items),
          updateItem: (itemId, fields) => updates.add(MapEntry(itemId, fields)),
          deleteItem: (itemId) => deleted.add(itemId),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('no items shows how to create one', (tester) async {
      await openScreen(tester, []);
      expect(find.textContaining('No fixed items yet.'), findsOneWidget);
    });

    testWidgets('shows name, amount, day and the stopped label', (tester) async {
      await openScreen(tester, [item('rent'), item('gym', description: 'Gym', day: 31, isActive: false)]);
      expect(find.text('Room rent'), findsOneWidget);
      expect(find.textContaining('day 5 every month'), findsOneWidget);
      expect(find.textContaining('day 31 every month · Stopped'), findsOneWidget);
    });

    testWidgets('switch off stops the item, switch on resumes it with a new month', (tester) async {
      await openScreen(tester, [item('rent'), item('gym', description: 'Gym', isActive: false)]);

      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      expect(updates.last.key, 'rent');
      expect(updates.last.value, {DbFields.isActive: false});

      await tester.tap(find.byType(Switch).last);
      await tester.pump();
      expect(updates.last.key, 'gym');
      expect(updates.last.value[DbFields.isActive], isTrue);
      expect(updates.last.value[DbFields.lastCreatedMonth], isA<String>());
    });

    testWidgets('change amount: 0 is refused, a valid amount is saved', (tester) async {
      await openScreen(tester, [item('rent')]);

      await tester.tap(find.text('Change amount'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(updates, isEmpty);
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '2500000');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(updates.single.key, 'rent');
      expect(updates.single.value, {DbFields.amount: 2500000.0});
    });

    testWidgets('fits on a 360px phone with a long note', (tester) async {
      await openScreen(tester, [item('gym', description: 'Monthly gym membership at the university', day: 31, isActive: false)]);
      tester.view.physicalSize = const Size(360, 1600);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('delete asks first, then deletes', (tester) async {
      await openScreen(tester, [item('rent')]);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(deleted, isEmpty);
      await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('Delete')));
      await tester.pumpAndSettle();
      expect(deleted, ['rent']);
    });
  });
}
