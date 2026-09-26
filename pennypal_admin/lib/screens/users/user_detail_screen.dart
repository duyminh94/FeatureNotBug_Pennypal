import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/user_filter.dart';
import 'user_widgets.dart';

/// Details of one student: profile, how many transactions and goals they have,
/// and the Lock / Unlock button. The admin never sees the amounts, only counts.
class UserDetailScreen extends StatefulWidget {
  final UserProfile user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late UserProfile _user;

  // Null while loading or when the count could not be read; the card then shows "–".
  int? _transactionCount;
  int? _goalCount;

  // True while the lock change is being saved, so the button cannot be pressed twice.
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadCounts();
  }

  /// Reads the two counts once when the screen opens.
  Future<void> _loadCounts() async {
    final int? transactionCount = await UserService.countTransactions(_user.uid);
    final int? goalCount = await UserService.countGoals(_user.uid);
    if (!mounted) return;

    setState(() {
      _transactionCount = transactionCount;
      _goalCount = goalCount;
    });
  }

  /// Asks first, then saves the new lock state. The screen only changes when the save works.
  Future<void> _toggleLock() async {
    final l10n = AppLocalizations.of(context)!;
    final bool confirmed = await confirmLockChange(context, _user);
    if (!confirmed || !mounted) return;

    setState(() {
      _isSaving = true;
    });
    final bool isSaved = await UserService.setActive(_user.uid, !_user.isActive);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      if (isSaved) _user = UserFilter.withActive(_user, !_user.isActive);
    });

    if (!isSaved) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.usersSaveFailed)));
    }
  }

  /// Count as text for the current language, or "–" when it is not available.
  String _countText(int? count, String languageCode) {
    if (count == null) return '–';
    return Formatters.count(count, languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final int? lastLogin = _user.lastLogin;

    String lastLoginText = l10n.commonNever;
    if (lastLogin != null) {
      lastLoginText = DateFormat('dd MMM yyyy, HH:mm', languageCode).format(DateTime.fromMillisecondsSinceEpoch(lastLogin));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.userDetailTitle, style: const TextStyle(fontWeight: FontWeight.w800))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          UserAvatar(name: _user.fullName, size: 64),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 6),
                                UserStatusBadge(isActive: _user.isActive),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(label: l10n.usersEmail, value: _user.email),
                      _InfoRow(label: l10n.usersMobile, value: _user.mobileNumber),
                      _InfoRow(label: l10n.userDetailStudentStatus, value: UserLabels.studentStatus(l10n, _user.studentStatus)),
                      _InfoRow(label: l10n.userDetailCurrency, value: _user.currency),
                      _InfoRow(label: l10n.usersJoined, value: UserLabels.joined(_user.createdAt, languageCode)),
                      _InfoRow(
                        label: l10n.usersLastLogin,
                        value: lastLoginText,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _CountCard(label: l10n.userDetailTransactions, value: _countText(_transactionCount, languageCode))),
                  const SizedBox(width: 12),
                  Expanded(child: _CountCard(label: l10n.userDetailGoals, value: _countText(_goalCount, languageCode))),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.infoSoft, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_user_outlined, color: AppColors.info),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l10n.userDetailPrivacy, style: const TextStyle(color: AppColors.info, fontSize: 15))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: _user.isActive ? AppColors.error : AppColors.primary,
                ),
                onPressed: _isSaving ? null : _toggleLock,
                icon: Icon(_user.isActive ? Icons.lock_outline : Icons.lock_open_outlined),
                label: Text(_user.isActive ? l10n.usersLockConfirm : l10n.usersUnlockConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One line of the profile card: label on the left, value on the right.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({required this.label, required this.value, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showDivider ? const Border(bottom: BorderSide(color: AppColors.border)) : null,
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// Small card with one number, e.g. the transaction count.
class _CountCard extends StatelessWidget {
  final String label;
  final String value;

  const _CountCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
