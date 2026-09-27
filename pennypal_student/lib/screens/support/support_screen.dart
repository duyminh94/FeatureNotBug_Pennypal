import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/app_settings.dart';
import '../../models/support_query.dart';
import '../../models/user_profile.dart';
import '../../services/app_settings_service.dart';
import '../../services/support_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/error_state.dart';
import 'support_form_screen.dart';
import 'support_sent_screen.dart';
import 'support_widgets.dart';

/// The student's help requests from Firebase; the admin's reply shows up here live.
class SupportScreen extends StatefulWidget {
  final UserProfile? profile;

  const SupportScreen({super.key, this.profile});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late Stream<List<SupportQuery>> _queriesStream = SupportService.watchMine();
  final Future<AppSettings> _settingsFuture = AppSettingsService.load();
  final Set<String> _openedIds = {};

  Future<void> _openNewRequest() async {
    final SupportQuery? sent = await Navigator.of(context).push<SupportQuery>(
      MaterialPageRoute(builder: (context) => const SupportFormScreen()),
    );
    if (sent == null || !mounted) return;

    // No need to add it to the list by hand: the stream already contains the new request.
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => SupportSentScreen(query: sent)));
  }

  void _reload() => setState(() => _queriesStream = SupportService.watchMine());

  void _toggle(SupportQuery query) {
    setState(() {
      if (_openedIds.contains(query.id)) {
        _openedIds.remove(query.id);
      } else {
        _openedIds.add(query.id);
      }
    });
  }

  Widget _buildEmailCard(AppLocalizations l10n) {
    return FutureBuilder<AppSettings>(
      future: _settingsFuture,
      builder: (context, snapshot) {
        final String supportEmail = snapshot.data?.supportEmail ?? '';
        if (supportEmail.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(22)),
          child: Row(
            children: [
              const Icon(Icons.mail_outline, color: AppColors.mint),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.supportEmailLabel, style: const TextStyle(fontSize: 14, color: AppColors.textOnDark)),
                    Text(supportEmail, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(AppLocalizations l10n, List<SupportQuery> queries) {
    final List<Widget> children = [
      _buildEmailCard(l10n),
      Text(
        l10n.supportMyRequests,
        style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 10),
    ];

    if (queries.isEmpty) {
      children.add(Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.supportNoRequests, style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ));
    }
    for (final SupportQuery query in queries) {
      children.add(_QueryCard(query: query, isOpened: _openedIds.contains(query.id), onTap: () => _toggle(query)));
    }

    return ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: children);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.dashSupport, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<SupportQuery>>(
        stream: _queriesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('SupportScreen load failed: ${snapshot.error}');
            return ErrorState(onRetry: _reload);
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return _buildList(l10n, snapshot.data!);
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(onPressed: _openNewRequest, icon: const Icon(Icons.add), label: Text(l10n.supportNew)),
        ),
      ),
    );
  }
}

class _QueryCard extends StatelessWidget {
  final SupportQuery query;
  final bool isOpened;
  final VoidCallback onTap;

  const _QueryCard({required this.query, required this.isOpened, required this.onTap});

  String _shortDate(int? millis) => millis == null ? '' : DateFormat('dd/MM').format(DateTime.fromMillisecondsSinceEpoch(millis));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String? response = query.adminResponse;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(query.subject, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        Text(
                          l10n.supportSentOn(_shortDate(query.submittedAt)),
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SupportStatusBadge(isResolved: query.isResolved),
                ],
              ),
              if (isOpened) ...[
                const SizedBox(height: 12),
                Text(query.message, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
                if (response != null && response.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.support_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              l10n.supportReplyFrom(_shortDate(query.respondedAt)),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(response, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
