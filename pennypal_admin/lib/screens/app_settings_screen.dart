import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../utils/app_theme.dart';
import '../utils/lesson_editor.dart';
import '../utils/settings_validator.dart';

/// App Settings page: reads app_settings once from Firebase, then shows the form.
/// The settings are read once (not live) so a change from elsewhere cannot wipe what the admin is typing.
class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late Future<AppSettings?> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = SettingsService.load();
  }

  /// Reads the settings again after a loading error.
  void _retry() {
    setState(() {
      _settingsFuture = SettingsService.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<AppSettings?>(
      future: _settingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final AppSettings? settings = snapshot.data;
        if (settings == null) {
          return _LoadError(message: l10n.settingsLoadFailed, onRetry: _retry);
        }
        return AppSettingsForm(settings: settings);
      },
    );
  }
}

/// The settings form: budget alert threshold, support email and the announcement banner in EN / VI.
/// Rules: threshold 50–100%, a valid support email, and an active banner needs both languages.
class AppSettingsForm extends StatefulWidget {
  final AppSettings settings;

  const AppSettingsForm({super.key, required this.settings});

  @override
  State<AppSettingsForm> createState() => _AppSettingsFormState();
}

class _AppSettingsFormState extends State<AppSettingsForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageEnController = TextEditingController();
  final TextEditingController _messageViController = TextEditingController();
  int _threshold = SettingsValidator.minThreshold;
  bool _announcementActive = false;
  int? _updatedAt;

  // True while saving, so the button cannot save twice.
  bool _isSaving = false;

  /// Fills the form with the saved settings.
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Rebuild when the tab changes so the message box switches language.
    _tabController.addListener(() {
      setState(() {});
    });

    final AppSettings settings = widget.settings;
    _emailController.text = settings.supportEmail;
    _messageEnController.text = settings.announcementEn;
    _messageViController.text = settings.announcementVi;
    _announcementActive = settings.announcementActive;
    _updatedAt = settings.updatedAt;

    // Old data may hold a value outside 50–100; keep the slider inside its range.
    _threshold = settings.defaultAlertThreshold;
    if (_threshold < SettingsValidator.minThreshold) _threshold = SettingsValidator.minThreshold;
    if (_threshold > SettingsValidator.maxThreshold) _threshold = SettingsValidator.maxThreshold;
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

  /// Saves to Firebase; "Last updated" only changes when the save works.
  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final AppSettings newSettings = SettingsValidator.build(
      threshold: _threshold,
      supportEmail: _emailController.text,
      announcementActive: _announcementActive,
      announcementEn: _messageEnController.text,
      announcementVi: _messageViController.text,
      updatedAt: now,
    );

    setState(() {
      _isSaving = true;
    });
    final bool isSaved = await SettingsService.save(newSettings);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      if (isSaved) _updatedAt = now;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsSaveFailed)));
    }
  }

  /// Hint under the message box telling which language is still missing.
  String _missingMessage(AppLocalizations l10n, List<LessonLanguage> missing) {
    if (missing.length == 2) return l10n.settingsMissingBoth;
    if (missing.first == LessonLanguage.en) return l10n.settingsMissingEn;
    return l10n.settingsMissingVi;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final bool isEmailValid = SettingsValidator.isValidSupportEmail(_emailController.text);
    final List<LessonLanguage> missing = SettingsValidator.missingAnnouncement(_messageEnController.text, _messageViController.text);
    final bool isEnglishTab = _tabController.index == 0;
    final int? updatedAt = _updatedAt;

    // Hint under the message: green check when both languages are filled,
    // red warning only when the banner is on (a missing language would then reach students).
    IconData hintIcon = Icons.check;
    Color hintColor = AppColors.primary;
    String hintText = l10n.settingsBothFilled;
    Color hintTextColor = AppColors.textSecondary;
    if (missing.isNotEmpty) {
      hintIcon = Icons.warning_amber_rounded;
      hintText = _missingMessage(l10n, missing);
      hintColor = AppColors.textMuted;
      if (_announcementActive) {
        hintColor = AppColors.error;
        hintTextColor = AppColors.error;
      }
    }

    String updatedText = l10n.settingsNeverUpdated;
    if (updatedAt != null) {
      final DateTime updatedTime = DateTime.fromMillisecondsSinceEpoch(updatedAt);
      updatedText = l10n.settingsLastUpdated(DateFormat('dd MMM yyyy, HH:mm', languageCode).format(updatedTime));
    }

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
                      onChanged: (value) {
                        setState(() {
                          _threshold = value.round();
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _announcementActive = value;
                        });
                      },
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
                        Icon(hintIcon, size: 18, color: hintColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(hintText, style: TextStyle(color: hintTextColor)),
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
              onPressed: _canSave && !_isSaving ? _save : null,
              child: Text(l10n.settingsSave),
            ),
            const SizedBox(height: 12),
            Text(
              updatedText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the settings cannot be loaded, e.g. no connection or no permission.
class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}
