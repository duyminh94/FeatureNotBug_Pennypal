import 'budget_plan_proposal.dart';

class ChatProgress {
  final String label;
  final int percent;
  final String caption;

  const ChatProgress({required this.label, required this.percent, required this.caption});
}

class ChatMessage {
  final bool isUser;
  final String text;
  final List<String> suggestions;
  final ChatProgress? progress;
  final bool showAddExpense;
  final BudgetPlanProposal? budgetPlan;
  final int sentAt;

  const ChatMessage({
    required this.isUser,
    required this.text,
    this.suggestions = const [],
    this.progress,
    this.showAddExpense = false,
    this.budgetPlan,
    required this.sentAt,
  });
}
