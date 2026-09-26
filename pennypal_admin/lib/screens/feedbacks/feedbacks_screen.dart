import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/feedback_entry.dart';
import '../../utils/app_theme.dart';
import '../../utils/overview_calculator.dart';
import '../../utils/support_manager.dart';
import '../../widgets/star_rating.dart';

class FeedbacksScreen extends StatefulWidget {
  final List<FeedbackEntry> feedbacks;

  const FeedbacksScreen({super.key, required this.feedbacks});

  @override
  State<FeedbacksScreen> createState() => _FeedbacksScreenState();
}

class _FeedbacksScreenState extends State<FeedbacksScreen> {
  RatingFilter _filter = RatingFilter.all;

  String _filterLabel(AppLocalizations l10n, RatingFilter filter) {
    return switch (filter) {
      RatingFilter.all => l10n.feedbackAll,
      RatingFilter.five => l10n.feedbackStars(5),
      RatingFilter.four => l10n.feedbackStars(4),
      RatingFilter.three => l10n.feedbackStars(3),
      RatingFilter.lowest => l10n.feedbackLowest,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String languageCode = Localizations.localeOf(context).languageCode;
    final double? average = OverviewCalculator.averageRating(widget.feedbacks);
    final List<FeedbackEntry> shown = FeedbackFilter.apply(widget.feedbacks, _filter);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: average == null
                    ? Text(l10n.feedbackEmpty, style: const TextStyle(color: AppColors.textSecondary))
                    : Row(
                        children: [
                          Text(
                            NumberFormat('0.0', languageCode).format(average),
                            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StarRating(rating: average, size: 22),
                                const SizedBox(height: 4),
                                Text(l10n.feedbackFrom(widget.feedbacks.length), style: const TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RatingFilter.values.map((filter) {
                final bool isSelected = filter == _filter;
                return ChoiceChip(
                  label: Text(_filterLabel(l10n, filter)),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.textPrimary,
                  labelStyle: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimary),
                  onSelected: (_) => setState(() => _filter = filter),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (shown.isEmpty && widget.feedbacks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.feedbackEmptyFilter, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ...shown.map((feedback) {
              final int? submittedAt = feedback.submittedAt;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(feedback.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                          if (submittedAt != null)
                            Text(
                              DateFormat('dd MMM', languageCode).format(DateTime.fromMillisecondsSinceEpoch(submittedAt)),
                              style: const TextStyle(color: AppColors.textMuted),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      StarRating(rating: feedback.rating.toDouble()),
                      const SizedBox(height: 8),
                      feedback.comments.isEmpty
                          ? Text(l10n.feedbackNoComment, style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textMuted))
                          : Text(feedback.comments, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
