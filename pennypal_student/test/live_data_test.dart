import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:pennypal_student/models/budget.dart';
import 'package:pennypal_student/models/savings_goal.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/screens/chatbot/screen.dart';
import 'package:pennypal_student/screens/reports/screen.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/widgets/error_state.dart';

Widget buildTestApp(Widget screen) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('en'),
    supportedLocales: const [Locale('en'), Locale('vi')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: screen,
  );
}

void main() {
  group('ReportsScreen live data', () {
    testWidgets('shows a new transaction without reopening the screen', (tester) async {
      final StreamController<List<TransactionRecord>> transactionController = StreamController();
      await tester.pumpWidget(buildTestApp(ReportsScreen(
        uid: 'student1',
        watchTransactions: (uid) => transactionController.stream,
        watchBudgets: (uid) => Stream.value(<Budget>[]),
      )));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      transactionController.add([]);
      await tester.pumpAndSettle();
      expect(find.text('Not enough data'), findsOneWidget);

      final TransactionRecord lunch = TransactionRecord(
        id: 'tx1',
        type: TransactionTypes.expense,
        amount: 50000,
        categoryId: CategoryKeys.food,
        date: DateTime.now().millisecondsSinceEpoch,
      );
      transactionController.add([lunch]);
      await tester.pumpAndSettle();
      expect(find.text('Not enough data'), findsNothing);

      await transactionController.close();
    });

    testWidgets('network error shows Retry instead of crashing', (tester) async {
      await tester.pumpWidget(buildTestApp(ReportsScreen(
        uid: 'student1',
        watchTransactions: (uid) => Stream.error('offline'),
        watchBudgets: (uid) => Stream.value(<Budget>[]),
      )));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
    });
  });

  group('ChatbotScreen live data', () {
    testWidgets('data error: tips still answer, number questions say data failed', (tester) async {
      await tester.pumpWidget(buildTestApp(ChatbotScreen(
        uid: 'student1',
        userName: 'Minh',
        watchTransactions: (uid) => Stream.error('offline'),
        watchBudgets: (uid) => Stream.error('offline'),
        watchGoals: (uid) => Stream.error('offline'),
      )));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'How can I save money?');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_outlined));
      await tester.pumpAndSettle();
      expect(find.textContaining('Save a fixed part', skipOffstage: false), findsOneWidget);

      await tester.tap(find.widgetWithText(ActionChip, 'What did I spend most on?'));
      await tester.pumpAndSettle();
      expect(find.textContaining("I couldn't load your data", skipOffstage: false), findsOneWidget);
    });

    testWidgets('answers with the newest data after a transaction is added', (tester) async {
      final StreamController<List<TransactionRecord>> transactionController = StreamController();
      await tester.pumpWidget(buildTestApp(ChatbotScreen(
        uid: 'student1',
        userName: 'Minh',
        watchTransactions: (uid) => transactionController.stream,
        watchBudgets: (uid) => Stream.value(<Budget>[]),
        watchGoals: (uid) => Stream.value(<SavingsGoal>[]),
      )));
      await tester.pump();

      await tester.tap(find.widgetWithText(ActionChip, 'What did I spend most on?'));
      await tester.pump();
      expect(find.textContaining('still loading your data', skipOffstage: false), findsOneWidget);

      transactionController.add([
        TransactionRecord(
          id: 'tx1',
          type: TransactionTypes.expense,
          amount: 50000,
          categoryId: CategoryKeys.food,
          date: DateTime.now().millisecondsSinceEpoch,
        ),
      ]);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ActionChip, 'What did I spend most on?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Food'), findsWidgets);

      await transactionController.close();
    });
  });
}
