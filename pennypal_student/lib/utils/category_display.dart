import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../models/category.dart';
import 'app_theme.dart';
import 'constants.dart';

class PaymentModeDisplay {
  static String name(AppLocalizations l10n, String? mode) {
    return switch (mode) {
      PaymentModes.cash => l10n.paymentCash,
      PaymentModes.bankTransfer => l10n.paymentBankTransfer,
      PaymentModes.eWallet => l10n.paymentEWallet,
      _ => l10n.paymentOther,
    };
  }
}

class LearningDisplay {
  static String topicName(AppLocalizations l10n, String topic) {
    return switch (topic) {
      LearningTopics.budgeting => l10n.topicBudgeting,
      LearningTopics.saving => l10n.topicSaving,
      LearningTopics.income => l10n.topicIncome,
      LearningTopics.needsVsWants => l10n.topicNeedsVsWants,
      _ => l10n.topicSmartSpending,
    };
  }

  static IconData topicIcon(String topic) {
    return switch (topic) {
      LearningTopics.budgeting => Icons.pie_chart_outline,
      LearningTopics.saving => Icons.savings_outlined,
      LearningTopics.income => Icons.work_outline,
      LearningTopics.needsVsWants => Icons.shopping_bag_outlined,
      _ => Icons.lightbulb_outline,
    };
  }

  static Color topicColor(String topic) {
    return switch (topic) {
      LearningTopics.budgeting => AppColors.honeyText,
      LearningTopics.saving => AppColors.primary,
      LearningTopics.income => AppColors.info,
      LearningTopics.needsVsWants => AppColors.expense,
      _ => AppColors.purple,
    };
  }

  static Color topicSoftColor(String topic) {
    return switch (topic) {
      LearningTopics.budgeting => AppColors.honeySoft,
      LearningTopics.saving => AppColors.mintSoft,
      LearningTopics.income => AppColors.infoSoft,
      LearningTopics.needsVsWants => AppColors.expenseSoft,
      _ => AppColors.purpleSoft,
    };
  }

  static String levelName(AppLocalizations l10n, String level) {
    return level == LearningLevels.intermediate ? l10n.levelIntermediate : l10n.levelBeginner;
  }
}

class StudentStatusDisplay {
  static String name(AppLocalizations l10n, String? status) {
    return switch (status) {
      StudentStatuses.highSchool => l10n.studentStatusHighSchool,
      StudentStatuses.undergraduate => l10n.studentStatusUndergraduate,
      StudentStatuses.postgraduate => l10n.studentStatusPostgraduate,
      _ => l10n.studentStatusOther,
    };
  }
}

class CategoryDisplay {
  static List<Category> customCategories = [];

  static Category? findCustom(String categoryId) {
    for (final Category category in customCategories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  static List<String> selectableIds(String type) {
    final List<String> ids = [...(type == TransactionTypes.income ? CategoryKeys.income : CategoryKeys.selectableExpense)];
    for (final Category category in customCategories) {
      if (category.type == type) ids.add(category.id);
    }
    return ids;
  }

  static String name(AppLocalizations l10n, String categoryId) {
    final Category? custom = findCustom(categoryId);
    if (custom != null) return custom.name ?? '';

    return switch (categoryId) {
      CategoryKeys.food => l10n.categoryFood,
      CategoryKeys.transport => l10n.categoryTransport,
      CategoryKeys.education => l10n.categoryEducation,
      CategoryKeys.shopping => l10n.categoryShopping,
      CategoryKeys.entertainment => l10n.categoryEntertainment,
      CategoryKeys.bills => l10n.categoryBills,
      CategoryKeys.savings => l10n.categorySavings,
      CategoryKeys.allowance => l10n.categoryAllowance,
      CategoryKeys.scholarship => l10n.categoryScholarship,
      CategoryKeys.partTime => l10n.categoryPartTime,
      CategoryKeys.internship => l10n.categoryInternship,
      CategoryKeys.gift => l10n.categoryGift,
      CategoryKeys.otherIncome => l10n.categoryOtherIncome,
      _ => l10n.categoryMiscellaneous,
    };
  }

  static String iconName(String categoryId) {
    final Category? custom = findCustom(categoryId);
    if (custom != null) return custom.icon;

    return switch (categoryId) {
      CategoryKeys.food => 'restaurant',
      CategoryKeys.transport => 'directions_bus',
      CategoryKeys.education => 'school',
      CategoryKeys.shopping => 'shopping_bag',
      CategoryKeys.entertainment => 'movie',
      CategoryKeys.bills => 'receipt_long',
      CategoryKeys.savings => 'savings',
      CategoryKeys.allowance => 'family_restroom',
      CategoryKeys.scholarship => 'emoji_events',
      CategoryKeys.partTime => 'work',
      CategoryKeys.internship => 'badge',
      CategoryKeys.gift => 'card_giftcard',
      CategoryKeys.otherIncome => 'attach_money',
      _ => 'more_horiz',
    };
  }

  static Color customColor(String colorKey) {
    return switch (colorKey) {
      'orange' => AppColors.orange,
      'pink' => AppColors.expense,
      'purple' => AppColors.purple,
      'teal' => AppColors.teal,
      'gold' => AppColors.gold,
      'info' => AppColors.info,
      'honey' => AppColors.honeyText,
      _ => AppColors.primary,
    };
  }

  static Color customSoftColor(String colorKey) {
    return switch (colorKey) {
      'orange' => AppColors.orangeSoft,
      'pink' => AppColors.expenseSoft,
      'purple' => AppColors.purpleSoft,
      'teal' => AppColors.tealSoft,
      'gold' => AppColors.goldSoft,
      'info' => AppColors.infoSoft,
      'honey' => AppColors.honeySoft,
      _ => AppColors.mintSoft,
    };
  }

  static Color color(String categoryId) {
    final Category? custom = findCustom(categoryId);
    if (custom?.color != null) return customColor(custom!.color!);

    return switch (categoryId) {
      CategoryKeys.food => AppColors.orange,
      CategoryKeys.transport => AppColors.info,
      CategoryKeys.education => AppColors.purple,
      CategoryKeys.shopping => AppColors.expense,
      CategoryKeys.entertainment => AppColors.honeyText,
      CategoryKeys.bills || CategoryKeys.miscellaneous => AppColors.teal,
      CategoryKeys.savings => AppColors.gold,
      _ => AppColors.primary,
    };
  }

  static Color chartColor(String categoryId) {
    final Category? custom = findCustom(categoryId);
    if (custom?.color != null) return customColor(custom!.color!);

    return switch (categoryId) {
      CategoryKeys.food => const Color(0xFFFF9A52),
      CategoryKeys.entertainment => const Color(0xFFFFC53D),
      CategoryKeys.transport => const Color(0xFF4DA3FF),
      CategoryKeys.shopping => const Color(0xFFFF8FAB),
      CategoryKeys.education => const Color(0xFF8B7CF6),
      CategoryKeys.bills => const Color(0xFF3BB4A1),
      CategoryKeys.savings => AppColors.gold,
      _ => const Color(0xFFA39BA8),
    };
  }

  static Color softColor(String categoryId) {
    final Category? custom = findCustom(categoryId);
    if (custom?.color != null) return customSoftColor(custom!.color!);

    return switch (categoryId) {
      CategoryKeys.food => AppColors.orangeSoft,
      CategoryKeys.transport => AppColors.infoSoft,
      CategoryKeys.education => AppColors.purpleSoft,
      CategoryKeys.shopping => AppColors.expenseSoft,
      CategoryKeys.entertainment => AppColors.honeySoft,
      CategoryKeys.bills || CategoryKeys.miscellaneous => AppColors.tealSoft,
      CategoryKeys.savings => AppColors.goldSoft,
      _ => AppColors.mintSoft,
    };
  }
}
