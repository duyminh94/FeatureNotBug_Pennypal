import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/app_settings.dart';
import '../utils/app_theme.dart';
import '../utils/lesson_editor.dart';
import '../utils/settings_validator.dart';

class AppSettingsScreen extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSaved;

  const AppSettingsScreen({super.key, required this.settings, required this.onSaved});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  late final TextEditingController _emailController = TextEditingController(text: widget.settings.supportEmail);
  late final TextEditingController _messageEnController = TextEditingController(text: widget.settings.announcementEn);
  late final TextEditingController _messageViController = TextEditingController(text: widget.settings.announcementVi);
  late int _threshold = widget.settings.defaultAlertThreshold.clamp(SettingsValidator.minThreshold, SettingsValidator.maxThreshold);
  late bool _announcementActive = widget.settings.announcementActive;
  late int? _updatedAt = widget.settings.updatedAt;

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _messageEnController.dispose();
    _messageViController.dispose();
    super.dispose();
  }

  bool get _canSave => SettingsValidator.canSave(
        threshold: _threshold,
        supportEmail: _emailController.text,
        announcementActive: _announcementActive,
        announcementEn: _messageEnController.text,
        announcementVi: _messageViController.text,
      );

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final AppSettings saved = SettingsValidator.build(
      threshold: _threshold,
      supportEmail: _emailController.text,
      announcementActive: _announcementActive,
      announcementEn: _messageEnController.text,
      announcementVi: _messageViController.text,
      updatedAt: now,
    );
    setState(() => _updatedAt = now);
    widget.onSaved(saved);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
  }

  String _missingMessage(AppLocalizations l10n, List<LessonLanguage> missing) {
    if (missing.length == 2) return l10n.settingsMissingBoth;
    return missing.first == LessonLanguage.en ? l10n.settingsMissingEn : l10n.settingsMissingVi;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final bool isEmailValid = SettingsValidator.isValidSupportEmail(_emailController.text);
    final List<LessonLanguage> missing = SettingsValidator.missingAnnouncement(_messageEnController.text, _messageViController.text);
    final bool isEnglishTab = _tabController.index == 0;
    final int? updatedAt = _updatedAt;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.settingsBudgetSupport, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Text(l10n.settingsThreshold, style: const TextStyle(fontWeight: FontWeight.w700))),
                        Text('$_threshold%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Slider(
                      value: _threshold.toDouble(),
                      min: SettingsValidator.minThreshold.toDouble(),
                      max: SettingsValidator.maxThreshold.toDouble(),
                      divisions: (SettingsValidator.maxThreshold - SettingsValidator.minThreshold) ~/ 5,
                      label: '$_threshold%',
                      onChanged: (value) => setState(() => _threshold = value.round()),
                    ),
                    Row(
                      children: [
                        Expanded(child: Text('${SettingsValidator.minThreshold}%', style: const TextStyle(color: AppColors.textSecondary))),
                        Text('${SettingsValidator.maxThreshold}%', style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                    Text(l10n.settingsThresholdHelp, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    Text(l10n.settingsSupportEmail, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(errorText: isEmailValid ? null : l10n.validationEmail),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _announcementActive,
                      onChanged: (value) => setState(() => _announcementActive = value),
                      title: Text(l10n.settingsAnnouncement, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                      subtitle: Text(l10n.settingsAnnouncementHint),
                    ),
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      indicatorColor: AppColors.primary,
                      tabs: const [Tab(text: 'English'), Tab(text: 'Tiếng Việt')],
                    ),
                    const SizedBox(height: 16),
                    Text(isEnglishTab ? l10n.settingsMessageEn : l10n.settingsMessageVi, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextField(
                      key: ValueKey(isEnglishTab ? 'announcement_en' : 'announcement_vi'),
                      controller: isEnglishTab ? _messageEnController : _messageViController,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: SettingsValidator.announcementMaxLength,
                      onChanged: (_) => setState(() {}),
                    ),
                    Row(
                      children: [
                        Icon(
                          missing.isEmpty ? Icons.check : Icons.warning_amber_rounded,
                          size: 18,
                          color: missing.isEmpty ? AppColors.primary : (_announcementActive ? AppColors.error : AppColors.textMuted),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            missing.isEmpty ? l10n.settingsBothFilled : _missingMessage(l10n, missing),
                            style: TextStyle(
                              color: missing.isNotEmpty && _announcementActive ? AppColors.error : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: _canSave ? _save : null,
              child: Text(l10n.settingsSave),
            ),
            const SizedBox(height: 12),
            Text(
              updatedAt == null
                  ? l10n.settingsNeverUpdated
                  : l10n.settingsLastUpdated(
                      DateFormat('dd MMM yyyy, HH:mm', languageCode).format(DateTime.fromMillisecondsSinceEpoch(updatedAt))),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
