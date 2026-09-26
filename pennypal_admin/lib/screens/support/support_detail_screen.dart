import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/support_query.dart';
import '../../utils/app_theme.dart';
import '../../utils/support_manager.dart';
import 'support_widgets.dart';

class SupportDetailScreen extends StatefulWidget {
  final SupportQuery query;
  final ValueChanged<SupportQuery> onReplied;

  const SupportDetailScreen({super.key, required this.query, required this.onReplied});

  @override
  State<SupportDetailScreen> createState() => _SupportDetailScreenState();
}

class _SupportDetailScreenState extends State<SupportDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  late SupportQuery _query = widget.query;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _sendReply() {
    final l10n = AppLocalizations.of(context)!;
    final SupportQuery updated = SupportManager.reply(_query, _replyController.text, DateTime.now().millisecondsSinceEpoch);
    setState(() => _query = updated);
    widget.onReplied(updated);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.supportReplySent)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final String? response = _query.adminResponse;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportRequestTitle, style: const TextStyle(fontWeight: FontWeight.w800))),
      body: Align(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(_query.subject, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                          const SizedBox(width: 8),
                          SupportStatusBadge(isResolved: _query.isResolved),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.mail_outline, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${_query.userEmail} · ${supportDate(_query.submittedAt, languageCode)}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(12)),
                        child: Text(_query.message, style: const TextStyle(fontSize: 16, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_query.isResolved && response != null)
                ..._buildResolved(l10n, languageCode, response)
              else
                _buildReplyBox(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyBox(AppLocalizations l10n) {
    final bool canSend = SupportManager.canSendReply(_replyController.text);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.supportYourReply, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _replyController,
              minLines: 5,
              maxLines: 10,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: l10n.supportReplyHint),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(l10n.supportMarksResolved, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                FilledButton.icon(
                  onPressed: canSend ? _sendReply : null,
                  icon: const Icon(Icons.send_outlined),
                  label: Text(l10n.supportSendReply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResolved(AppLocalizations l10n, String languageCode, String response) {
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFB9E6D3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.send_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.supportRepliedAt(supportDate(_query.respondedAt, languageCode)),
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(response, style: const TextStyle(fontSize: 16, height: 1.4)),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          const Icon(Icons.notifications_none, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(_query.studentNotified ? l10n.supportStudentNotified : l10n.supportStudentPending)),
        ],
      ),
      const SizedBox(height: 8),
      Text(l10n.supportReadOnly, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
    ];
  }
}
