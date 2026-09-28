import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/budget.dart';
import '../../models/budget_plan_proposal.dart';
import '../../models/chat_message.dart';
import '../../models/recurring_item.dart';
import '../../models/savings_goal.dart';
import '../../models/transaction_record.dart';
import '../../controllers/budget_service.dart';
import '../../controllers/gemini_advisor_service.dart';
import '../../controllers/goal_service.dart';
import '../../controllers/recurring_service.dart';
import '../../controllers/transaction_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/chat_intent_matcher.dart';
import '../../utils/chatbot_engine.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/category_icon.dart';
import '../transactions/form_screen.dart';

/// Answers from live Firebase data and optional Gemini AI.
/// If data fails or Gemini is unavailable, falls back gracefully to offline engine.
class ChatbotScreen extends StatefulWidget {
  final String uid;
  final String userName;
  final Stream<List<TransactionRecord>> Function(String uid) watchTransactions;
  final Stream<List<Budget>> Function(String uid) watchBudgets;
  final Stream<List<SavingsGoal>> Function(String uid) watchGoals;
  final Stream<List<RecurringItem>> Function(String uid) watchRecurring;

  const ChatbotScreen({
    super.key,
    required this.uid,
    required this.userName,
    this.watchTransactions = TransactionService.watch,
    this.watchBudgets = BudgetService.watch,
    this.watchGoals = GoalService.watch,
    this.watchRecurring = _defaultWatchRecurring,
  });

  static Stream<List<RecurringItem>> _defaultWatchRecurring(String uid) {
    try {
      return RecurringService.watch(uid);
    } catch (_) {
      return Stream.value(<RecurringItem>[]);
    }
  }

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  List<TransactionRecord> _transactions = [];
  List<Budget> _budgets = [];
  List<SavingsGoal> _goals = [];
  List<RecurringItem> _recurringItems = [];

  bool _hasTransactions = false;
  bool _hasBudgets = false;
  bool _hasGoals = false;
  bool _hasError = false;
  bool _isAiTyping = false;
  bool _hasConfiguredGemini = false;
  String? _pendingPlanMonth;

  StreamSubscription<List<TransactionRecord>>? _transactionSubscription;
  StreamSubscription<List<Budget>>? _budgetSubscription;
  StreamSubscription<List<SavingsGoal>>? _goalSubscription;
  StreamSubscription<List<RecurringItem>>? _recurringSubscription;

  bool get _isLoading => !_hasTransactions || !_hasBudgets || !_hasGoals;

  ChatbotEngine _engine() {
    final ChatbotData data = ChatbotData(
      userName: widget.userName,
      transactions: _transactions,
      budgets: _budgets,
      goals: _goals,
      customCategories: CategoryDisplay.customCategories,
      recurringItems: _recurringItems,
    );
    return ChatbotEngine(
      data: data,
      l10n: AppLocalizations.of(context)!,
      languageCode: Localizations.localeOf(context).languageCode,
    );
  }

  @override
  void initState() {
    super.initState();
    _checkGeminiConfig();
    _listenData();
  }

  void _checkGeminiConfig() {
    GeminiAdvisorService.isConfigured().then((configured) {
      if (mounted) setState(() => _hasConfiguredGemini = configured);
    }).catchError((_) {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) _messages.add(_engine().welcome());
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    _budgetSubscription?.cancel();
    _goalSubscription?.cancel();
    _recurringSubscription?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _listenData() {
    _transactionSubscription?.cancel();
    _budgetSubscription?.cancel();
    _goalSubscription?.cancel();
    _recurringSubscription?.cancel();
    _hasError = false;

    try {
      _transactionSubscription = widget.watchTransactions(widget.uid).listen(
        (transactions) => setState(() {
          _transactions = transactions;
          _hasTransactions = true;
        }),
        onError: _onDataError,
      );
      _budgetSubscription = widget.watchBudgets(widget.uid).listen(
        (budgets) => setState(() {
          _budgets = budgets;
          _hasBudgets = true;
        }),
        onError: _onDataError,
      );
      _goalSubscription = widget.watchGoals(widget.uid).listen(
        (goals) => setState(() {
          _goals = goals;
          _hasGoals = true;
        }),
        onError: _onDataError,
      );
      try {
        _recurringSubscription = widget.watchRecurring(widget.uid).listen(
          (items) => setState(() {
            _recurringItems = items;
          }),
          onError: (err) => debugPrint('Recurring items watch failed: $err'),
        );
      } catch (err) {
        debugPrint('Recurring items watch init error: $err');
      }
    } catch (e) {
      _onDataError(e);
    }
  }

  void _onDataError(Object error) {
    debugPrint('ChatbotScreen data failed: $error');
    if (!mounted) return;
    setState(() => _hasError = true);
  }

  bool _needsUserData(ChatIntent intent) {
    return intent == ChatIntent.topSpending ||
        intent == ChatIntent.monthSummary ||
        intent == ChatIntent.budgetRemaining ||
        intent == ChatIntent.goalProgress ||
        intent == ChatIntent.compareLastMonth ||
        intent == ChatIntent.planBudget;
  }

  ChatMessage _answerFor(String text) {
    final l10n = AppLocalizations.of(context)!;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final bool needsData = _needsUserData(ChatIntentMatcher.detect(text));

    if (needsData && _hasError) {
      _listenData();
      return ChatMessage(isUser: false, text: l10n.chatDataFailed, sentAt: now);
    }
    if (needsData && _isLoading) return ChatMessage(isUser: false, text: l10n.chatDataLoading, sentAt: now);
    return _engine().reply(text);
  }

  void _send(String text) {
    if (!ChatIntentMatcher.canSend(text)) return;

    final String query = text.trim();
    final bool isPlanning = GeminiAdvisorService.isBudgetPlanningRequest(query);
    final ChatIntent intent = ChatIntentMatcher.detect(query);

    // If budget planning or unknown intent with configured Gemini, use async AI
    final bool shouldUseAi = isPlanning || (_hasConfiguredGemini && intent == ChatIntent.unknown);

    if (shouldUseAi) {
      _sendAsync(query);
      return;
    }

    // Default fast synchronous flow for offline / local engine (preserves exact test semantics)
    final ChatMessage question = ChatMessage(
      isUser: true,
      text: query,
      sentAt: DateTime.now().millisecondsSinceEpoch,
    );
    final ChatMessage answer = _answerFor(query);
    _inputController.clear();
    setState(() => _messages.addAll([question, answer]));
    _scrollToBottom();
  }

  Future<void> _sendAsync(String query) async {
    final ChatMessage userMsg = ChatMessage(
      isUser: true,
      text: query,
      sentAt: DateTime.now().millisecondsSinceEpoch,
    );

    _inputController.clear();
    setState(() {
      _messages.add(userMsg);
      _isAiTyping = true;
    });
    _scrollToBottom();

    ChatMessage answer;
    try {
      final String languageCode = Localizations.localeOf(context).languageCode;
      final ChatbotData data = _engine().data;
      answer = await GeminiAdvisorService.generateResponse(
        query: query,
        data: data,
        languageCode: languageCode,
        now: DateTime.now(),
        pendingMonth: _pendingPlanMonth,
      );
    } catch (e) {
      debugPrint('Chatbot response error, falling back to local engine: $e');
      answer = _answerFor(query);
    }

    if (!mounted) return;
    setState(() {
      _messages.add(answer);
      _isAiTyping = false;
      if (answer.pendingMonth != null) {
        _pendingPlanMonth = answer.pendingMonth;
      } else if (answer.budgetPlan != null) {
        _pendingPlanMonth = null;
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _openAddExpense() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TransactionFormScreen(type: TransactionTypes.expense)),
    );
  }

  void _applyBudgetPlan(BudgetPlanProposal plan) {
    // Save each category budget to Firebase
    for (final item in plan.items) {
      if (item.amount > 0) {
        BudgetService.save(Budget(
          month: plan.month,
          categoryId: item.categoryId,
          limitAmount: item.amount,
        ));
      }
    }

    // Also update/save total monthly budget
    if (plan.totalPlanned > 0) {
      BudgetService.save(Budget(
        month: plan.month,
        categoryId: null, // Total month budget
        limitAmount: plan.totalPlanned,
      ));
    }

    final bool isVi = Localizations.localeOf(context).languageCode == 'vi';

    setState(() {
      plan.isApplied = true;
      _messages.add(ChatMessage(
        isUser: false,
        text: isVi
            ? '🎉 Tuyệt vời! Penny đã tự động lưu các ngân sách tháng ${plan.month} vào hệ thống của bạn. Bạn có thể mở tab "Ngân sách" để xem và theo dõi nhé!'
            : '🎉 Great! Penny has saved the budget allocations for month ${plan.month} into your system. You can view and track them in the "Budget" tab!',
        sentAt: DateTime.now().millisecondsSinceEpoch,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(isVi ? 'Đã áp dụng ngân sách thành công!' : 'Budget applied successfully!'),
      ),
    );

    _scrollToBottom();
  }

  void _editPlanItem(BudgetPlanItem item) {
    final controller = TextEditingController(text: item.amount.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Điều chỉnh số tiền ngân sách:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Huỷ')),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.replaceAll(RegExp(r'[^0-9]'), ''));
              if (parsed != null && parsed >= 0) {
                setState(() => item.amount = parsed);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  Future<void> _showGeminiSettingsDialog() async {
    final currentKey = await GeminiAdvisorService.getApiKey();
    final controller = TextEditingController(text: currentKey);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Trợ lý Gemini AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Penny đã tích hợp sẵn Gemini AI từ backend hệ thống. Bạn có thể sử dụng trực tiếp hoặc tùy chọn cấu hình khóa API riêng nếu cần:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AQ...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            const Text(
              'Trạng thái: Đã sẵn sàng hoạt động với Gemini AI backend.',
              style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Đóng')),
          FilledButton(
            onPressed: () async {
              await GeminiAdvisorService.saveApiKey(controller.text.trim());
              _checkGeminiConfig();
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật cài đặt Gemini AI!')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool canSend = ChatIntentMatcher.canSend(_inputController.text);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const _PennyAvatar(size: 44),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.menuChatbot, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(l10n.chatSubtitle, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
            tooltip: 'Cấu hình Gemini AI',
            onPressed: _showGeminiSettingsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading && !_hasError) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _MessageBubble(
                message: _messages[index],
                onSuggestion: _send,
                onAddExpense: _openAddExpense,
                onApplyBudgetPlan: _applyBudgetPlan,
                onEditPlanItem: _editPlanItem,
              ),
            ),
          ),
          if (_isAiTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  const _PennyAvatar(size: 26),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Penny đang tính toán...',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: _engine()
                  .defaultSuggestions
                  .map((suggestion) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(suggestion, style: const TextStyle(fontWeight: FontWeight.w700)),
                          onPressed: () => _send(suggestion),
                        ),
                      ))
                  .toList(),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      maxLength: ChatIntentMatcher.maxMessageLength,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: _send,
                      decoration: InputDecoration(hintText: l10n.chatHint),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        minimumSize: const Size(52, 52),
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.fill,
                      ),
                      tooltip: l10n.chatSend,
                      onPressed: canSend && !_isAiTyping ? () => _send(_inputController.text) : null,
                      icon: const Icon(Icons.send_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PennyAvatar extends StatelessWidget {
  final double size;

  const _PennyAvatar({this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.pink,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textPrimary, width: 2),
      ),
      child: ClipOval(child: Image.asset(AppAssets.pig, fit: BoxFit.cover)),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<String> onSuggestion;
  final VoidCallback onAddExpense;
  final ValueChanged<BudgetPlanProposal> onApplyBudgetPlan;
  final ValueChanged<BudgetPlanItem> onEditPlanItem;

  const _MessageBubble({
    required this.message,
    required this.onSuggestion,
    required this.onAddExpense,
    required this.onApplyBudgetPlan,
    required this.onEditPlanItem,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(20)),
          child: Text(message.text, style: const TextStyle(fontSize: 16, color: Colors.white)),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final ChatProgress? progress = message.progress;
    final BudgetPlanProposal? plan = message.budgetPlan;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PennyAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text, style: const TextStyle(fontSize: 15, height: 1.4)),
                  if (progress != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(progress.label, style: const TextStyle(fontWeight: FontWeight.w700))),
                              Text(progress.caption, style: const TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AppProgressBar(
                            value: progress.percent / 100,
                            color: progress.percent >= 100 ? AppColors.expense : AppColors.honey,
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (plan != null) ...[
                    const SizedBox(height: 12),
                    _BudgetPlanProposalCard(
                      plan: plan,
                      onApply: () => onApplyBudgetPlan(plan),
                      onEditItem: onEditPlanItem,
                    ),
                  ],
                  if (message.suggestions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...message.suggestions.map((suggestion) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ActionChip(
                            backgroundColor: AppColors.mintSoft,
                            side: const BorderSide(color: AppColors.mint, width: 1.5),
                            label: Text(suggestion, style: const TextStyle(fontWeight: FontWeight.w700)),
                            onPressed: () => onSuggestion(suggestion),
                          ),
                        )),
                  ],
                  if (message.showAddExpense) ...[
                    const SizedBox(height: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                      onPressed: onAddExpense,
                      child: Text(l10n.dashAddExpense),
                    ),
                  ],
                  const Divider(height: 24, color: AppColors.border),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(l10n.chatDisclaimer, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetPlanProposalCard extends StatelessWidget {
  final BudgetPlanProposal plan;
  final VoidCallback onApply;
  final ValueChanged<BudgetPlanItem> onEditItem;

  const _BudgetPlanProposalCard({
    required this.plan,
    required this.onApply,
    required this.onEditItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      plan.isDeficit ? Icons.warning_amber_rounded : Icons.auto_awesome,
                      color: plan.isDeficit ? AppColors.expense : AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Kế hoạch tháng ${plan.month}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: plan.isDeficit ? AppColors.expenseSoft : AppColors.mintSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${Formatters.money(plan.estimatedIncome)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: plan.isDeficit ? AppColors.expense : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (plan.isDeficit) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.expenseSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.expense, width: 1.2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.expense, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CẢNH BÁO: THÂM HỤT NGÂN SÁCH',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.expense),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Khoản chi cố định (${Formatters.money(plan.fixedExpensesTotal)}) vượt thu nhập dự kiến (${Formatters.money(plan.estimatedIncome)}) là -${Formatters.money(plan.deficitAmount)}. Đã chuyển sang kế hoạch sinh tồn và cắt giảm mua sắm, giải trí.',
                          style: const TextStyle(fontSize: 11, color: AppColors.expense, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (plan.fixedExpensesTotal > 0 || plan.savingsTotal > 0 || plan.isDeficit)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (plan.fixedExpensesTotal > 0)
                    _pill(
                      'Chi cố định: -${Formatters.money(plan.fixedExpensesTotal)}',
                      AppColors.expenseSoft,
                      AppColors.expense,
                    ),
                  if (plan.savingsTotal > 0)
                    _pill(
                      'Tiết kiệm mục tiêu: -${Formatters.money(plan.savingsTotal)}',
                      AppColors.honeySoft,
                      Colors.orange.shade800,
                    ),
                  if (plan.isDeficit)
                    _pill(
                      'Thâm hụt: -${Formatters.money(plan.deficitAmount)}',
                      AppColors.expenseSoft,
                      AppColors.expense,
                    ),
                ],
              ),
            ),
          const Divider(height: 12, color: AppColors.border),
          ...plan.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CategoryIcon(iconName: CategoryDisplay.iconName(item.categoryId), size: 32),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.categoryName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          if (item.note != null && item.note!.isNotEmpty)
                            Text(
                              item.note!,
                              style: TextStyle(
                                fontSize: 11,
                                color: item.amount == 0 ? AppColors.expense : AppColors.textSecondary,
                                fontStyle: item.amount == 0 ? FontStyle.italic : FontStyle.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.money(item.amount),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: item.amount == 0 ? AppColors.textMuted : AppColors.textPrimary,
                      ),
                    ),
                    if (!plan.isApplied)
                      InkWell(
                        onTap: () => onEditItem(item),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6, top: 4, bottom: 4),
                          child: Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              )),
          const Divider(height: 14, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Tổng ngân sách dự kiến:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              Text(
                Formatters.money(plan.totalPlanned),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (plan.isApplied)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.mintSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1.2),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Đã áp dụng vào Ngân sách',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            )
          else
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onApply,
              child: const Text('Áp dụng vào Ngân sách', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
