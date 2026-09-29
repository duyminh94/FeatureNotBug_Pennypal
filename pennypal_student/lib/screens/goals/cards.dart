import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/savings_goal.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/goal_calculator.dart';
import '../../widgets/app_progress_bar.dart';

class GoalProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final Color color;
  final Color backgroundColor;

  const GoalProgressRing({
    super.key,
    required this.progress,
    this.size = 80,
    this.color = AppColors.pink,
    this.backgroundColor = AppColors.expenseSoft,
  });

  @override
  Widget build(BuildContext context) {
    final int percent = GoalCalculator.percentOf(progress);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: size / 9,
              color: color,
              backgroundColor: backgroundColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(fontFamily: AppFonts.heading, fontSize: size / 4.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class GoalPaceBadge extends StatelessWidget {
  final GoalPace pace;

  const GoalPaceBadge({super.key, required this.pace});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String label = switch (pace) {
      GoalPace.onTrack => l10n.goalOnTrack,
      GoalPace.behind => l10n.goalBehind,
      GoalPace.unknown => l10n.goalNotEstimated,
    };
    final IconData icon = switch (pace) {
      GoalPace.onTrack => Icons.check,
      GoalPace.behind => Icons.warning_amber_rounded,
      GoalPace.unknown => Icons.help_outline,
    };
    final Color background = switch (pace) {
      GoalPace.onTrack => AppColors.mintSoft,
      GoalPace.behind => AppColors.error,
      GoalPace.unknown => AppColors.fill,
    };
    final Color foreground = switch (pace) {
      GoalPace.onTrack => AppColors.primary,
      GoalPace.behind => Colors.white,
      GoalPace.unknown => AppColors.textSecondary,
    };

    return _Badge(label: label, icon: icon, background: background, foreground: foreground);
  }
}

class ActiveGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;

  const ActiveGoalCard({super.key, required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int? months = GoalCalculator.monthsLeft(goal.remainingAmount, goal.monthlyContribution);
    final DateTime? estimated = GoalCalculator.estimatedDate(months);
    final GoalPace pace = GoalCalculator.pace(estimated, DateTime.fromMillisecondsSinceEpoch(goal.targetDate));
    final String due = Formatters.monthYear(goal.targetDate);
    final String estimateText = estimated == null
        ? l10n.goalEstimateUnknown(due)
        : l10n.goalEstimate(Formatters.monthYear(estimated.millisecondsSinceEpoch), due);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const _GoalIcon(),
                  const SizedBox(width: 12),
                  Expanded(child: Text(goal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                  GoalPaceBadge(pace: pace),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  GoalProgressRing(progress: goal.progress),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formatters.money(goal.currentAmount),
                          style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          l10n.budgetOfLimit(Formatters.money(goal.targetAmount)),
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(estimateText, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletedGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback? onTap;

  const CompletedGoalCard({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int? completedAt = goal.completedAt;
    String doneDate = '';
    if (completedAt != null) doneDate = Formatters.fullDate(DateTime.fromMillisecondsSinceEpoch(completedAt));

    final List<Widget> milestoneChips = [];
    for (final String key in MilestoneKeys.values) {
      final bool isReached = goal.milestones.containsKey(key);
      milestoneChips.add(Expanded(child: _MilestoneChip(label: '${key.substring(1)}%', isReached: isReached)));
      if (key != MilestoneKeys.values.last) milestoneChips.add(const SizedBox(width: 6));
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const _GoalIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(
                          l10n.goalCompletedOn(Formatters.money(goal.targetAmount), doneDate),
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _Badge(label: l10n.goalCompleted, icon: Icons.check, background: AppColors.mint, foreground: AppColors.textPrimary),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: milestoneChips),
            ],
          ),
        ),
      ),
    );
  }
}

class CancelledGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final int contributionCount;
  final VoidCallback? onTap;

  const CancelledGoalCard({super.key, required this.goal, required this.contributionCount, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _GoalIcon(isMuted: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(
                          l10n.goalSavedOf(Formatters.money(goal.currentAmount), Formatters.money(goal.targetAmount)),
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _Badge(label: l10n.goalCancelled, icon: Icons.close, background: AppColors.fill, foreground: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 12),
              AppProgressBar(value: goal.progress, color: AppColors.textMuted),
              const SizedBox(height: 8),
              Text(l10n.goalKeptContributions(contributionCount), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalIcon extends StatelessWidget {
  final bool isMuted;

  const _GoalIcon({this.isMuted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isMuted ? AppColors.fill : AppColors.expenseSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.flag_outlined, color: isMuted ? AppColors.textMuted : AppColors.expense),
    );
  }
}

class _MilestoneChip extends StatelessWidget {
  final String label;
  final bool isReached;

  const _MilestoneChip({required this.label, required this.isReached});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isReached ? AppColors.honey : AppColors.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isReached ? AppColors.textPrimary : AppColors.textMuted),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _Badge({required this.label, required this.icon, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: foreground)),
        ],
      ),
    );
  }
}
