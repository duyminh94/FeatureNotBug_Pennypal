import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/budget_plan_proposal.dart';
import 'package:pennypal_student/models/recurring_item.dart';
import 'package:pennypal_student/models/savings_goal.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/controllers/gemini_advisor_service.dart';
import 'package:pennypal_student/utils/chat_intent_matcher.dart';
import 'package:pennypal_student/utils/chatbot_engine.dart';
import 'package:pennypal_student/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('ChatIntentMatcher budget planning detection', () {
    test('detects Vietnamese planning phrases', () {
      expect(ChatIntentMatcher.detect('Lập kế hoạch chi tiêu tháng này'), ChatIntent.planBudget);
      expect(ChatIntentMatcher.detect('lap ke hoach chi tieu'), ChatIntent.planBudget);
      expect(ChatIntentMatcher.detect('chia tiền tháng này giúp tôi'), ChatIntent.planBudget);
      expect(ChatIntentMatcher.detect('phân bổ ngân sách'), ChatIntent.planBudget);
    });

    test('detects English planning phrases', () {
      expect(ChatIntentMatcher.detect('plan my budget for this month'), ChatIntent.planBudget);
      expect(ChatIntentMatcher.detect('budget plan please'), ChatIntent.planBudget);
    });
  });

  group('GeminiAdvisorService.isBudgetPlanningRequest', () {
    test('returns true for planning queries', () {
      expect(GeminiAdvisorService.isBudgetPlanningRequest('Lập kế hoạch chi tiêu'), isTrue);
      expect(GeminiAdvisorService.isBudgetPlanningRequest('ngân sách tháng này'), isTrue);
      expect(GeminiAdvisorService.isBudgetPlanningRequest('chia tiền'), isTrue);
      expect(GeminiAdvisorService.isBudgetPlanningRequest('create a budget plan'), isTrue);
    });

    test('returns false for general chit chat or other queries', () {
      expect(GeminiAdvisorService.isBudgetPlanningRequest('Xin chào'), isFalse);
      expect(GeminiAdvisorService.isBudgetPlanningRequest('Hôm nay ăn gì?'), isFalse);
    });
  });

  group('GeminiAdvisorService heuristic budget planning', () {
    test('generates valid budget proposal based on income, fixed recurring items, and goals', () {
      final List<TransactionRecord> transactions = [
        TransactionRecord(
          id: 'inc1',
          type: TransactionTypes.income,
          amount: 6000000,
          categoryId: CategoryKeys.allowance,
          date: DateTime.now().millisecondsSinceEpoch,
        ),
      ];

      final List<RecurringItem> recurringItems = [
        RecurringItem(
          id: 'rec1',
          type: TransactionTypes.expense,
          amount: 1500000,
          categoryId: CategoryKeys.bills,
          description: 'Tiền phòng trọ',
          dayOfMonth: 5,
          lastCreatedMonth: '2026-09',
        ),
      ];

      final List<SavingsGoal> goals = [
        SavingsGoal(
          id: 'goal1',
          name: 'Mua laptop',
          targetAmount: 12000000,
          currentAmount: 2000000,
          targetDate: DateTime.now().add(const Duration(days: 180)).millisecondsSinceEpoch,
          monthlyContribution: 500000,
          status: GoalStatuses.active,
        ),
      ];

      final data = ChatbotData(
        userName: 'Khoa',
        transactions: transactions,
        budgets: [],
        goals: goals,
        customCategories: [],
        recurringItems: recurringItems,
      );

      final plan = GeminiAdvisorService.generateHeuristicPlan(
        data: data,
        month: '2026-09',
      );

      expect(plan.month, '2026-09');
      expect(plan.estimatedIncome, 6000000);
      expect(plan.fixedExpensesTotal, 1500000);
      expect(plan.savingsTotal, 500000);
      expect(plan.items, isNotEmpty);
      expect(plan.totalPlanned, greaterThan(0));

      final categories = plan.items.map((i) => i.categoryId).toSet();
      expect(categories.contains(CategoryKeys.food), isTrue);
      expect(categories.contains(CategoryKeys.transport), isTrue);
    });
  });

  group('GeminiAdvisorService backend API key', () {
    test('getApiKey returns default backend key when no custom key configured', () async {
      final key = await GeminiAdvisorService.getApiKey();
      expect(key.startsWith('AQ.'), isTrue);
      expect(key.length, 53);
      expect(await GeminiAdvisorService.isConfigured(), isTrue);
    });
  });

  group('GeminiAdvisorService.parseTargetMonth', () {
    final now = DateTime(2026, 9, 28);

    test('parses relative future month keywords', () {
      expect(GeminiAdvisorService.parseTargetMonth('kế hoạch tháng sau', now), '2026-10');
      expect(GeminiAdvisorService.parseTargetMonth('lập chi tiêu tháng tới', now), '2026-10');
      expect(GeminiAdvisorService.parseTargetMonth('plan next month', now), '2026-10');
    });

    test('parses specific month numbers', () {
      expect(GeminiAdvisorService.parseTargetMonth('lập chi tiêu tháng 10', now), '2026-10');
      expect(GeminiAdvisorService.parseTargetMonth('kế hoạch tháng 11', now), '2026-11');
      expect(GeminiAdvisorService.parseTargetMonth('tháng 12/2026', now), '2026-12');
      expect(GeminiAdvisorService.parseTargetMonth('tháng 1/2027', now), '2027-01');
    });

    test('uses fallbackMonth when query does not specify month', () {
      expect(GeminiAdvisorService.parseTargetMonth('thu nhập 5 triệu', now, fallbackMonth: '2026-10'), '2026-10');
    });

    test('defaults to current month if unspecified and no fallback', () {
      expect(GeminiAdvisorService.parseTargetMonth('chia tiền giúp tôi', now), '2026-09');
    });
  });

  group('GeminiAdvisorService.parseIncomeFromQuery', () {
    test('parses various Vietnamese income expressions', () {
      expect(GeminiAdvisorService.parseIncomeFromQuery('thu nhập 5 triệu'), 5000000.0);
      expect(GeminiAdvisorService.parseIncomeFromQuery('thu nhập 6tr'), 6000000.0);
      expect(GeminiAdvisorService.parseIncomeFromQuery('lương 5.5 triệu'), 5500000.0);
      expect(GeminiAdvisorService.parseIncomeFromQuery('thu nhập 5tr5'), 5500000.0);
      expect(GeminiAdvisorService.parseIncomeFromQuery('thu nhập 5 triệu 500k'), 5500000.0);
      expect(GeminiAdvisorService.parseIncomeFromQuery('lương 6.000.000'), 6000000.0);
      expect(GeminiAdvisorService.parseIncomeFromQuery('thu nhập 4500000'), 4500000.0);
      expect(GeminiAdvisorService.parseIncomeFromQuery('Thu nhập tháng 10 là 5 triệu'), 5000000.0);
    });

    test('returns null when no valid income amount is present', () {
      expect(GeminiAdvisorService.parseIncomeFromQuery('lập kế hoạch chi tiêu'), isNull);
      expect(GeminiAdvisorService.parseIncomeFromQuery('năm 2026 có gì mới?'), isNull);
    });
  });

  group('GeminiAdvisorService future month missing income prompt', () {
    test('asks for expected income with suggestions when planning for future month without data', () async {
      final now = DateTime(2026, 9, 28);
      final data = ChatbotData(
        userName: 'Khoa',
        transactions: [],
        budgets: [],
        goals: [],
        customCategories: [],
        recurringItems: [],
      );

      final response = await GeminiAdvisorService.generateResponse(
        query: 'Lập kế hoạch tháng 10',
        data: data,
        languageCode: 'vi',
        now: now,
      );

      expect(response.budgetPlan, isNull);
      expect(response.pendingMonth, '2026-10');
      expect(response.text, contains('thu nhập'));
      expect(response.suggestions, isNotEmpty);
      expect(response.suggestions.any((s) => s.contains('tháng 10')), isTrue);
    });
  });

  group('GeminiAdvisorService deficit handling', () {
    test('detects deficit when income is lower than fixed expenses', () {
      final List<RecurringItem> recurringItems = [
        RecurringItem(
          id: 'rec1',
          type: TransactionTypes.expense,
          amount: 3000000,
          categoryId: CategoryKeys.bills,
          description: 'Tiền phòng trọ + điện nước',
          dayOfMonth: 5,
          lastCreatedMonth: '2026-09',
        ),
      ];

      final data = ChatbotData(
        userName: 'Khoa',
        transactions: [],
        budgets: [],
        goals: [
          SavingsGoal(
            id: 'g1',
            name: 'Quỹ tiết kiệm',
            targetAmount: 5000000,
            currentAmount: 1000000,
            targetDate: DateTime.now().add(const Duration(days: 90)).millisecondsSinceEpoch,
            monthlyContribution: 500000,
            status: GoalStatuses.active,
          ),
        ],
        customCategories: [],
        recurringItems: recurringItems,
      );

      final plan = GeminiAdvisorService.generateHeuristicPlan(
        data: data,
        month: '2026-10',
        incomeOverride: 2000000,
      );

      expect(plan.isDeficit, isTrue);
      expect(plan.deficitAmount, 1000000.0);
      expect(plan.savingsTotal, 0.0);

      final shoppingItem = plan.items.firstWhere((i) => i.categoryId == CategoryKeys.shopping);
      final entertainmentItem = plan.items.firstWhere((i) => i.categoryId == CategoryKeys.entertainment);
      expect(shoppingItem.amount, 0.0);
      expect(entertainmentItem.amount, 0.0);
      expect(shoppingItem.note, contains('Tạm ngưng'));
    });
  });

  group('BudgetPlanProposal model serialization', () {
    test('toMap and fromMap preserves all fields including deficit', () {
      final proposal = BudgetPlanProposal(
        month: '2026-10',
        estimatedIncome: 2000000,
        fixedExpensesTotal: 3000000,
        savingsTotal: 0,
        items: [
          BudgetPlanItem(
            categoryId: 'food',
            categoryName: 'Ăn uống',
            amount: 800000,
            note: 'Ăn uống sinh tồn',
          ),
        ],
        isApplied: false,
      );

      final map = proposal.toMap();
      final revived = BudgetPlanProposal.fromMap(map);

      expect(revived.month, proposal.month);
      expect(revived.estimatedIncome, proposal.estimatedIncome);
      expect(revived.fixedExpensesTotal, proposal.fixedExpensesTotal);
      expect(revived.savingsTotal, proposal.savingsTotal);
      expect(revived.items.length, 1);
      expect(revived.items[0].categoryId, 'food');
      expect(revived.items[0].amount, 800000);
      expect(revived.isDeficit, isTrue);
      expect(revived.deficitAmount, 1000000.0);
    });
  });
}
