import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/app_settings.dart';
import '../../models/support_query.dart';
import '../../utils/app_theme.dart';
import '../../utils/sample_data.dart';
import 'support_form_screen.dart';
import 'support_sent_screen.dart';
import 'support_widgets.dart';

class SupportScreen extends StatefulWidget {
  final List<SupportQuery>? initialQueries;
  final AppSettings? settings;

  const SupportScreen({super.key, this.initialQueries, this.settings});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late final List<SupportQuery> _queries = [...(widget.initialQueries ?? SampleData.supportQueries())]
    ..sort((a, b) => (b.submittedAt ?? 0).compareTo(a.submittedAt ?? 0));
  late final String _supportEmail = (widget.settings ?? SampleData.appSettings()).supportEmail;
  final Set<String> _openedIds = {};

  Future<void> _openNewRequest() async {
    final SupportQuery? sent = await Navigator.of(context).push<SupportQuery>(
      MaterialPageRoute(builder: (context) => const SupportFormScreen()),
    );
    if (sent == null || !mounted) return;

    setState(() => _queries.insert(0, sent));
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => SupportSentScreen(query: sent)));
  }

  void _toggle(SupportQuery query) {
    setState(() {
      if (_openedIds.contains(query.id)) {
        _openedIds.remove(query.id);
      } else {
        _openedIds.add(query.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.dashSupport, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (_supportEmail.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(18),
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
                        Text(
                          _supportEmail,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Text(
            l10n.supportMyRequests,
            style: const TextStyle(fontFamily: AppFonts.heading, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (_queries.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.supportNoRequests, style: const TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ..._queries.map((query) => _QueryCard(
                  query: query,
                  isOpened: _openedIds.contains(query.id),
                  onTap: () => _toggle(query),
                )),
        ],
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
                const SizedBox(height: 10),
                Text(query.message, style: const TextStyle(fontSize: 15)),
              ],
              if (response != null && response.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.mintSoft, borderRadius: BorderRadius.circular(16)),
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
                      const SizedBox(height: 6),
                      Text(response, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
