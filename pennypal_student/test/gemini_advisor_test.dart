import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_student/models/budget_plan_proposal.dart';
import 'package:pennypal_student/models/recurring_item.dart';
import 'package:pennypal_student/models/savings_goal.dart';
import 'package:pennypal_student/models/transaction_record.dart';
import 'package:pennypal_student/services/gemini_advisor_service.dart';
import 'package:pennypal_student/utils/chat_intent_matcher.dart';
import 'package:pennypal_student/utils/chatbot_engine.dart';
import 'package:pennypal_student/utils/constants.dart';

void main() {
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

      // Check category items contain food, transport, etc.
      final categories = plan.items.map((i) => i.categoryId).toSet();
      expect(categories.contains(CategoryKeys.food), isTrue);
      expect(categories.contains(CategoryKeys.transport), isTrue);
    });
  });

  group('BudgetPlanProposal model serialization', () {
    test('toMap and fromMap preserves all fields', () {
      final proposal = BudgetPlanProposal(
        month: '2026-09',
        estimatedIncome: 5000000,
        fixedExpensesTotal: 1200000,
        savingsTotal: 300000,
        items: [
          BudgetPlanItem(
            categoryId: 'food',
            categoryName: 'Ăn uống',
            amount: 1500000,
            note: 'Cơm trưa',
          ),
          BudgetPlanItem(
            categoryId: 'transport',
            categoryName: 'Đi lại',
            amount: 300000,
            note: 'Xăng xe',
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
      expect(revived.items.length, 2);
      expect(revived.items[0].categoryId, 'food');
      expect(revived.items[0].amount, 1500000);
      expect(revived.totalPlanned, 1800000);
    });
  });
}
