import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/budget.dart';
import '../../models/chat_message.dart';
import '../../models/savings_goal.dart';
import '../../models/transaction_record.dart';
import '../../services/budget_service.dart';
import '../../services/goal_service.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/chat_intent_matcher.dart';
import '../../utils/chatbot_engine.dart';
import '../../utils/constants.dart';
import '../../widgets/app_progress_bar.dart';
import '../transactions/transaction_form_screen.dart';

/// Answers from live Firebase data. If the data can't load, tips still work (SRS: fail gracefully).
class ChatbotScreen extends StatefulWidget {
  final String uid;
  final String userName;
  final Stream<List<TransactionRecord>> Function(String uid) watchTransactions;
  final Stream<List<Budget>> Function(String uid) watchBudgets;
  final Stream<List<SavingsGoal>> Function(String uid) watchGoals;

  const ChatbotScreen({
    super.key,
    required this.uid,
    required this.userName,
    this.watchTransactions = TransactionService.watch,
    this.watchBudgets = BudgetService.watch,
    this.watchGoals = GoalService.watch,
  });

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
  bool _hasTransactions = false;
  bool _hasBudgets = false;
  bool _hasGoals = false;
  bool _hasError = false;
  StreamSubscription<List<TransactionRecord>>? _transactionSubscription;
  StreamSubscription<List<Budget>>? _budgetSubscription;
  StreamSubscription<List<SavingsGoal>>? _goalSubscription;

  bool get _isLoading => !_hasTransactions || !_hasBudgets || !_hasGoals;

  ChatbotEngine _engine() {
    final ChatbotData data = ChatbotData(
      userName: widget.userName,
      transactions: _transactions,
      budgets: _budgets,
      goals: _goals,
      customCategories: CategoryDisplay.customCategories,
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
    _listenData();
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
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _listenData() {
    _transactionSubscription?.cancel();
    _budgetSubscription?.cancel();
    _goalSubscription?.cancel();
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
        intent == ChatIntent.compareLastMonth;
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

    final ChatMessage question = ChatMessage(isUser: true, text: text.trim(), sentAt: DateTime.now().millisecondsSinceEpoch);
    final ChatMessage answer = _answerFor(text);
    _inputController.clear();
    setState(() => _messages.addAll([question, answer]));

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
              ),
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
                      onPressed: canSend ? () => _send(_inputController.text) : null,
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

  const _MessageBubble({required this.message, required this.onSuggestion, required this.onAddExpense});

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
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
                  Text(message.text, style: const TextStyle(fontSize: 16, height: 1.4)),
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
                    FilledButton.icon(
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                      onPressed: onAddExpense,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.dashAddExpense),
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
