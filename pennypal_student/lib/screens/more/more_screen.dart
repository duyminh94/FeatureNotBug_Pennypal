import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../widgets/profile_avatar.dart';
import '../categories/categories_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../learning/learning_screen.dart';
import '../reports/reports_screen.dart';
import '../support/feedback_screen.dart';
import '../support/support_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatefulWidget {
  final UserProfile profile;
  final int unreadCount;
  final VoidCallback? onOpenNotifications;
  final ValueChanged<UserProfile>? onProfileChanged;
  final Future<bool> Function(UserProfile profile) saveProfile;
  final Future<void> Function() signOut;

  const MoreScreen({
    super.key,
    required this.profile,
    this.unreadCount = 0,
    this.onOpenNotifications,
    this.onProfileChanged,
    this.saveProfile = UserService.saveProfile,
    this.signOut = AuthService.signOut,
  });

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late UserProfile _profile = widget.profile;

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonComingSoon)));
  }

  void _openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  void _openChatbot() {
    _openScreen(ChatbotScreen(uid: _profile.uid, userName: _profile.fullName));
  }

  Future<void> _openSettings() async {
    final UserProfile? saved = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(profile: _profile, saveProfile: widget.saveProfile, signOut: widget.signOut),
      ),
    );
    if (saved == null || !mounted) return;
    setState(() => _profile = saved);
    // MainShell needs the new "notifications on/off" setting for the bell badge.
    widget.onProfileChanged?.call(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(
              l10n.navMore,
              style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _ProfileCard(profile: _profile, onTap: _openSettings),
            const SizedBox(height: 16),
            _MenuGroup(items: [
              _MenuItem(
                icon: Icons.bar_chart,
                label: l10n.menuReports,
                color: AppColors.info,
                background: AppColors.infoSoft,
                onTap: () => _openScreen(ReportsScreen(uid: _profile.uid)),
              ),
              _MenuItem(
                icon: Icons.sell_outlined,
                label: l10n.menuCategories,
                color: AppColors.purple,
                background: AppColors.purpleSoft,
                onTap: () => _openScreen(CategoriesScreen(uid: _profile.uid)),
              ),
              _MenuItem(
                icon: Icons.notifications_none,
                label: l10n.dashNotifications,
                color: AppColors.expense,
                background: AppColors.expenseSoft,
                onTap: widget.onOpenNotifications ?? _showComingSoon,
                badgeCount: widget.unreadCount,
              ),
              _MenuItem(
                icon: Icons.chat_bubble_outline,
                label: l10n.menuChatbot,
                color: AppColors.primary,
                background: AppColors.mintSoft,
                onTap: _openChatbot,
              ),
            ]),
            const SizedBox(height: 16),
            _MenuGroup(items: [
              _MenuItem(
                icon: Icons.menu_book_outlined,
                label: l10n.menuLearning,
                color: AppColors.honeyText,
                background: AppColors.honeySoft,
                onTap: () => _openScreen(const LearningScreen()),
              ),
              _MenuItem(
                icon: Icons.star_outline,
                label: l10n.dashFeedback,
                color: AppColors.orange,
                background: AppColors.orangeSoft,
                onTap: () => _openScreen(FeedbackScreen(profile: _profile)),
              ),
              _MenuItem(
                icon: Icons.support_outlined,
                label: l10n.dashSupport,
                color: AppColors.teal,
                background: AppColors.tealSoft,
                onTap: () => _openScreen(const SupportScreen()),
              ),
            ]),
            const SizedBox(height: 16),
            _MenuGroup(items: [
              _MenuItem(
                icon: Icons.info_outline,
                label: l10n.menuAbout,
                color: AppColors.textSecondary,
                background: AppColors.fill,
                onTap: () => _openScreen(const AboutScreen()),
              ),
              _MenuItem(
                icon: Icons.settings_outlined,
                label: l10n.menuSettings,
                color: AppColors.textSecondary,
                background: AppColors.fill,
                onTap: _openSettings,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onTap;

  const _ProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String? status = profile.studentStatus;

    return Material(
      color: AppColors.pink,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.textPrimary, width: 3),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ProfileAvatar(fullName: profile.fullName),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    Text(profile.email, style: const TextStyle(fontSize: 14)),
                    if (status != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(99)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school_outlined, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                StudentStatusDisplay.name(l10n, status),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  final int badgeCount;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
    this.badgeCount = 0,
  });
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int index = 0; index < items.length; index++) ...[
            if (index > 0) const Divider(height: 1, color: AppColors.border),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              onTap: items[index].onTap,
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: items[index].background, borderRadius: BorderRadius.circular(14)),
                child: Icon(items[index].icon, color: items[index].color),
              ),
              title: Text(items[index].label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (items[index].badgeCount > 0)
                    Badge(
                      largeSize: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      label: Text('${items[index].badgeCount}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
