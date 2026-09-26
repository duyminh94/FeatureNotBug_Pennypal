import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/feedback_entry.dart';
import '../../services/feedback_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/overview_calculator.dart';
import '../../utils/support_manager.dart';
import '../../widgets/star_rating.dart';

/// Feedbacks page: loads every rating students gave the app from Firebase.
/// The admin can only read them, there is nothing to edit here.
class FeedbacksScreen extends StatefulWidget {
  const FeedbacksScreen({super.key});

  @override
  State<FeedbacksScreen> createState() => _FeedbacksScreenState();
}

class _FeedbacksScreenState extends State<FeedbacksScreen> {
  late Stream<List<FeedbackEntry>> _feedbackStream;

  @override
  void initState() {
    super.initState();
    _openStream();
  }

  /// Starts listening to feedbacks. If Firebase is not ready the screen
  /// shows the error box instead of crashing.
  void _openStream() {
    try {
      _feedbackStream = FeedbackService.watch();
    } catch (e) {
      _feedbackStream = Stream.error(e);
    }
  }

  /// Tries to load the feedback again after an error.
  void _retry() {
    setState(() {
      _openStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<FeedbackEntry>>(
      stream: _feedbackStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _LoadError(message: l10n.feedbackLoadFailed, onRetry: _retry);
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return FeedbackListView(feedbacks: snapshot.data!);
      },
    );
  }
}

/// Shows the average rating, the star filter and one card per feedback.
/// It only draws the list it is given, so it can be tested without Firebase.
class FeedbackListView extends StatefulWidget {
  final List<FeedbackEntry> feedbacks;

  const FeedbackListView({super.key, required this.feedbacks});

  @override
  State<FeedbackListView> createState() => _FeedbackListViewState();
}

class _FeedbackListViewState extends State<FeedbackListView> {
  RatingFilter _filter = RatingFilter.all;

  /// Chip text of each star filter; 1 and 2 stars are grouped as the lowest.
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
    final List<FeedbackEntry> shown = FeedbackFilter.apply(widget.feedbacks, _filter);

    final List<Widget> filterChips = [];
    for (final RatingFilter filter in RatingFilter.values) {
      final bool isSelected = filter == _filter;
      filterChips.add(ChoiceChip(
        label: Text(_filterLabel(l10n, filter)),
        selected: isSelected,
        showCheckmark: false,
        selectedColor: AppColors.textPrimary,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimary),
        onSelected: (_) {
          setState(() {
            _filter = filter;
          });
        },
      ));
    }

    final List<Widget> feedbackCards = [];
    for (final FeedbackEntry feedback in shown) {
      feedbackCards.add(_FeedbackCard(feedback: feedback, languageCode: languageCode));
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAverageCard(l10n, languageCode),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: filterChips),
            const SizedBox(height: 12),
            // Only say "no feedback with this rating" when there is feedback but the filter hides it.
            if (shown.isEmpty && widget.feedbacks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.feedbackEmptyFilter, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ...feedbackCards,
          ],
        ),
      ),
    );
  }

  /// Average of all ratings with its stars; shows "No feedback yet" when the list is empty.
  Widget _buildAverageCard(AppLocalizations l10n, String languageCode) {
    final double? average = OverviewCalculator.averageRating(widget.feedbacks);

    Widget content;
    if (average == null) {
      content = Text(l10n.feedbackEmpty, style: const TextStyle(color: AppColors.textSecondary));
    } else {
      content = Row(
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
      );
    }

    return Card(
      child: Padding(padding: const EdgeInsets.all(20), child: content),
    );
  }
}

/// One feedback: student name, date, stars and the comment (if any).
class _FeedbackCard extends StatelessWidget {
  final FeedbackEntry feedback;
  final String languageCode;

  const _FeedbackCard({required this.feedback, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int? submittedAt = feedback.submittedAt;

    Widget comment;
    if (feedback.comments.isEmpty) {
      comment = Text(l10n.feedbackNoComment, style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textMuted));
    } else {
      comment = Text(feedback.comments, style: const TextStyle(fontSize: 16));
    }

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
            comment,
          ],
        ),
      ),
    );
  }
}

/// Shown when the feedback cannot be loaded, e.g. no connection or no permission.
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
