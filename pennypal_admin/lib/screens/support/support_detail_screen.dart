import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/support_query.dart';
import '../../services/support_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/support_manager.dart';
import 'support_widgets.dart';

/// One support request: the student's message and the admin's reply box.
/// After replying the request becomes Resolved and can only be read, not edited.
class SupportDetailScreen extends StatefulWidget {
  /// Student who sent the request; the reply is saved under this uid.
  final String uid;
  final SupportQuery query;

  const SupportDetailScreen({super.key, required this.uid, required this.query});

  @override
  State<SupportDetailScreen> createState() => _SupportDetailScreenState();
}

class _SupportDetailScreenState extends State<SupportDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  late SupportQuery _query;

  // True while the reply is being saved, so the button cannot send it twice.
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _query = widget.query;
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  /// Saves the reply to Firebase. The screen only switches to Resolved when the save works,
  /// otherwise the typed reply stays in the box so the admin can try again.
  Future<void> _sendReply() async {
    final l10n = AppLocalizations.of(context)!;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final SupportQuery repliedQuery = SupportManager.reply(_query, _replyController.text, now);

    setState(() {
      _isSending = true;
    });
    final bool isSaved = await SupportService.reply(widget.uid, repliedQuery);
    if (!mounted) return;

    setState(() {
      _isSending = false;
      if (isSaved) _query = repliedQuery;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.supportReplySent)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.supportReplyFailed)));
    }
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
              if (_query.isResolved && response != null) _buildResolved(l10n, languageCode, response) else _buildReplyBox(l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// Reply box for an open request; the button stays off while the reply is empty or being sent.
  Widget _buildReplyBox(AppLocalizations l10n) {
    final bool canSend = SupportManager.canSendReply(_replyController.text) && !_isSending;

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

  /// Read-only view of the answer once the request is resolved.
  Widget _buildResolved(AppLocalizations l10n, String languageCode, String response) {
    String notifyText = l10n.supportStudentPending;
    if (_query.studentNotified) notifyText = l10n.supportStudentNotified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            Expanded(child: Text(notifyText)),
          ],
        ),
        const SizedBox(height: 8),
        Text(l10n.supportReadOnly, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ],
    );
  }
}
