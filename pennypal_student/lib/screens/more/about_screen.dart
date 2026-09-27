import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';

import '../../models/app_settings.dart';
import '../../services/app_settings_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // The support email comes from app_settings, which the admin edits.
  final Future<AppSettings> _settingsFuture = AppSettingsService.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSettings>(
      future: _settingsFuture,
      builder: (context, snapshot) => _buildPage(context, snapshot.data?.supportEmail ?? ''),
    );
  }

  Widget _buildPage(BuildContext context, String supportEmail) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.aboutTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Image.asset(AppAssets.logo, height: 180, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(
            l10n.aboutVersion(AppInfo.version),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.auto_awesome,
            color: AppColors.primary,
            background: AppColors.mintSoft,
            title: l10n.aboutWhatTitle,
            lines: [l10n.aboutWhatBody],
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.honeySoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.honey),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.honeyText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l10n.aboutNotBank, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          _InfoCard(
            icon: Icons.verified_user_outlined,
            color: AppColors.info,
            background: AppColors.infoSoft,
            title: l10n.aboutDataTitle,
            lines: [l10n.aboutData1, l10n.aboutData2, l10n.aboutData3, l10n.aboutData4],
            isBulleted: true,
          ),
          if (supportEmail.isNotEmpty)
            _InfoCard(
              icon: Icons.mail_outline,
              color: AppColors.expense,
              background: AppColors.expenseSoft,
              title: l10n.aboutContactTitle,
              lines: [supportEmail],
            ),
          _InfoCard(
            icon: Icons.groups_outlined,
            color: AppColors.purple,
            background: AppColors.purpleSoft,
            title: l10n.aboutTeamTitle,
            lines: [l10n.aboutTeamBody(AppInfo.teamName)],
          ),
          _InfoCard(
            icon: Icons.menu_book_outlined,
            color: AppColors.teal,
            background: AppColors.tealSoft,
            title: l10n.aboutToolsTitle,
            lines: [l10n.aboutLibraries, l10n.aboutAiTools],
            isBulleted: true,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final List<String> lines;
  final bool isBulleted;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.lines,
    this.isBulleted = false,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle bodyStyle = TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.4);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 10),
            ...lines.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: isBulleted
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  ', style: bodyStyle),
                            Expanded(child: Text(line, style: bodyStyle)),
                          ],
                        )
                      : Text(line, style: bodyStyle),
                )),
          ],
        ),
      ),
    );
  }
}
