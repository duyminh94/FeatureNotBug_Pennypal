import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/user_profile.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/confirm_dialog.dart';

/// Display texts for student fields (education level, join date, last login).
class UserLabels {
  static String joined(int? millis, String languageCode) {
    if (millis == null) return '–';
    return DateFormat('dd MMM yyyy', languageCode).format(DateTime.fromMillisecondsSinceEpoch(millis));
  }

  static String lastLogin(AppLocalizations l10n, int? millis, String languageCode, {DateTime? now}) {
    if (millis == null) return l10n.commonNever;
    final DateTime today = now ?? DateTime.now();
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(millis);
    final DateTime startOfToday = DateTime(today.year, today.month, today.day);
    final int daysBefore = startOfToday.difference(DateTime(time.year, time.month, time.day)).inDays;

    if (daysBefore <= 0) return l10n.commonTodayAt(DateFormat('HH:mm').format(time));
    if (daysBefore == 1) return l10n.commonYesterday;
    if (daysBefore < 7) return l10n.commonDaysAgo(daysBefore);
    return DateFormat('dd MMM', languageCode).format(time);
  }

  static String studentStatus(AppLocalizations l10n, String? status) {
    return switch (status) {
      StudentStatuses.highSchool => l10n.studentStatusHighSchool,
      StudentStatuses.undergraduate => l10n.studentStatusUndergraduate,
      StudentStatuses.postgraduate => l10n.studentStatusPostgraduate,
      StudentStatuses.other => l10n.studentStatusOther,
      _ => l10n.studentStatusNone,
    };
  }
}

/// Confirmation before locking or unlocking; locking explains the student will be signed out.
Future<bool> confirmLockChange(BuildContext context, UserProfile user) {
  final l10n = AppLocalizations.of(context)!;
  final bool willLock = user.isActive;

  return showConfirmDialog(
    context,
    title: willLock ? l10n.usersLockTitle(user.fullName) : l10n.usersUnlockTitle(user.fullName),
    message: willLock ? l10n.usersLockBody : l10n.usersUnlockBody,
    confirmLabel: willLock ? l10n.usersLockConfirm : l10n.usersUnlockConfirm,
    isDestructive: willLock,
    icon: willLock ? Icons.lock_outline : Icons.lock_open_outlined,
  );
}

/// Round avatar with the student's initials.
class UserAvatar extends StatelessWidget {
  final String name;
  final double size;

  const UserAvatar({super.key, required this.name, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.fill,
      child: Text(
        Formatters.initials(name),
        style: TextStyle(fontSize: size / 3, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      ),
    );
  }
}

/// Active / Locked label.
class UserStatusBadge extends StatelessWidget {
  final bool isActive;

  const UserStatusBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color color = isActive ? AppColors.primary : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primarySoft : AppColors.errorSoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Icons.check : Icons.lock_outline, size: 15, color: color),
          const SizedBox(width: 4),
          Text(isActive ? l10n.statusActive : l10n.statusLocked, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

/// Lock button for an active student, Unlock for a locked one.
class LockButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const LockButton({super.key, required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color color = isActive ? AppColors.error : AppColors.textPrimary;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: isActive ? AppColors.errorSoft : AppColors.border, width: 1.5),
      ),
      onPressed: onPressed,
      icon: Icon(isActive ? Icons.lock_outline : Icons.lock_open_outlined, size: 18),
      label: Text(isActive ? l10n.usersLock : l10n.usersUnlock),
    );
  }
}
