import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/constants.dart';

/// Display names of the lesson topic and level in the current language.
class LessonLabels {
  static String topic(AppLocalizations l10n, String topic) {
    return switch (topic) {
      LearningTopics.budgeting => l10n.topicBudgeting,
      LearningTopics.saving => l10n.topicSaving,
      LearningTopics.income => l10n.topicIncome,
      LearningTopics.needsVsWants => l10n.topicNeedsVsWants,
      // Unknown values from old data fall back to the last topic instead of crashing.
      _ => l10n.topicSmartSpending,
    };
  }

  static String level(AppLocalizations l10n, String level) {
    return level == LearningLevels.intermediate ? l10n.levelIntermediate : l10n.levelBeginner;
  }
}
