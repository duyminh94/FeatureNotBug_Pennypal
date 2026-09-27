import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/screens/transactions/transaction_form_screen.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/utils/constants.dart';

void main() {
  Future<void> openForm(WidgetTester tester, {TransactionRecord? initial}) async {
    tester.view.physicalSize = const Size(600, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('vi')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: TransactionFormScreen(type: TransactionTypes.expense, initial: initial),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a new transaction has the repeat switch, off by default, with the day of the month', (tester) async {
    await openForm(tester);
    final int today = DateTime.now().day;

    expect(find.text('Repeat every month'), findsOneWidget);
    expect(find.textContaining('Added automatically on day $today of each month.'), findsOneWidget);

    SwitchListTile repeatSwitch = tester.widget(find.byType(SwitchListTile));
    expect(repeatSwitch.value, isFalse);

    await tester.tap(find.text('Repeat every month'));
    await tester.pump();
    repeatSwitch = tester.widget(find.byType(SwitchListTile));
    expect(repeatSwitch.value, isTrue);
  });

  testWidgets('editing a transaction has no repeat switch', (tester) async {
    final TransactionRecord rent = TransactionRecord(
      id: 't1',
      type: TransactionTypes.expense,
      amount: 2000000,
      categoryId: CategoryKeys.miscellaneous,
      date: DateTime.now().millisecondsSinceEpoch,
    );
    await openForm(tester, initial: rent);
    expect(find.text('Repeat every month'), findsNothing);
  });
}
