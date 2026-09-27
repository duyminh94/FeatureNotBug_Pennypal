import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/savings_goal.dart';
import '../../models/transaction_record.dart';
import '../../services/goal_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/goal_calculator.dart';
import '../../widgets/confirm_dialog.dart';
import 'contribution_sheet.dart';
import 'goal_cards.dart';
import 'goal_form_screen.dart';
import 'goal_milestones.dart';

/// What changed on the detail screen, sent back to the Goals list so it updates at once.
/// [goal] is null when the goal was deleted.
class GoalChange {
  final String goalId;
  final SavingsGoal? goal;
  final List<TransactionRecord> contributions;

  const GoalChange({required this.goalId, required this.goal, required this.contributions});
}

/// What the Goals list should do after the detail screen closes.
enum GoalDetailAction { createGoal, openHistory }

/// The two ways to delete a goal that already has contributions.
enum _DeleteChoice { refund, keepHistory }

/// One goal: progress, milestones, stats, contributions and the actions
/// (contribute, edit, delete). A completed goal shows a "goal reached" header instead.
class GoalDetailScreen extends StatefulWidget {
  final SavingsGoal goal;

  /// This goal's contributions (savings transactions with its goalId).
  final List<TransactionRecord> contributions;

  /// Current balance, used for the "more than your balance" warning when contributing.
  final double balance;

  /// Called after every change so the Goals list stays in step.
  final ValueChanged<GoalChange> onChanged;

  const GoalDetailScreen({
    super.key,
    required this.goal,
    required this.contributions,
    required this.balance,
    required this.onChanged,
  });

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late SavingsGoal _goal;
  List<TransactionRecord> _contributions = [];

  // Balance before this goal's contributions; the live balance is this minus the current contributions.
  double _balanceWithoutGoal = 0;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _contributions = List.of(widget.contributions);
    _sortContributions();
    _balanceWithoutGoal = widget.balance + GoalCalculator.contributedTotal(widget.contributions);
  }

  /// Newest contribution first.
  void _sortContributions() {
    _contributions.sort((a, b) => b.date.compareTo(a.date));
  }

  /// Balance after the contributions made on this screen.
  double get _balance {
    return _balanceWithoutGoal - GoalCalculator.contributedTotal(_contributions);
  }

  bool get _isCancelled {
    return _goal.status == GoalStatuses.cancelled;
  }

  bool get _isCompleted {
    return _goal.status == GoalStatuses.completed;
  }

  int get _now {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Sends the current goal and contributions back to the Goals list.
  void _notify() {
    widget.onChanged(GoalChange(goalId: _goal.id, goal: _goal, contributions: List.of(_contributions)));
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Opens the edit form; the form saves the goal itself.
  Future<void> _openEditForm() async {
    final SavingsGoal? saved = await Navigator.of(context).push<SavingsGoal>(
      MaterialPageRoute(builder: (context) => GoalFormScreen(initial: _goal, hasContributions: _contributions.isNotEmpty)),
    );
    if (saved == null || !mounted) return;
    setState(() {
      _goal = saved;
    });
    _notify();
  }

  /// Adds, edits or deletes a contribution. The goal's saved money changes by the difference,
  /// which may complete the goal (100%) or reopen it. The contribution and the goal are saved together.
  Future<void> _openContributionSheet({TransactionRecord? contribution}) async {
    final l10n = AppLocalizations.of(context)!;
    final Object? result = await showContributionSheet(context, goal: _goal, balance: _balance, contribution: contribution);
    if (result == null || !mounted) return;

    final double oldAmount = contribution?.amount ?? 0;

    // Delete: take the old amount back out of the goal.
    if (result == FormResults.deleted && contribution != null) {
      setState(() {
        _contributions.remove(contribution);
        _goal = GoalCalculator.changeCurrentAmount(_goal, -oldAmount, _now);
      });
      GoalService.deleteContribution(contribution.id, _goal);
      _notify();
      _showMessage(l10n.goalContributionDeleted);
      return;
    }

    if (result is! TransactionRecord) return;
    final TransactionRecord saved = result;

    setState(() {
      if (contribution != null) {
        // Edit: only the difference between the new and old amount changes the goal.
        final int index = _contributions.indexOf(contribution);
        _contributions[index] = saved;
        _goal = GoalCalculator.changeCurrentAmount(_goal, saved.amount - oldAmount, _now);
      } else {
        _contributions.insert(0, saved);
        _goal = GoalCalculator.changeCurrentAmount(_goal, saved.amount, _now);
      }
      _sortContributions();
    });
    GoalService.saveContribution(saved, _goal);
    _notify();

    if (contribution != null) {
      _showMessage(l10n.goalContributionUpdated);
    } else {
      _showMessage(l10n.goalContributed(Formatters.money(saved.amount)));
    }
  }

  /// Marks a reached milestone with today's date.
  void _markMilestone(String key) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _goal = GoalCalculator.markMilestone(_goal, key, _now);
    });
    GoalService.saveGoal(_goal);
    _notify();
    _showMessage(l10n.goalMilestoneMarked(int.parse(key.substring(1))));
  }

  /// Deleting a goal:
  /// - no contributions: simple confirm, then the goal is deleted;
  /// - with contributions, "refund": the goal and its contributions are deleted, the money goes back to the balance;
  /// - with contributions, "keep history": the goal becomes cancelled and its transactions stay.
  Future<void> _deleteGoal() async {
    final l10n = AppLocalizations.of(context)!;
    if (_contributions.isEmpty) {
      final bool confirmed = await showConfirmDialog(
        context,
        title: l10n.goalDeleteTitle,
        message: l10n.goalDeleteBody(_goal.name),
        confirmLabel: l10n.commonDelete,
        isDestructive: true,
        icon: Icons.delete_outline,
      );
      if (!confirmed || !mounted) return;
      GoalService.deleteGoal(_goal.id, const []);
      _finishDelete(GoalChange(goalId: _goal.id, goal: null, contributions: const []), l10n.goalDeleted);
      return;
    }

    final double contributed = GoalCalculator.contributedTotal(_contributions);
    final _DeleteChoice? choice = await _showDeleteChoices(l10n, contributed);
    if (choice == null || !mounted) return;

    if (choice == _DeleteChoice.refund) {
      final List<String> contributionIds = [];
      for (final TransactionRecord contribution in _contributions) {
        contributionIds.add(contribution.id);
      }
      GoalService.deleteGoal(_goal.id, contributionIds);
      _finishDelete(
        GoalChange(goalId: _goal.id, goal: null, contributions: const []),
        l10n.goalRefunded(Formatters.money(contributed)),
      );
    } else {
      final SavingsGoal cancelledGoal = GoalCalculator.cancelGoal(_goal);
      GoalService.saveGoal(cancelledGoal);
      _finishDelete(
        GoalChange(goalId: _goal.id, goal: cancelledGoal, contributions: List.of(_contributions)),
        l10n.goalMovedToHistory,
      );
    }
  }

  /// Tells the list, shows the result and closes the detail screen.
  void _finishDelete(GoalChange change, String message) {
    widget.onChanged(change);
    _showMessage(message);
    Navigator.of(context).pop();
  }

  /// Dialog with the two choices (refund or keep history); returns null on Cancel.
  Future<_DeleteChoice?> _showDeleteChoices(AppLocalizations l10n, double contributed) {
    return showDialog<_DeleteChoice>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: AppColors.expenseSoft, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.savings_outlined, color: AppColors.expense),
            ),
          ),
          title: Text(
            l10n.goalHasContributionsTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.goalHasContributionsBody(Formatters.money(contributed), _goal.name),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: () => Navigator.of(dialogContext).pop(_DeleteChoice.refund),
                icon: const Icon(Icons.replay),
                label: Text(l10n.goalRefund(Formatters.money(contributed))),
              ),
              const SizedBox(height: 4),
              Text(l10n.goalRefundHint(_contributions.length), textAlign: TextAlign.center, style: _hintStyle),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(_DeleteChoice.keepHistory),
                icon: const Icon(Icons.schedule),
                label: Text(l10n.goalKeepHistory),
              ),
              const SizedBox(height: 4),
              Text(l10n.goalKeepHistoryHint, textAlign: TextAlign.center, style: _hintStyle),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.commonCancel)),
            ],
          ),
        );
      },
    );
  }

  static const TextStyle _hintStyle = TextStyle(fontSize: 13, color: AppColors.textSecondary);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_goal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          if (_goal.isActive) IconButton(tooltip: l10n.commonEdit, icon: const Icon(Icons.edit_outlined), onPressed: _openEditForm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (_isCompleted) _buildCompletedHeader(l10n) else _buildProgressHeader(l10n),
          if (_goal.isActive) ...[
            const SizedBox(height: 16),
            _buildStats(l10n),
          ],
          const SizedBox(height: 20),
          _SectionTitle(text: l10n.goalMilestones),
          GoalMilestones(goal: _goal, onMark: _markMilestone),
          const SizedBox(height: 20),
          _SectionTitle(text: l10n.goalContributions),
          _buildContributions(l10n),
          const SizedBox(height: 12),
          Text(
            l10n.goalCreatedInfo(
              Formatters.money(_goal.initialAmount),
              Formatters.money(_goal.monthlyContribution),
              Formatters.monthYear(_goal.targetDate),
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (!_isCancelled) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
              onPressed: _deleteGoal,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.goalDelete),
            ),
          ],
        ],
      ),
      bottomNavigationBar: _buildBottomBar(l10n),
    );
  }

  /// Ring, saved / target and pace for an active or cancelled goal.
  Widget _buildProgressHeader(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _goal.progress,
                  strokeWidth: 18,
                  color: _isCancelled ? AppColors.textMuted : AppColors.pink,
                  backgroundColor: _isCancelled ? AppColors.fill : AppColors.expenseSoft,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppAssets.pig, width: 72, height: 64, fit: BoxFit.contain),
                  Text(
                    '${GoalCalculator.percentOf(_goal.progress)}%',
                    style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 34, fontWeight: FontWeight.w800),
                  ),
                  Text(l10n.goalSavedLabel, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: Formatters.money(_goal.currentAmount),
                style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              TextSpan(
                text: ' / ${Formatters.money(_goal.targetAmount)}',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_isCancelled)
          Text(l10n.goalCancelledInfo, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary))
        else
          GoalPaceBadge(pace: _pace()),
      ],
    );
  }

  /// On track / behind, from the estimated finish date and the target date.
  GoalPace _pace() {
    final int? months = GoalCalculator.monthsLeft(_goal.remainingAmount, _goal.monthlyContribution);
    return GoalCalculator.pace(GoalCalculator.estimatedDate(months), DateTime.fromMillisecondsSinceEpoch(_goal.targetDate));
  }

  /// "Goal reached" header of a completed goal, with the completion date.
  Widget _buildCompletedHeader(AppLocalizations l10n) {
    final int? completedAt = _goal.completedAt;
    String doneDate = '';
    if (completedAt != null) doneDate = Formatters.fullDate(DateTime.fromMillisecondsSinceEpoch(completedAt));

    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.honeySoft,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.honey, width: 6),
          ),
          child: Image.asset(AppAssets.pig, fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(99)),
          child: Text(
            l10n.goalCompletedBadge(doneDate),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.goalCompletedTitle,
          style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.goalCompletedBody(Formatters.money(_goal.targetAmount), _goal.name),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Three numbers: money left, months left at the monthly amount, estimated finish month.
  /// Without a monthly amount the last two say "No estimate".
  Widget _buildStats(AppLocalizations l10n) {
    final int? months = GoalCalculator.monthsLeft(_goal.remainingAmount, _goal.monthlyContribution);
    final DateTime? estimated = GoalCalculator.estimatedDate(months);

    String monthsText = l10n.goalNotEstimated;
    if (months != null) monthsText = l10n.goalMonthsValue(months);
    String estimatedText = l10n.goalNotEstimated;
    if (estimated != null) estimatedText = Formatters.monthYear(estimated.millisecondsSinceEpoch);

    return Row(
      children: [
        Expanded(child: _StatTile(label: l10n.goalRemainingLabel, value: Formatters.money(_goal.remainingAmount))),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(label: l10n.goalMonthsLabel, value: monthsText),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: l10n.goalEstimatedLabel,
            value: estimatedText,
          ),
        ),
      ],
    );
  }

  /// List of contributions, newest first.
  Widget _buildContributions(AppLocalizations l10n) {
    if (_contributions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.goalNoContributions, style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final List<Widget> rows = [];
    for (final TransactionRecord contribution in _contributions) {
      rows.add(_buildContributionRow(l10n, contribution));
    }
    return Card(child: Column(children: rows));
  }

  /// One contribution; tapping it opens the edit sheet (not for a cancelled goal, which is read-only).
  Widget _buildContributionRow(AppLocalizations l10n, TransactionRecord contribution) {
    VoidCallback? onTap;
    if (!_isCancelled) {
      onTap = () => _openContributionSheet(contribution: contribution);
    }

    String title = l10n.goalContribute;
    if (contribution.description.isNotEmpty) title = contribution.description;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.savings_outlined, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(Formatters.fullDate(DateTime.fromMillisecondsSinceEpoch(contribution.date))),
      trailing: Text(
        '+${Formatters.money(contribution.amount)}',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
      ),
    );
  }

  /// Bottom buttons: Contribute for an active goal, "new goal" / History for a completed one, none when cancelled.
  Widget? _buildBottomBar(AppLocalizations l10n) {
    if (_isCancelled) return null;

    final Widget buttons = _isCompleted
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.mint, foregroundColor: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(GoalDetailAction.createGoal),
                icon: const Icon(Icons.add),
                label: Text(l10n.goalCreateNext),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                onPressed: () => Navigator.of(context).pop(GoalDetailAction.openHistory),
                child: Text(l10n.goalSeeHistory),
              ),
            ],
          )
        : FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.mint, foregroundColor: AppColors.textPrimary),
            onPressed: () => _openContributionSheet(),
            icon: const Icon(Icons.add),
            label: Text(l10n.goalContribute),
          );

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: buttons,
      ),
    );
  }
}

/// Heading of a section on the detail screen.
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w700)),
    );
  }
}

/// One small stat box: label and value.
class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
