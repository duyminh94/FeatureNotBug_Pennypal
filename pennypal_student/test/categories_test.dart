import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/budget.dart';
import 'package:pennypal_student/models/category.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/screens/categories/categories_screen.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/utils/category_display.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:pennypal_student/utils/validators.dart';
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

Category gymCategory() {
  return Category(id: 'cat_gym', type: TransactionTypes.expense, icon: 'fitness_center', sortOrder: 100, isDefault: false, name: 'Gym');
}

TransactionRecord gymExpense() {
  return TransactionRecord(
    id: 'tx1',
    type: TransactionTypes.expense,
    amount: 300000,
    categoryId: 'cat_gym',
    date: DateTime.now().millisecondsSinceEpoch,
  );
}

void main() {
  group('CategoryDisplay and Validators with custom categories', () {
    tearDown(() => CategoryDisplay.customCategories = []);

    test('a custom category shows its own name and icon', () {
      CategoryDisplay.customCategories = [gymCategory()];
      final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

      expect(CategoryDisplay.name(l10n, 'cat_gym'), 'Gym');
      expect(CategoryDisplay.iconName('cat_gym'), 'fitness_center');
      expect(CategoryDisplay.name(l10n, CategoryKeys.food), 'Food');
    });

    test('a custom category can be picked only for its own type', () {
      CategoryDisplay.customCategories = [gymCategory()];

      expect(CategoryDisplay.selectableIds(TransactionTypes.expense), contains('cat_gym'));
      expect(CategoryDisplay.selectableIds(TransactionTypes.income), isNot(contains('cat_gym')));
      expect(Validators.isCategoryAllowed('cat_gym', TransactionTypes.expense), isTrue);
      expect(Validators.isCategoryAllowed('cat_gym', TransactionTypes.income), isFalse);
    });

    test('an unknown id is not allowed after the categories are cleared (logout)', () {
      CategoryDisplay.customCategories = [gymCategory()];
      CategoryDisplay.customCategories = [];

      expect(Validators.isCategoryAllowed('cat_gym', TransactionTypes.expense), isFalse);
    });
  });

  group('CategoriesScreen', () {
    Future<void> openScreen(
      WidgetTester tester, {
      required List<TransactionRecord> transactions,
      required List<Category> deleted,
      List<Category>? saved,
    }) async {
      await tester.pumpWidget(buildTestApp(CategoriesScreen(
        uid: 'student1',
        watchCategories: (uid) => Stream.value([gymCategory()]),
        watchTransactions: (uid) => Stream.value(transactions),
        watchBudgets: (uid) => Stream.value(<Budget>[]),
        saveCategory: (category) => saved?.add(category),
        deleteCategory: deleted.add,
      )));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the categories saved in Firebase, not sample data', (tester) async {
      await openScreen(tester, transactions: [], deleted: []);

      expect(find.text('Gym'), findsOneWidget);
      expect(find.text('Coffee'), findsNothing);
    });

    testWidgets('a category in use cannot be deleted', (tester) async {
      final List<Category> deleted = [];
      await openScreen(tester, transactions: [gymExpense()], deleted: deleted);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      expect(find.textContaining("can't be deleted"), findsOneWidget);
      expect(deleted, isEmpty);
    });

    testWidgets('an unused category is deleted after confirming', (tester) async {
      final List<Category> deleted = [];
      await openScreen(tester, transactions: [], deleted: deleted);

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(deleted.single.id, 'cat_gym');
    });

    testWidgets('a new category is saved with the typed name', (tester) async {
      final List<Category> saved = [];
      await openScreen(tester, transactions: [], deleted: [], saved: saved);

      await tester.tap(find.byTooltip('Add category'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Coffee');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Save category'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save category'));
      await tester.pumpAndSettle();

      expect(saved.single.name, 'Coffee');
      expect(saved.single.isDefault, isFalse);
    });

    testWidgets('a loading error shows Retry', (tester) async {
      await tester.pumpWidget(buildTestApp(CategoriesScreen(
        uid: 'student1',
        watchCategories: (uid) => Stream.error('offline'),
        watchTransactions: (uid) => Stream.value(<TransactionRecord>[]),
        watchBudgets: (uid) => Stream.value(<Budget>[]),
      )));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorState), findsOneWidget);
    });
  });
}
