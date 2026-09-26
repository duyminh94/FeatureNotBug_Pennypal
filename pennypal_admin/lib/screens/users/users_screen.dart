import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/user_profile.dart';
import '../../utils/admin_section.dart';
import '../../utils/app_theme.dart';
import '../../utils/sample_data.dart';
import '../../utils/user_filter.dart';
import 'user_detail_screen.dart';
import 'user_widgets.dart';

class UsersScreen extends StatefulWidget {
  final AdminData data;
  final ValueChanged<UserProfile> onUserChanged;

  const UsersScreen({super.key, required this.data, required this.onUserChanged});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  UserStatusFilter _status = UserStatusFilter.all;
  int _pageIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleLock(UserProfile user) async {
    final l10n = AppLocalizations.of(context)!;
    final bool confirmed = await confirmLockChange(context, user);
    if (!confirmed || !mounted) return;

    widget.onUserChanged(UserFilter.withActive(user, !user.isActive));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(user.isActive ? l10n.usersLockedMessage(user.fullName) : l10n.usersUnlockedMessage(user.fullName)),
      ));
  }

  void _openDetail(UserProfile user) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UserDetailScreen(
        userId: user.uid,
        data: widget.data,
        onUserChanged: widget.onUserChanged,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<UserProfile> students = UserFilter.students(widget.data.users);
    final List<UserProfile> searched = UserFilter.apply(students, query: _query);
    final List<UserProfile> shown = UserFilter.apply(students, query: _query, status: _status);
    final int activeCount = searched.where((user) => user.isActive).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= AdminLayout.wideBreakpoint;
        final Widget search = TextField(
          controller: _searchController,
          onChanged: (value) => setState(() {
            _query = value;
            _pageIndex = 0;
          }),
          decoration: InputDecoration(hintText: l10n.usersSearchHint, prefixIcon: const Icon(Icons.search)),
        );
        final Widget statusFilter = SegmentedButton<UserStatusFilter>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: UserStatusFilter.all, label: Text(l10n.usersFilterAll(searched.length))),
            ButtonSegment(value: UserStatusFilter.active, label: Text(l10n.usersFilterActive(activeCount))),
            ButtonSegment(value: UserStatusFilter.locked, label: Text(l10n.usersFilterLocked(searched.length - activeCount))),
          ],
          selected: {_status},
          onSelectionChanged: (selected) => setState(() {
            _status = selected.first;
            _pageIndex = 0;
          }),
        );

        return ListView(
          padding: EdgeInsets.all(isWide ? 28 : 16),
          children: [
            if (isWide) ...[
              Text(l10n.usersSubtitle, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 16),
                  statusFilter,
                ],
              ),
            ] else ...[
              search,
              const SizedBox(height: 12),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: statusFilter),
            ],
            const SizedBox(height: 16),
            if (shown.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.usersNoMatch, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else if (isWide)
              _buildTable(l10n, shown)
            else
              ...shown.map((user) => _UserCard(user: user, onLock: () => _toggleLock(user), onOpen: () => _openDetail(user))),
          ],
        );
      },
    );
  }

  Widget _buildTable(AppLocalizations l10n, List<UserProfile> shown) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final int pageCount = UserFilter.pageCount(shown.length);
    final int pageIndex = _pageIndex >= pageCount ? pageCount - 1 : _pageIndex;
    final List<UserProfile> pageUsers = UserFilter.page(shown, pageIndex);
    final int from = pageIndex * UserFilter.pageSize + 1;
    final int to = from + pageUsers.length - 1;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              showCheckboxColumn: false,
              columns: [
                DataColumn(label: Text(l10n.usersName)),
                DataColumn(label: Text(l10n.usersEmail)),
                DataColumn(label: Text(l10n.usersMobile)),
                DataColumn(label: Text(l10n.usersJoined)),
                DataColumn(label: Text(l10n.usersLastLogin)),
                DataColumn(label: Text(l10n.usersStatus)),
                const DataColumn(label: SizedBox.shrink()),
              ],
              rows: pageUsers.map((user) {
                return DataRow(
                  onSelectChanged: (_) => _openDetail(user),
                  cells: [
                    DataCell(Row(
                      children: [
                        UserAvatar(name: user.fullName, size: 36),
                        const SizedBox(width: 10),
                        Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    )),
                    DataCell(Text(user.email)),
                    DataCell(Text(user.mobileNumber)),
                    DataCell(Text(UserLabels.joined(user.createdAt, languageCode))),
                    DataCell(Text(UserLabels.lastLogin(l10n, user.lastLogin, languageCode))),
                    DataCell(UserStatusBadge(isActive: user.isActive)),
                    DataCell(LockButton(isActive: user.isActive, onPressed: () => _toggleLock(user))),
                  ],
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.usersShowing(from, to, shown.length),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                OutlinedButton(
                  onPressed: pageIndex == 0 ? null : () => setState(() => _pageIndex = pageIndex - 1),
                  child: Text(l10n.commonPrevious),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: pageIndex >= pageCount - 1 ? null : () => setState(() => _pageIndex = pageIndex + 1),
                  child: Text(l10n.commonNext),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onLock;
  final VoidCallback onOpen;

  const _UserCard({required this.user, required this.onLock, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(name: user.fullName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(user.email, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                UserStatusBadge(isActive: user.isActive),
              ],
            ),
            const Divider(height: 24, color: AppColors.border),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                _Fact(label: l10n.usersMobile, value: user.mobileNumber),
                _Fact(label: l10n.usersJoined, value: UserLabels.joined(user.createdAt, languageCode)),
                _Fact(label: l10n.usersLastLogin, value: UserLabels.lastLogin(l10n, user.lastLogin, languageCode)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(onPressed: onOpen, child: Text(l10n.usersViewDetails)),
                LockButton(isActive: user.isActive, onPressed: onLock),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;

  const _Fact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
