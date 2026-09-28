import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/support_query.dart';
import '../models/user_profile.dart';
import '../controllers/admin_auth_service.dart';
import '../controllers/admin_data_service.dart';
import '../controllers/support_service.dart';
import '../utils/admin_section.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/overview_calculator.dart';
import '../models/admin_data.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/language_toggle.dart';
import 'analytics_screen.dart';
import 'app_settings_screen.dart';
import 'feedbacks/screen.dart';
import 'learning/screen.dart';
import 'login_screen.dart';
import 'overview_screen.dart';
import 'support/screen.dart';
import 'users/screen.dart';

class AdminShell extends StatefulWidget {
  /// Null in the real app: the shell loads the data from Firebase. Tests pass ready-made data.
  final AdminData? data;
  final UserProfile admin;
  final Future<void> Function() signOut;
  final Stream<Map<String, List<SupportQuery>>> Function() watchSupport;

  const AdminShell({
    super.key,
    this.data,
    required this.admin,
    this.signOut = AdminAuthService.signOut,
    this.watchSupport = SupportService.watch,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  AdminSection _section = AdminSection.overview;
  late Future<AdminData> _dataFuture = _loadData();
  int _openSupport = 0;
  StreamSubscription<Map<String, List<SupportQuery>>>? _supportSubscription;

  @override
  void initState() {
    super.initState();
    _listenSupport();
  }

  @override
  void dispose() {
    _supportSubscription?.cancel();
    super.dispose();
  }

  /// Keeps the menu badge live: after a reply the count goes down without opening the Overview again.
  void _listenSupport() {
    try {
      _supportSubscription = widget.watchSupport().listen(
        (supportByUser) => setState(() => _openSupport = OverviewCalculator.openQueries(supportByUser).length),
        onError: (Object error) => debugPrint('AdminShell support badge failed: $error'),
      );
    } catch (e) {
      debugPrint('AdminShell support badge failed: $e');
    }
  }

  /// Reads the data once; the support badge is updated when it arrives.
  Future<AdminData> _loadData() {
    final AdminData? readyData = widget.data;
    final Future<AdminData> future = readyData != null ? Future.value(readyData) : AdminDataService.load();
    future.then((data) {
      if (mounted) setState(() => _openSupport = OverviewCalculator.openQueries(data.supportByUser).length);
    }).catchError((Object error) {
      debugPrint('AdminShell data failed: $error');
    });
    return future;
  }

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

  /// Opening Overview or Analytics reads the data again, so the numbers are never old.
  void _open(AdminSection section) {
    setState(() {
      _section = section;
      if (section == AdminSection.overview || section == AdminSection.analytics) _dataFuture = _loadData();
    });
  }

  Widget _withData(Widget Function(AdminData data) buildPage) {
    return FutureBuilder<AdminData>(
      future: _dataFuture,
      // Data passed in (tests) is shown at once instead of waiting one frame.
      initialData: widget.data,
      builder: (context, snapshot) {
        // After Retry the builder still holds the old error while the new read runs, so waiting is checked first.
        final bool isFirstLoad = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
        if (isFirstLoad) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) {
          final l10n = AppLocalizations.of(context)!;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(l10n.overviewLoadFailed, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: () => setState(() => _dataFuture = _loadData()), child: Text(l10n.commonRetry)),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return buildPage(snapshot.data!);
      },
    );
  }

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

  Widget _page() {
    return switch (_section) {
      AdminSection.overview => _withData((data) => OverviewScreen(data: data, onOpenSection: _open)),
      AdminSection.analytics => _withData((data) => AnalyticsScreen(data: data)),
      AdminSection.users => const UsersScreen(),
      AdminSection.learning => const LearningScreen(),
      AdminSection.support => const SupportScreen(),
      AdminSection.feedbacks => const FeedbacksScreen(),
      AdminSection.settings => const AppSettingsScreen(),
    };
  }

  Widget _iconWithBadge(AdminSection section, int openSupport) {
    final Widget icon = Icon(_icon(section));
    if (section != AdminSection.support || openSupport == 0) return icon;
    return Badge(label: Text('$openSupport'), child: icon);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int openSupport = _openSupport;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AdminLayout.wideBreakpoint && constraints.maxHeight >= AdminLayout.railMinHeight;
        return isWide ? _buildWide(l10n, openSupport) : _buildNarrow(l10n, openSupport);
      },
    );
  }

  Widget _buildWide(AppLocalizations l10n, int openSupport) {
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
                      icon: _iconWithBadge(section, openSupport),
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
                Expanded(child: _page()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrow(AppLocalizations l10n, int openSupport) {
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
                    final bool showBadge = section == AdminSection.support && openSupport > 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        selectedTileColor: AppColors.primarySoft,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        leading: Icon(_icon(section)),
                        title: Text(_label(l10n, section), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        trailing: showBadge ? Badge(label: Text('$openSupport'), largeSize: 24) : null,
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
      body: _page(),
    );
  }
}

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
