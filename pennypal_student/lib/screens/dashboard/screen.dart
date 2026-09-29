import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/budget.dart';
import '../../models/dashboard_data.dart';
import '../../models/savings_goal.dart';
import '../../models/transaction_record.dart';
import '../../models/user_profile.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/balance_calculator.dart';
import '../../utils/budget_calculator.dart';
import '../../utils/category_display.dart';
import '../../utils/formatters.dart';
import '../../utils/goal_calculator.dart';
import '../../utils/report_calculator.dart';
import '../../widgets/month_picker.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_tile.dart';
import '../chatbot/screen.dart';
import '../learning/screen.dart';
import '../support/feedback_screen.dart';
import '../support/screen.dart';
import '../transactions/detail_screen.dart';
import '../transactions/form_screen.dart';
import 'cards.dart';

class DashboardScreen extends StatefulWidget {
  final DashboardData? data;
  final List<TransactionRecord>? transactions;
  final List<Budget> budgets;
  final List<SavingsGoal> goals;
  final String userName;
  final UserProfile? profile;
  final ValueChanged<int> onOpenTab;
  final int unreadCount;
  final VoidCallback? onOpenNotifications;

  const DashboardScreen({
    super.key,
    this.data,
    this.transactions,
    this.budgets = const [],
    this.goals = const [],
    this.userName = '',
    this.profile,
    required this.onOpenTab,
    this.unreadCount = 0,
    this.onOpenNotifications,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _isAnnouncementClosed = false;

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.commonComingSoon)),
    );
  }

  void _openTransactionForm(String type) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TransactionFormScreen(type: type)),
    );
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  void _openChatbot() {
    final UserProfile? profile = widget.profile;
    if (profile == null) return;
    _openScreen(ChatbotScreen(uid: profile.uid, userName: widget.userName));
  }

  Future<void> _openDetail(TransactionRecord transaction) async {
    final Object? result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TransactionDetailScreen(transaction: transaction)),
    );
    if (result != FormResults.deleted || !mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.txDeleted)));
  }

  double _categorySpent(Budget budget) {
    final String monthKey = BudgetCalculator.monthKey(_month);
    return BudgetCalculator.spent(widget.transactions ?? const [], monthKey, categoryId: budget.categoryId);
  }

  Budget? _mostUsedCategoryBudget() {
    final List<Budget> categoryBudgets = BudgetCalculator.categoryBudgets(widget.budgets, BudgetCalculator.monthKey(_month));
    Budget? mostUsed;
    int highestPercent = -1;
    for (final Budget budget in categoryBudgets) {
      final int percent = BudgetCalculator.percent(_categorySpent(budget), budget.limitAmount);
      if (percent > highestPercent) {
        highestPercent = percent;
        mostUsed = budget;
      }
    }
    return mostUsed;
  }

  Widget _buildBudgetCard(DashboardData data) {
    final l10n = AppLocalizations.of(context)!;
    void openBudgetTab() => widget.onOpenTab(MainTabs.budget);

    final Budget? totalBudget = data.totalBudget;
    if (totalBudget != null) {
      return BudgetCard(budget: totalBudget, spent: data.monthExpense, month: _month, onTap: openBudgetTab);
    }

    final Budget? categoryBudget = _mostUsedCategoryBudget();
    if (categoryBudget == null) return NoBudgetCard(onCreate: openBudgetTab);

    return BudgetCard(
      budget: categoryBudget,
      spent: _categorySpent(categoryBudget),
      month: _month,
      title: CategoryDisplay.name(l10n, categoryBudget.categoryId!),
      onTap: openBudgetTab,
    );
  }

  SavingsGoal? _nearestActiveGoal() {
    final List<SavingsGoal> activeGoals = GoalCalculator.goalsWithStatus(widget.goals, GoalStatuses.active);
    if (activeGoals.isEmpty) return null;
    activeGoals.sort((first, second) => first.targetDate.compareTo(second.targetDate));
    return activeGoals.first;
  }

  DashboardData _buildData() {
    final List<TransactionRecord>? transactions = widget.transactions;
    if (transactions == null) {
      return widget.data ?? DashboardData.empty(userName: widget.userName);
    }

    final MonthSummary summary = ReportCalculator.summary(transactions, _month);
    return DashboardData(
      userName: widget.userName,
      balance: BalanceCalculator.balance(transactions),
      monthIncome: summary.income,
      monthExpense: summary.spending,
      savedInGoals: GoalCalculator.savedInActiveGoals(widget.goals),
      totalBudget: BudgetCalculator.totalBudget(widget.budgets, BudgetCalculator.monthKey(_month)),
      activeGoal: _nearestActiveGoal(),
      recentTransactions: transactions.take(5).toList(),
    );
  }

  String _greeting(AppLocalizations l10n) {
    final int hour = DateTime.now().hour;
    return hour < 12 ? l10n.dashGreetingMorning : (hour < 18 ? l10n.dashGreetingAfternoon : l10n.dashGreetingEvening);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final DashboardData data = _buildData();
    final bool hasTransactions = data.recentTransactions.isNotEmpty;
    final String? announcement = data.announcement;
    final bool showAnnouncement = announcement != null && announcement.isNotEmpty && !_isAnnouncementClosed;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openChatbot,
        backgroundColor: AppColors.textPrimary,
        foregroundColor: Colors.white,
        icon: Image.asset(AppAssets.pig, width: 32, height: 32),
        label: Text(l10n.dashAskPenny, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          children: [
            _buildHeader(l10n, data.userName),
            const SizedBox(height: 8),
            MonthPicker(month: _month, onChanged: (month) => setState(() => _month = month)),
            if (showAnnouncement) ...[
              const SizedBox(height: 8),
              _buildAnnouncement(l10n, announcement),
            ],
            const SizedBox(height: 16),
            BalanceCard(balance: data.balance, hasData: hasTransactions),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: l10n.dashMonthIncome,
                    value: Formatters.money(data.monthIncome),
                    icon: Icons.arrow_downward,
                    color: AppColors.primary,
                    backgroundColor: AppColors.mintSoft,
                    onTap: () => _openTransactionForm(TransactionTypes.income),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SummaryCard(
                    title: l10n.dashMonthExpense,
                    value: Formatters.money(data.monthExpense),
                    icon: Icons.arrow_upward,
                    color: AppColors.expense,
                    backgroundColor: AppColors.expenseSoft,
                    onTap: () => _openTransactionForm(TransactionTypes.expense),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SummaryCard(
                    title: l10n.dashSavedInGoals,
                    value: Formatters.money(data.savedInGoals),
                    icon: Icons.savings_outlined,
                    color: AppColors.honeyText,
                    backgroundColor: AppColors.honeySoft,
                    onTap: () => widget.onOpenTab(MainTabs.goals),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBudgetCard(data),
            if (data.activeGoal != null) ...[
              const SizedBox(height: 20),
              _buildSectionTitle(l10n.dashGoalsTitle, onSeeAll: () => widget.onOpenTab(MainTabs.goals)),
              const SizedBox(height: 10),
              GoalCard(goal: data.activeGoal!, onTap: () => widget.onOpenTab(MainTabs.goals)),
            ],
            const SizedBox(height: 20),
            _buildSectionTitle(l10n.dashShortcuts),
            const SizedBox(height: 12),
            _buildShortcuts(l10n),
            const SizedBox(height: 20),
            if (hasTransactions) ...[
              _buildSectionTitle(l10n.dashRecent, onSeeAll: () => widget.onOpenTab(MainTabs.transactions)),
              const SizedBox(height: 6),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Column(
                    children: data.recentTransactions
                        .map((transaction) => TransactionTile(transaction: transaction, onTap: () => _openDetail(transaction)))
                        .toList(),
                  ),
                ),
              ),
            ] else
              NoTransactionsCard(onAddExpense: () => _openTransactionForm(TransactionTypes.expense)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, String userName) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.expenseSoft,
          child: Text(
            Formatters.initials(userName),
            style: const TextStyle(fontFamily: AppFonts.heading, fontWeight: FontWeight.w800, color: AppColors.expense),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(l10n), style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              Text(
                userName,
                style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.textPrimary),
          tooltip: l10n.dashNotifications,
          onPressed: widget.onOpenNotifications ?? _showComingSoon,
          icon: Badge(
            isLabelVisible: widget.unreadCount > 0,
            label: Text('${widget.unreadCount}'),
            child: const Icon(Icons.notifications_none),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncement(AppLocalizations l10n, String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      decoration: BoxDecoration(
        color: AppColors.honeySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.honey),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_outlined, color: AppColors.honeyText),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          IconButton(
            tooltip: l10n.commonClose,
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _isAnnouncementClosed = true),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w700)),
        ),
        if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: Text(l10n.commonSeeAll)),
      ],
    );
  }

  Widget _buildShortcuts(AppLocalizations l10n) {
    final List<ShortcutButton> shortcuts = [
      ShortcutButton(
        icon: Icons.arrow_downward,
        label: l10n.dashAddIncome,
        color: AppColors.primary,
        background: AppColors.mintSoft,
        onTap: () => _openTransactionForm(TransactionTypes.income),
      ),
      ShortcutButton(
        icon: Icons.arrow_upward,
        label: l10n.dashAddExpense,
        color: AppColors.expense,
        background: AppColors.expenseSoft,
        onTap: () => _openTransactionForm(TransactionTypes.expense),
      ),
      ShortcutButton(
        icon: Icons.account_balance_wallet_outlined,
        label: l10n.navBudget,
        color: AppColors.honeyText,
        background: AppColors.honeySoft,
        onTap: () => widget.onOpenTab(MainTabs.budget),
      ),
      ShortcutButton(
        icon: Icons.format_list_bulleted,
        label: l10n.dashHistory,
        color: AppColors.info,
        background: AppColors.infoSoft,
        onTap: () => widget.onOpenTab(MainTabs.transactions),
      ),
      ShortcutButton(
        icon: Icons.menu_book_outlined,
        label: l10n.dashLearning,
        color: AppColors.purple,
        background: AppColors.purpleSoft,
        onTap: () => _openScreen(const LearningScreen()),
      ),
      ShortcutButton(
        icon: Icons.star_outline,
        label: l10n.dashFeedback,
        color: AppColors.orange,
        background: AppColors.orangeSoft,
        onTap: () => _openScreen(FeedbackScreen(profile: widget.profile)),
      ),
      ShortcutButton(
        icon: Icons.support_outlined,
        label: l10n.dashSupport,
        color: AppColors.teal,
        background: AppColors.tealSoft,
        onTap: () => _openScreen(const SupportScreen()),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 8,
      childAspectRatio: 0.85,
      children: shortcuts,
    );
  }
}
