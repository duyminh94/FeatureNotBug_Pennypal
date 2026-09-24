import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/utils/app_theme.dart';
import 'package:pennypal_student/widgets/app_progress_bar.dart';
import 'package:pennypal_student/widgets/category_icon.dart';
import 'package:pennypal_student/widgets/confirm_dialog.dart';
import 'package:pennypal_student/widgets/empty_state.dart';
import 'package:pennypal_student/widgets/error_state.dart';
import 'package:pennypal_student/widgets/month_picker.dart';

/// Wraps a widget with the app theme and localizations for testing.
Widget buildTestApp(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('vi')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('ErrorState shows Vietnamese text and calls onRetry',
      (tester) async {
    int retryCount = 0;
    await tester.pumpWidget(buildTestApp(
      ErrorState(onRetry: () => retryCount++),
      locale: const Locale('vi'),
    ));

    expect(find.text('Đã có lỗi, vui lòng thử lại'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    expect(retryCount, 1);
  });

  testWidgets('EmptyState hides the button when there is no action',
      (tester) async {
    await tester.pumpWidget(buildTestApp(
      const EmptyState(icon: Icons.inbox, message: 'No data yet'),
    ));

    expect(find.text('No data yet'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('ConfirmDialog returns true on confirm and false on cancel',
      (tester) async {
    bool? result;
    await tester.pumpWidget(buildTestApp(Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          result = await showConfirmDialog(context, message: 'Delete?');
        },
        child: const Text('open'),
      ),
    )));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('MonthPicker moves to the previous month across the year',
      (tester) async {
    DateTime? picked;
    await tester.pumpWidget(buildTestApp(
      MonthPicker(
          month: DateTime(2026, 1), onChanged: (value) => picked = value),
    ));

    await tester.tap(find.byTooltip('Previous month'));
    expect(picked, DateTime(2025, 12));
  });

  testWidgets('AppProgressBar clamps values above 100%', (tester) async {
    await tester.pumpWidget(buildTestApp(const AppProgressBar(value: 1.5)));

    final bar = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(bar.value, 1.0);
  });

  test('Unknown icon name falls back to the generic category icon', () {
    expect(categoryIconData('restaurant'), Icons.restaurant);
    expect(categoryIconData('not_a_real_icon'), Icons.category);
  });
}
