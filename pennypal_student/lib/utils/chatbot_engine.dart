import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/budget.dart';
import '../models/category.dart';
import '../models/chat_message.dart';
import '../models/savings_goal.dart';
import '../models/transaction_record.dart';
import 'budget_calculator.dart';
import 'category_display.dart';
import 'category_keywords.dart';
import 'chat_intent_matcher.dart';
import 'constants.dart';
import 'formatters.dart';
import 'goal_calculator.dart';
import 'report_calculator.dart';
import 'text_normalizer.dart';

class ChatbotData {
  final String userName;
  final List<TransactionRecord> transactions;
  final List<Budget> budgets;
  final List<SavingsGoal> goals;
  final List<Category> customCategories;

  const ChatbotData({
    required this.userName,
    required this.transactions,
    required this.budgets,
    required this.goals,
    required this.customCategories,
  });
}

class ChatbotEngine {
  final ChatbotData data;
  final AppLocalizations l10n;
  final String languageCode;
  final DateTime now;

  ChatbotEngine({required this.data, required this.l10n, required this.languageCode, DateTime? now})
      : now = now ?? DateTime.now();

  DateTime get _month => DateTime(now.year, now.month);

  String get _monthLabel => Formatters.monthLabel(_month, languageCode);

  String _percentText(double value) => '${NumberFormat('0.0', languageCode).format(value)}%';

  ChatMessage _botMessage(String text, {List<String> suggestions = const [], ChatProgress? progress, bool showAddExpense = false}) {
    return ChatMessage(
      isUser: false,
      text: text,
      suggestions: suggestions,
      progress: progress,
      showAddExpense: showAddExpense,
      sentAt: now.millisecondsSinceEpoch,
    );
  }

  List<String> get defaultSuggestions => [l10n.chatChipTop, l10n.chatChipBudget, l10n.chatChipGoal, l10n.chatChipSave];

  ChatMessage welcome() => _botMessage(l10n.chatWelcome(Formatters.givenName(data.userName)));

  ChatMessage reply(String message) {
    final ChatIntent intent = ChatIntentMatcher.detect(message);
    final int? askedMonth = _mentionedMonth(message);
    final bool usesThisMonthData =
        intent == ChatIntent.topSpending || intent == ChatIntent.monthSummary || intent == ChatIntent.budgetRemaining;
    // The answers below only read the current month, so asking about another month must not show this month's numbers.
    final bool asksOtherMonth = (askedMonth != null && askedMonth != now.month) || _mentionsLastMonth(message);
    if (usesThisMonthData && asksOtherMonth) {
      return _botMessage(l10n.chatOnlyThisMonth(_monthLabel));
    }

    return switch (intent) {
      ChatIntent.greeting => welcome(),
      ChatIntent.help => _botMessage(l10n.chatHelp),
      ChatIntent.topSpending => _topSpending(),
      ChatIntent.monthSummary => _monthSummary(message),
      ChatIntent.budgetRemaining => _budgetRemaining(message),
      ChatIntent.goalProgress => _goalProgress(),
      ChatIntent.compareLastMonth => _compareLastMonth(),
      ChatIntent.budgetingTips => _botMessage(l10n.chatBudgetingTips),
      ChatIntent.savingTips => _botMessage(l10n.chatSavingTips),
      ChatIntent.needsVsWants => _botMessage(l10n.chatNeedsWants),
      ChatIntent.unknown => _botMessage(l10n.chatUnknown, suggestions: defaultSuggestions.skip(1).toList()),
    };
  }

  /// "thang 8", "month 8" -> 8; null when no valid month number (1-12) is written.
  int? _mentionedMonth(String message) {
    final RegExpMatch? match = RegExp(r'\b(?:thang|month)\s+(\d{1,2})\b').firstMatch(TextNormalizer.normalize(message));
    if (match == null) return null;
    final int month = int.parse(match.group(1)!);
    return month >= 1 && month <= 12 ? month : null;
  }

  /// "last month" / "tháng trước" (written with or without accents).
  bool _mentionsLastMonth(String message) {
    final String text = TextNormalizer.normalize(message);
    return RegExp(r'\b(last month|thang truoc)\b').hasMatch(text);
  }

  String categoryName(String categoryId) {
    for (final Category category in data.customCategories) {
      if (category.id == categoryId) return category.name ?? '';
    }
    return CategoryDisplay.name(l10n, categoryId);
  }

  String? findCategory(String message) {
    final String text = TextNormalizer.normalize(message).replaceAll('ngan sach', ' ');
    for (final Category category in data.customCategories) {
      final String name = TextNormalizer.normalize(category.name ?? '');
      if (name.isNotEmpty && RegExp('\\b${RegExp.escape(name)}\\b').hasMatch(text)) return category.id;
    }
    return CategoryKeywords.findCategory(text);
  }

  ChatMessage _topSpending() {
    final List<CategoryTotal> byCategory = ReportCalculator.spendingByCategory(data.transactions, _month);
    if (byCategory.isEmpty) return _botMessage(l10n.chatNoSpending(_monthLabel), showAddExpense: true);

    final CategoryTotal top = byCategory.first;
    final String name = categoryName(top.categoryId);
    final String text = l10n.chatTopSpending(_monthLabel, name, Formatters.money(top.amount), _percentText(top.percent));
    final Budget? budget = _budgetFor(top.categoryId);
    final int usedPercent = budget == null ? 0 : BudgetCalculator.percent(top.amount, budget.limitAmount);
    final ChatProgress? progress =
        budget == null ? null : ChatProgress(label: name, percent: usedPercent, caption: l10n.chatPercentOfLimit(usedPercent));
    return _botMessage('$text\n\n${l10n.chatTopTip}', progress: progress);
  }

  /// "How much did I spend on food?" answers for that category; without a category it sums up the whole month.
  ChatMessage _monthSummary(String message) {
    final MonthSummary summary = ReportCalculator.summary(data.transactions, _month);
    if (summary.isEmpty) return _botMessage(l10n.chatNoSpending(_monthLabel), showAddExpense: true);

    final String? categoryId = findCategory(message);
    if (categoryId != null) return _categorySpending(categoryId);

    return _botMessage(l10n.chatMonthSummary(
      _monthLabel,
      Formatters.money(summary.income),
      Formatters.money(summary.spending),
      Formatters.money(summary.savings),
    ));
  }

  /// Spending of one category this month and its share of all spending (savings are not spending).
  ChatMessage _categorySpending(String categoryId) {
    final String month = BudgetCalculator.monthKey(_month);
    final double categorySpent = BudgetCalculator.spent(data.transactions, month, categoryId: categoryId);
    final double totalSpent = BudgetCalculator.spent(data.transactions, month);
    // Only income this month: nothing spent yet, so the share would divide by zero.
    if (totalSpent == 0) return _botMessage(l10n.chatNoSpending(_monthLabel), showAddExpense: true);

    final String share = _percentText(categorySpent / totalSpent * 100);
    return _botMessage(l10n.chatCategorySpending(_monthLabel, Formatters.money(categorySpent), categoryName(categoryId), share));
  }

  Budget? _budgetFor(String? categoryId) {
    final String month = BudgetCalculator.monthKey(_month);
    for (final Budget budget in data.budgets) {
      if (budget.month == month && budget.categoryId == categoryId) return budget;
    }
    return null;
  }

  ChatMessage _budgetRemaining(String message) {
    final String? categoryId = findCategory(message);
    final String name = categoryId == null ? l10n.chatTotalBudgetName : categoryName(categoryId);
    final Budget? budget = _budgetFor(categoryId);
    if (budget == null) return _botMessage(l10n.chatNoBudget(name, _monthLabel));

    final double spent = BudgetCalculator.spent(data.transactions, budget.month, categoryId: categoryId);
    final int percent = BudgetCalculator.percent(spent, budget.limitAmount);
    final double left = BudgetCalculator.remaining(spent, budget.limitAmount);
    final String text = left < 0
        ? l10n.chatBudgetOver(name, _monthLabel, Formatters.money(-left), percent)
        : l10n.chatBudgetLeft(name, _monthLabel, Formatters.money(left), Formatters.money(budget.limitAmount), percent);
    return _botMessage(text, progress: ChatProgress(label: name, percent: percent, caption: l10n.chatPercentOfLimit(percent)));
  }

  ChatMessage _goalProgress() {
    final List<SavingsGoal> active = GoalCalculator.goalsWithStatus(data.goals, GoalStatuses.active)
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
    if (active.isEmpty) return _botMessage(l10n.chatNoGoal);

    final SavingsGoal goal = active.first;
    final int? months = GoalCalculator.monthsLeft(goal.remainingAmount, goal.monthlyContribution);
    final DateTime? estimated = GoalCalculator.estimatedDate(months, now: now);
    final String due = Formatters.monthYear(goal.targetDate);
    final String pace = switch (GoalCalculator.pace(estimated, DateTime.fromMillisecondsSinceEpoch(goal.targetDate))) {
      GoalPace.onTrack => l10n.chatPaceOnTrack(Formatters.monthYear(estimated!.millisecondsSinceEpoch)),
      GoalPace.behind => l10n.chatPaceBehind(Formatters.monthYear(estimated!.millisecondsSinceEpoch), due),
      GoalPace.unknown => l10n.chatPaceUnknown,
    };
    final int percent = GoalCalculator.percentOf(goal.progress);
    return _botMessage(
      l10n.chatGoalProgress(goal.name, Formatters.money(goal.currentAmount), Formatters.money(goal.targetAmount), percent, pace),
      progress: ChatProgress(label: goal.name, percent: percent, caption: '$percent%'),
    );
  }

  /// This month so far against the same days of last month (day 1 to today's day),
  /// so on the 5th it compares 5 days with 5 days, not 5 days with a whole month.
  ChatMessage _compareLastMonth() {
    final DateTime lastMonth = DateTime(_month.year, _month.month - 1);
    final double current = _spendingUntilDay(_month, now.day);
    final double last = _spendingUntilDay(lastMonth, now.day);
    if (last == 0) return _botMessage(l10n.chatCompareNoLast(Formatters.money(current)));
    if (current == last) return _botMessage(l10n.chatCompareSame(Formatters.money(current)));

    final double change = (current - last) / last * 100;
    final String percent = _percentText(change.abs());
    return _botMessage(change > 0
        ? l10n.chatCompareMore(Formatters.money(current), Formatters.money(last), percent)
        : l10n.chatCompareLess(Formatters.money(current), Formatters.money(last), percent));
  }

  /// Spending of [month] from day 1 to [lastDay]. A day past the month's end (31 in a 30-day month) counts the whole month.
  /// Same rule as BudgetCalculator.spent: only expenses, money put into goals is not spending.
  double _spendingUntilDay(DateTime month, int lastDay) {
    double total = 0;
    for (final TransactionRecord transaction in data.transactions) {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(transaction.date);
      final bool isSpending = transaction.type == TransactionTypes.expense && transaction.categoryId != CategoryKeys.savings;
      final bool isInMonth = date.year == month.year && date.month == month.month;
      if (isSpending && isInMonth && date.day <= lastDay) total += transaction.amount;
    }
    return total;
  }
}
