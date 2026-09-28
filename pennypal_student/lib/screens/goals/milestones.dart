import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/savings_goal.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/goal_calculator.dart';

/// The 25% / 50% / 75% / 100% milestones of a goal.
/// The student marks a milestone by hand once the saved money reaches it; the mark date is shown after.
class GoalMilestones extends StatelessWidget {
  final SavingsGoal goal;

  /// Called with the milestone key ("m25", "m50"…) when the student presses Mark.
  final ValueChanged<String> onMark;

  const GoalMilestones({super.key, required this.goal, required this.onMark});

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    for (final String key in MilestoneKeys.values) {
      items.add(Expanded(
        child: _MilestoneItem(
          percent: int.parse(key.substring(1)),
          markedAt: goal.milestones[key],
          canMark: GoalCalculator.canMarkMilestone(goal, key),
          onMark: () => onMark(key),
        ),
      ));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: items),
      ),
    );
  }
}

/// One milestone circle with what is under it:
/// the mark date (already marked), a Mark button (reached) or just the percent (not reached yet, locked).
class _MilestoneItem extends StatelessWidget {
  final int percent;
  final int? markedAt;
  final bool canMark;
  final VoidCallback onMark;

  const _MilestoneItem({required this.percent, required this.markedAt, required this.canMark, required this.onMark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int? date = markedAt;
    final bool isMarked = date != null;
    final bool isLocked = !isMarked && !canMark;

    // Circle colors: honey when marked, light honey when it can be marked, grey when locked.
    Color circleColor = AppColors.fill;
    Color borderColor = AppColors.border;
    double borderWidth = 2;
    if (isMarked) {
      circleColor = AppColors.honey;
      borderColor = AppColors.textPrimary;
      borderWidth = 3;
    } else if (canMark) {
      circleColor = AppColors.honeySoft;
      borderColor = AppColors.honey;
    }

    Widget circleContent;
    if (isLocked) {
      circleContent = const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 22);
    } else {
      circleContent = Text('$percent%', style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 16, fontWeight: FontWeight.w800));
    }

    final Widget circle = Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: circleContent,
    );

    Widget below;
    if (isMarked) {
      below = Text(
        DateFormat('dd/MM').format(DateTime.fromMillisecondsSinceEpoch(date)),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      );
    } else if (canMark) {
      below = SizedBox(
        height: 32,
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 32),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          onPressed: onMark,
          child: Text(l10n.goalMark),
        ),
      );
    } else {
      below = Text('$percent%', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary));
    }

    // Screen readers say "locked" for a milestone that is not reached yet.
    String? semanticsLabel;
    if (isLocked) semanticsLabel = l10n.goalMilestoneLocked(percent);

    return Semantics(
      label: semanticsLabel,
      child: Column(
        children: [
          circle,
          const SizedBox(height: 8),
          below,
        ],
      ),
    );
  }
}
