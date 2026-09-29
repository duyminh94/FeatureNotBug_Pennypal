import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/user_profile.dart';
import '../../controllers/push_notification_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../main_shell.dart';

class NotificationPermissionScreen extends StatelessWidget {
  final UserProfile profile;

  const NotificationPermissionScreen({super.key, required this.profile});

  Future<void> _allow(BuildContext context) async {
    await PushNotificationService.requestPermission();
    if (context.mounted) _continue(context);
  }

  Future<void> _later(BuildContext context) async {
    await PushNotificationService.markAsked();
    if (context.mounted) _continue(context);
  }

  void _continue(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainShell(profile: profile)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 190,
                        height: 190,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.expenseSoft, shape: BoxShape.circle),
                        child: Image.asset(AppAssets.pig, width: 150, height: 140, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.notifTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.notifSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      _BenefitRow(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: AppColors.honeyText,
                        background: AppColors.honeySoft,
                        title: l10n.notifBudgetTitle,
                        subtitle: l10n.notifBudgetBody,
                      ),
                      _BenefitRow(
                        icon: Icons.flag_outlined,
                        iconColor: AppColors.primary,
                        background: AppColors.mintSoft,
                        title: l10n.notifGoalTitle,
                        subtitle: l10n.notifGoalBody,
                      ),
                      _BenefitRow(
                        icon: Icons.support_outlined,
                        iconColor: AppColors.info,
                        background: AppColors.infoSoft,
                        title: l10n.notifSupportTitle,
                        subtitle: l10n.notifSupportBody,
                      ),
                    ],
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => _allow(context),
                child: Text(l10n.notifAllow),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                onPressed: () => _later(context),
                child: Text(l10n.notifLater),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.notifFootnote,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color background;
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
