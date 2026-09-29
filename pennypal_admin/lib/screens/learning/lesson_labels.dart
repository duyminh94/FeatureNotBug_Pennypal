import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/constants.dart';

class LessonLabels {
  static String topic(AppLocalizations l10n, String topic) {
    return switch (topic) {
      LearningTopics.budgeting => l10n.topicBudgeting,
      LearningTopics.saving => l10n.topicSaving,
      LearningTopics.income => l10n.topicIncome,
      LearningTopics.needsVsWants => l10n.topicNeedsVsWants,
      _ => l10n.topicSmartSpending,
    };
  }

  static String level(AppLocalizations l10n, String level) {
    return level == LearningLevels.intermediate ? l10n.levelIntermediate : l10n.levelBeginner;
  }
}
