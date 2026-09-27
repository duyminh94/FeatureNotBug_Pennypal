import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/app_notification.dart';
import 'app_theme.dart';
import 'category_display.dart';
import 'constants.dart';
import 'formatters.dart';

class NotificationDisplay {
  static String title(AppLocalizations l10n, AppNotification notification) {
    return switch (notification.type) {
      NotificationTypes.budgetWarning => l10n.inboxTitleBudgetWarning,
      NotificationTypes.budgetExceeded => l10n.inboxTitleBudgetExceeded,
      NotificationTypes.goalMilestone => l10n.inboxTitleGoalMilestone,
      NotificationTypes.goalCompleted => l10n.inboxTitleGoalCompleted,
      _ => l10n.inboxTitleSupportReplied,
    };
  }

  static String message(AppLocalizations l10n, AppNotification notification) {
    final Map<String, dynamic> params = notification.params;
    final String categoryKey = params['category']?.toString() ?? DbNodes.budgetTotalKey;
    final String category =
        categoryKey == DbNodes.budgetTotalKey ? l10n.inboxMonthly : CategoryDisplay.name(l10n, categoryKey);
    final int percent = (params['percent'] as num? ?? 0).toInt();
    final String goal = params['goal']?.toString() ?? '';

    return switch (notification.type) {
      NotificationTypes.budgetWarning => l10n.inboxBudgetWarning(percent, category),
      NotificationTypes.budgetExceeded =>
        l10n.inboxBudgetExceeded(category, Formatters.money((params['amount'] as num? ?? 0).toDouble())),
      NotificationTypes.goalMilestone => l10n.inboxGoalMilestone(goal, percent),
      NotificationTypes.goalCompleted => l10n.inboxGoalCompleted(goal),
      _ => l10n.inboxSupportReplied(params['subject']?.toString() ?? ''),
    };
  }

  static IconData icon(String type) {
    return switch (type) {
      NotificationTypes.budgetWarning => Icons.account_balance_wallet_outlined,
      NotificationTypes.budgetExceeded => Icons.warning_amber_rounded,
      NotificationTypes.goalMilestone => Icons.flag_outlined,
      NotificationTypes.goalCompleted => Icons.military_tech_outlined,
      _ => Icons.support_outlined,
    };
  }

  static Color color(String type) {
    return switch (type) {
      NotificationTypes.budgetWarning => AppColors.honeyText,
      NotificationTypes.budgetExceeded || NotificationTypes.goalMilestone => AppColors.expense,
      NotificationTypes.goalCompleted => AppColors.primary,
      _ => AppColors.teal,
    };
  }

  static Color softColor(String type) {
    return switch (type) {
      NotificationTypes.budgetWarning => AppColors.honeySoft,
      NotificationTypes.budgetExceeded || NotificationTypes.goalMilestone => AppColors.expenseSoft,
      NotificationTypes.goalCompleted => AppColors.mintSoft,
      _ => AppColors.tealSoft,
    };
  }

  static int? targetTab(String type) {
    return switch (type) {
      NotificationTypes.budgetWarning || NotificationTypes.budgetExceeded => MainTabs.budget,
      NotificationTypes.goalMilestone || NotificationTypes.goalCompleted => MainTabs.goals,
      _ => null,
    };
  }

  static String timeLabel(AppLocalizations l10n, int? createdAt, {DateTime? now}) {
    if (createdAt == null) return '';
    final DateTime today = now ?? DateTime.now();
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final Duration age = today.difference(time);
    final DateTime startOfToday = DateTime(today.year, today.month, today.day);
    final DateTime startOfYesterday = DateTime(today.year, today.month, today.day - 1);

    if (age.inMinutes < 1) return l10n.inboxJustNow;
    if (age.inMinutes < 60) return l10n.inboxMinutesAgo(age.inMinutes);
    if (!time.isBefore(startOfToday)) return l10n.inboxHoursAgo(age.inHours);
    if (!time.isBefore(startOfYesterday)) return l10n.commonYesterday;
    return DateFormat('dd/MM').format(time);
  }

  static int unreadCount(List<AppNotification> notifications) {
    return notifications.where((notification) => !notification.isRead).length;
  }

  static AppNotification markRead(AppNotification notification) {
    return AppNotification(
      id: notification.id,
      type: notification.type,
      params: notification.params,
      isRead: true,
      createdAt: notification.createdAt,
    );
  }
}
