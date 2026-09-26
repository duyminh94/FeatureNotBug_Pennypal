import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/support_query.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/sample_data.dart';
import '../../utils/support_manager.dart';
import 'support_detail_screen.dart';
import 'support_widgets.dart';

class SupportScreen extends StatefulWidget {
  final AdminData data;
  final VoidCallback onChanged;

  const SupportScreen({super.key, required this.data, required this.onChanged});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String _status = SupportStatuses.open;

  void _openDetail(SupportQuery query) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SupportDetailScreen(
        query: query,
        onReplied: (updated) {
          setState(() => SupportManager.replace(widget.data.supportByUser, updated));
          widget.onChanged();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final List<SupportQuery> open = SupportManager.withStatus(widget.data.supportByUser, SupportStatuses.open);
    final List<SupportQuery> resolved = SupportManager.withStatus(widget.data.supportByUser, SupportStatuses.resolved);
    final List<SupportQuery> shown = _status == SupportStatuses.open ? open : resolved;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: SupportStatuses.open, label: Text(l10n.supportFilterOpen(open.length))),
                ButtonSegment(value: SupportStatuses.resolved, label: Text(l10n.supportFilterResolved(resolved.length))),
              ],
              selected: {_status},
              onSelectionChanged: (selected) => setState(() => _status = selected.first),
            ),
            const SizedBox(height: 16),
            if (shown.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Icon(
                        _status == SupportStatuses.open ? Icons.mark_email_read_outlined : Icons.inbox_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _status == SupportStatuses.open ? l10n.supportEmptyOpen : l10n.supportEmptyResolved,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...shown.map((query) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _openDetail(query),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(query.subject, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  Text(query.userEmail, style: const TextStyle(color: AppColors.textSecondary)),
                                  Text(
                                    supportDate(query.submittedAt, languageCode),
                                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SupportStatusBadge(isResolved: query.isResolved),
                          ],
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
