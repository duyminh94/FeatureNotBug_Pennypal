import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/savings_goal.dart';
import '../../models/transaction_record.dart';
import '../../utils/app_theme.dart';
import '../../utils/balance_calculator.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/goal_calculator.dart';
import '../../utils/sample_data.dart';
import '../../widgets/empty_state.dart';
import 'goal_cards.dart';
import 'goal_detail_screen.dart';
import 'goal_form_screen.dart';

/// Goals tab: active goals on the first tab, completed and cancelled goals under History.
/// Goals and transactions come from MainShell, which listens to Firebase.
class GoalsScreen extends StatefulWidget {
  /// The student's goals; null only in old tests, then sample data is shown.
  final List<SavingsGoal>? initialGoals;

  /// All transactions; a goal's contributions are the ones linked to it by goalId.
  final List<TransactionRecord>? transactions;

  const GoalsScreen({super.key, this.initialGoals, this.transactions});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<SavingsGoal> _goals = [];
  List<TransactionRecord> _transactions = [];
  bool _isHistoryTab = false;

  @override
  void initState() {
    super.initState();
    _goals = _copyGoals();
    _transactions = _copyTransactions();
  }

  /// When Firebase sends new data, MainShell rebuilds this screen with new lists; take copies of them.
  @override
  void didUpdateWidget(covariant GoalsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialGoals != oldWidget.initialGoals) {
      _goals = _copyGoals();
    }
    if (widget.transactions != oldWidget.transactions) {
      _transactions = _copyTransactions();
    }
  }

  List<SavingsGoal> _copyGoals() {
    final List<SavingsGoal>? goals = widget.initialGoals;
    if (goals == null) return List.of(SampleData.goals());
    return List.of(goals);
  }

  List<TransactionRecord> _copyTransactions() {
    final List<TransactionRecord>? transactions = widget.transactions;
    if (transactions == null) return List.of(SampleData.transactions());
    return List.of(transactions);
  }

  /// Number of contributions of a goal, shown on a cancelled goal's card.
  int _contributionCount(SavingsGoal goal) {
    return GoalCalculator.contributionsOf(goal.id, _transactions).length;
  }

  /// Applies a change made on the detail screen right away (the same data also comes back from Firebase):
  /// the goal is replaced, or removed when it was deleted, and its contributions are replaced.
  void _applyChange(GoalChange change) {
    setState(() {
      final SavingsGoal? changedGoal = change.goal;
      final List<SavingsGoal> goals = [];
      for (final SavingsGoal goal in _goals) {
        if (goal.id != change.goalId) {
          goals.add(goal);
        } else if (changedGoal != null) {
          goals.add(changedGoal);
        }
      }
      _goals = goals;

      final List<TransactionRecord> transactions = [];
      for (final TransactionRecord transaction in _transactions) {
        if (transaction.goalId != change.goalId) transactions.add(transaction);
      }
      transactions.addAll(change.contributions);
      _transactions = transactions;
    });
  }

  /// Opens a goal. The detail screen may ask to show History (after completing)
  /// or to create a new goal (from the "goal reached" screen).
  Future<void> _openDetail(SavingsGoal goal) async {
    final GoalDetailAction? action = await Navigator.of(context).push<GoalDetailAction>(
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(
          goal: goal,
          contributions: GoalCalculator.contributionsOf(goal.id, _transactions),
          balance: BalanceCalculator.balance(_transactions),
          onChanged: _applyChange,
        ),
      ),
    );
    if (!mounted || action == null) return;

    if (action == GoalDetailAction.openHistory) {
      setState(() {
        _isHistoryTab = true;
      });
    } else {
      await _openForm();
    }
  }

  /// Opens the new goal form; the new goal is put at the top of the Active tab.
  Future<void> _openForm() async {
    final SavingsGoal? saved = await Navigator.of(context).push<SavingsGoal>(
      MaterialPageRoute(builder: (context) => const GoalFormScreen()),
    );
    if (!mounted || saved == null) return;

    setState(() {
      final List<SavingsGoal> goals = [saved];
      for (final SavingsGoal goal in _goals) {
        if (goal.id != saved.id) goals.add(goal);
      }
      _goals = goals;
      _isHistoryTab = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<SavingsGoal> activeGoals = GoalCalculator.goalsWithStatus(_goals, GoalStatuses.active);
    final List<SavingsGoal> completedGoals = GoalCalculator.goalsWithStatus(_goals, GoalStatuses.completed);
    final List<SavingsGoal> cancelledGoals = GoalCalculator.goalsWithStatus(_goals, GoalStatuses.cancelled);
    final int historyCount = completedGoals.length + cancelledGoals.length;

    List<Widget> tabContent;
    if (_isHistoryTab) {
      tabContent = _buildHistory(l10n, completedGoals, cancelledGoals);
    } else {
      tabContent = _buildActive(l10n, activeGoals);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.navGoals,
                    style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(52, 52),
                  ),
                  tooltip: l10n.goalAdd,
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: false, label: Text(l10n.goalTabActive(activeGoals.length))),
                ButtonSegment(value: true, label: Text(l10n.goalTabHistory(historyCount))),
              ],
              selected: {_isHistoryTab},
              onSelectionChanged: (selected) {
                setState(() {
                  _isHistoryTab = selected.first;
                });
              },
            ),
            const SizedBox(height: 16),
            ...tabContent,
          ],
        ),
      ),
    );
  }

  /// Active tab: one card per active goal and a button to create another one.
  List<Widget> _buildActive(AppLocalizations l10n, List<SavingsGoal> activeGoals) {
    if (activeGoals.isEmpty) {
      return [
        EmptyState(
          icon: Icons.flag_outlined,
          message: l10n.goalEmptyActive,
          actionLabel: l10n.goalAdd,
          onAction: () => _openForm(),
        ),
      ];
    }

    final List<Widget> widgets = [];
    for (final SavingsGoal goal in activeGoals) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ActiveGoalCard(goal: goal, onTap: () => _openDetail(goal)),
      ));
    }
    widgets.add(OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      onPressed: () => _openForm(),
      icon: const Icon(Icons.add),
      label: Text(l10n.goalCreateNew),
    ));
    return widgets;
  }

  /// History tab: completed goals, then cancelled goals, then a banner with the total money saved.
  List<Widget> _buildHistory(AppLocalizations l10n, List<SavingsGoal> completedGoals, List<SavingsGoal> cancelledGoals) {
    if (completedGoals.isEmpty && cancelledGoals.isEmpty) {
      return [EmptyState(icon: Icons.history, message: l10n.goalEmptyHistory)];
    }

    // Only completed goals count as saved money; cancelled goals do not.
    double totalSaved = 0;
    for (final SavingsGoal goal in completedGoals) {
      totalSaved += goal.currentAmount;
    }

    final List<Widget> widgets = [];
    if (completedGoals.isNotEmpty) {
      widgets.add(_SectionTitle(text: l10n.goalCompleted));
      for (final SavingsGoal goal in completedGoals) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CompletedGoalCard(goal: goal, onTap: () => _openDetail(goal)),
        ));
      }
    }

    if (cancelledGoals.isNotEmpty) {
      widgets.add(_SectionTitle(text: l10n.goalCancelled));
      for (final SavingsGoal goal in cancelledGoals) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CancelledGoalCard(
            goal: goal,
            contributionCount: _contributionCount(goal),
            onTap: () => _openDetail(goal),
          ),
        ));
      }
    }

    if (completedGoals.isNotEmpty) {
      widgets.add(Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.honeySoft, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Image.asset(AppAssets.pig, width: 64, height: 56, fit: BoxFit.contain),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.goalHistoryBanner(completedGoals.length, Formatters.money(totalSaved)),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ));
    }
    return widgets;
  }
}

/// Heading above the Completed / Cancelled lists.
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(text, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w700)),
    );
  }
}
