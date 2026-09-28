import 'package:flutter/material.dart';
import 'package:pennypal_student/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/support_query.dart';
import '../../utils/app_theme.dart';
import '../../widgets/success_view.dart';
import 'widgets.dart';

class SupportSentScreen extends StatelessWidget {
  final SupportQuery query;

  const SupportSentScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int? submittedAt = query.submittedAt;
    final String sentTime = submittedAt == null
        ? ''
        : DateFormat('HH:mm · dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(submittedAt));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(l10n.dashSupport, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SuccessView(
        title: l10n.supportSentTitle,
        message: l10n.supportSentBody,
        extra: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(query.subject, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(l10n.supportSentAt(sentTime), style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SupportStatusBadge(isResolved: query.isResolved),
              ],
            ),
          ),
        ),
        primaryLabel: l10n.supportSeeRequests,
        onPrimary: () => Navigator.of(context).pop(),
        secondaryLabel: l10n.commonBackHome,
        onSecondary: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
    );
  }
}
