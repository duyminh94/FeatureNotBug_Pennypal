import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/admin_data.dart';
import '../../models/user_profile.dart';
import '../../services/admin_auth_service.dart';
import '../../utils/admin_section.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/language_toggle.dart';
import '../login/login_screen.dart';
import '../overview/overview_screen.dart';

/// Main frame after login: the menu, the signed-in admin and the selected page.
/// Wide screens (tablet) show a side rail, phones show a drawer.
class AdminShell extends StatefulWidget {
  final UserProfile admin;
  final Future<void> Function() signOut;

  const AdminShell({super.key, required this.admin, this.signOut = AdminAuthService.signOut});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  AdminSection _section = AdminSection.overview;

  // Empty until the screens are connected to Firebase.
  final AdminData _data = AdminData.empty();

  /// Menu title of a section in the current language.
  String _label(AppLocalizations l10n, AdminSection section) {
    return switch (section) {
      AdminSection.overview => l10n.navOverview,
      AdminSection.analytics => l10n.navAnalytics,
      AdminSection.users => l10n.navUsers,
      AdminSection.learning => l10n.navLearning,
      AdminSection.support => l10n.navSupport,
      AdminSection.feedbacks => l10n.navFeedbacks,
      AdminSection.settings => l10n.navSettings,
    };
  }

  /// Menu icon of a section.
  IconData _icon(AdminSection section) {
    return switch (section) {
      AdminSection.overview => Icons.bar_chart,
      AdminSection.analytics => Icons.pie_chart_outline,
      AdminSection.users => Icons.people_outline,
      AdminSection.learning => Icons.menu_book_outlined,
      AdminSection.support => Icons.support_outlined,
      AdminSection.feedbacks => Icons.star_outline,
      AdminSection.settings => Icons.settings_outlined,
    };
  }

  /// Switches the page shown next to the menu.
  void _open(AdminSection section) => setState(() => _section = section);

  /// Asks for confirmation, signs out, then goes back to login and clears the page history.
  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final bool confirmed = await showConfirmDialog(
      context,
      title: l10n.logoutTitle,
      message: l10n.logoutBody,
      confirmLabel: l10n.navLogout,
      isDestructive: true,
      icon: Icons.logout,
    );
    if (!confirmed || !mounted) return;

    await widget.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  /// Page of the selected section; sections not built yet show their icon and name.
  Widget _page(AppLocalizations l10n) {
    if (_section == AdminSection.overview) {
      return OverviewScreen(data: _data, onOpenSection: _open);
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(_section), size: 64, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(_label(l10n, _section), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AdminLayout.wideBreakpoint;
        return isWide ? _buildWide(l10n) : _buildNarrow(l10n);
      },
    );
  }

  /// Tablet layout: rail on the left, page title and admin info on top.
  Widget _buildWide(AppLocalizations l10n) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: AppColors.surface,
            selectedIndex: _section.index,
            onDestinationSelected: (index) => _open(AdminSection.values[index]),
            labelType: NavigationRailLabelType.all,
            indicatorColor: AppColors.primarySoft,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Image.asset(AppAssets.logo, width: 64),
                  Text(l10n.adminBadge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: Text(l10n.navLogout),
                  ),
                ),
              ),
            ),
            destinations: AdminSection.values
                .map((section) => NavigationRailDestination(
                      icon: Icon(_icon(section)),
                      label: Text(_label(l10n, section)),
                    ))
                .toList(),
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
          Expanded(
            child: Column(
              children: [
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(28, 16, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_label(l10n, _section), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                      ),
                      const LanguageToggle(),
                      const SizedBox(width: 16),
                      _AdminAvatar(name: widget.admin.fullName),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.admin.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                Expanded(child: _page(l10n)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Phone layout: app bar with a drawer menu.
  Widget _buildNarrow(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_label(l10n, _section), style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _AdminAvatar(name: widget.admin.fullName),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset(AppAssets.logo, width: 64),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PennyPal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        Text(l10n.adminConsole, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: AdminSection.values.map((section) {
                    final bool isSelected = section == _section;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        selectedTileColor: AppColors.primarySoft,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        leading: Icon(_icon(section)),
                        title: Text(_label(l10n, section), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.of(context).pop();
                          _open(section);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(color: AppColors.border),
              ListTile(
                leading: _AdminAvatar(name: widget.admin.fullName),
                title: Text(widget.admin.email),
                trailing: const LanguageToggle(),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: Text(l10n.navLogout, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: _page(l10n),
    );
  }
}

/// Round avatar with the admin's initials.
class _AdminAvatar extends StatelessWidget {
  final String name;

  const _AdminAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.textPrimary,
      child: Text(Formatters.initials(name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    );
  }
}
