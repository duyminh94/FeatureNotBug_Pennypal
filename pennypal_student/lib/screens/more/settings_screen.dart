import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/locale_service.dart';
import '../../services/user_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/category_display.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/profile_avatar.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfile profile;
  final Future<bool> Function(UserProfile profile) saveProfile;
  final Future<void> Function() signOut;

  const SettingsScreen({
    super.key,
    required this.profile,
    this.saveProfile = UserService.saveProfile,
    this.signOut = AuthService.signOut,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _noStatus = '';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(text: widget.profile.fullName);
  late final TextEditingController _mobileController = TextEditingController(text: widget.profile.mobileNumber);
  late String? _studentStatus = widget.profile.studentStatus;
  late String _currency = widget.profile.currency;
  late bool _notificationsEnabled = widget.profile.notificationsEnabled;
  bool _hasTriedToSave = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _hasTriedToSave = true);
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final UserProfile old = widget.profile;
    final UserProfile saved = UserProfile(
      uid: old.uid,
      fullName: _nameController.text.trim(),
      email: old.email,
      mobileNumber: _mobileController.text.trim(),
      studentStatus: _studentStatus,
      role: old.role,
      isActive: old.isActive,
      currency: _currency,
      notificationsEnabled: _notificationsEnabled,
      createdAt: old.createdAt,
      lastLogin: old.lastLogin,
    );
    setState(() => _isSaving = true);
    final bool isSaved = await widget.saveProfile(saved);
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(isSaved ? l10n.settingsSaved : l10n.errorUnknown)));
    if (isSaved) {
      Formatters.setCurrency(saved.currency);
      Navigator.of(context).pop(saved);
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final bool confirmed = await showConfirmDialog(
      context,
      title: l10n.settingsLogoutTitle,
      message: l10n.settingsLogoutBody,
      confirmLabel: l10n.settingsLogout,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.menuSettings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _hasTriedToSave ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Center(child: ProfileAvatar(fullName: widget.profile.fullName, size: 96)),
            const SizedBox(height: 8),
            Text(
              widget.profile.email,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: l10n.authFullName,
              icon: Icons.person_outline,
              controller: _nameController,
              validator: (value) => Validators.isEmpty(value) ? l10n.validationRequired : null,
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: l10n.authMobile,
              icon: Icons.phone_iphone,
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (Validators.isEmpty(value)) return l10n.validationRequired;
                return Validators.isValidMobile(value) ? null : l10n.validationMobile;
              },
            ),
            const SizedBox(height: 16),
            _Label(icon: Icons.school_outlined, text: l10n.settingsStudentStatus),
            DropdownButtonFormField<String>(
              initialValue: _studentStatus ?? _noStatus,
              onChanged: (value) => setState(() => _studentStatus = value == _noStatus ? null : value),
              items: [
                DropdownMenuItem(value: _noStatus, child: Text(l10n.settingsNoStatus)),
                ...StudentStatuses.values.map(
                  (status) => DropdownMenuItem(value: status, child: Text(StudentStatusDisplay.name(l10n, status))),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Label(icon: Icons.language, text: l10n.settingsLanguage),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'vi', label: Text('Tiếng Việt')),
              ],
              selected: {languageCode},
              onSelectionChanged: (selected) => LocaleService.change(selected.first),
            ),
            const SizedBox(height: 20),
            _Label(icon: Icons.payments_outlined, text: l10n.settingsCurrency),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: Currencies.vnd, label: Text('VND · ₫')),
                ButtonSegment(value: Currencies.usd, label: Text('USD · \$')),
              ],
              selected: {_currency},
              onSelectionChanged: (selected) => setState(() => _currency = selected.first),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l10n.settingsCurrencyNote, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
                secondary: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.expenseSoft, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.notifications_none, color: AppColors.expense),
                ),
                title: Text(l10n.settingsNotifications, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                subtitle: Text(l10n.settingsNotificationsBody),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _isSaving ? null : _save, child: Text(l10n.txSaveChanges)),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.expenseSoft, foregroundColor: AppColors.expense),
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text(l10n.settingsLogout),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Label({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
