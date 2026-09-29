import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/support_query.dart';
import '../../controllers/support_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/pager.dart';
import '../../utils/support_manager.dart';
import '../../widgets/page_controls.dart';
import 'detail_screen.dart';
import 'widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late Stream<Map<String, List<SupportQuery>>> _supportStream;

  String _status = SupportStatuses.open;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _openStream();
  }

  void _openStream() {
    try {
      _supportStream = SupportService.watch();
    } catch (e) {
      _supportStream = Stream.error(e);
    }
  }

  void _retry() {
    setState(() {
      _openStream();
    });
  }

  void _openDetail(Map<String, List<SupportQuery>> supportByUser, SupportQuery query) {
    final String? uid = SupportManager.ownerOf(supportByUser, query.id);
    if (uid == null) return;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SupportDetailScreen(uid: uid, query: query),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<Map<String, List<SupportQuery>>>(
      stream: _supportStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _LoadError(message: l10n.supportLoadFailed, onRetry: _retry);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildList(l10n, snapshot.data!);
      },
    );
  }

  Widget _buildList(AppLocalizations l10n, Map<String, List<SupportQuery>> supportByUser) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final List<SupportQuery> open = SupportManager.withStatus(supportByUser, SupportStatuses.open);
    final List<SupportQuery> resolved = SupportManager.withStatus(supportByUser, SupportStatuses.resolved);

    List<SupportQuery> shown = open;
    if (_status == SupportStatuses.resolved) shown = resolved;

    final int pageIndex = Pager.safePage(_pageIndex, shown.length);
    final List<Widget> requestCards = [];
    for (final SupportQuery query in Pager.page(shown, pageIndex)) {
      requestCards.add(_RequestCard(
        query: query,
        languageCode: languageCode,
        onTap: () => _openDetail(supportByUser, query),
      ));
    }

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
              onSelectionChanged: (selected) {
                setState(() {
                  _status = selected.first;
                  _pageIndex = 0;
                });
              },
            ),
            const SizedBox(height: 16),
            if (shown.isEmpty) _buildEmpty(l10n) else ...requestCards,
            if (Pager.pageCount(shown.length) > 1)
              PageControls(
                pageIndex: pageIndex,
                total: shown.length,
                onPageChanged: (newPage) {
                  setState(() {
                    _pageIndex = newPage;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    IconData icon = Icons.mark_email_read_outlined;
    String message = l10n.supportEmptyOpen;
    if (_status == SupportStatuses.resolved) {
      icon = Icons.inbox_outlined;
      message = l10n.supportEmptyResolved;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SupportQuery query;
  final String languageCode;
  final VoidCallback onTap;

  const _RequestCard({required this.query, required this.languageCode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
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
    );
  }
}

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
