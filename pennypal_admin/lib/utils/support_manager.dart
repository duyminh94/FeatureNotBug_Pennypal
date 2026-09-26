import '../models/feedback_entry.dart';
import '../models/support_query.dart';
import 'constants.dart';

enum RatingFilter { all, five, four, three, lowest }

class SupportManager {
  static List<SupportQuery> withStatus(Map<String, List<SupportQuery>> supportByUser, String status) {
    final List<SupportQuery> result = [
      for (final List<SupportQuery> queries in supportByUser.values) ...queries.where((query) => query.status == status),
    ];
    result.sort((a, b) => (b.submittedAt ?? 0).compareTo(a.submittedAt ?? 0));
    return result;
  }

  static bool canSendReply(String text) => text.trim().isNotEmpty;

  static SupportQuery reply(SupportQuery query, String text, int now) {
    return SupportQuery(
      id: query.id,
      userEmail: query.userEmail,
      subject: query.subject,
      message: query.message,
      status: SupportStatuses.resolved,
      adminResponse: text.trim(),
      submittedAt: query.submittedAt,
      respondedAt: now,
      studentNotified: false,
    );
  }

  static void replace(Map<String, List<SupportQuery>> supportByUser, SupportQuery updated) {
    for (final List<SupportQuery> queries in supportByUser.values) {
      final int index = queries.indexWhere((query) => query.id == updated.id);
      if (index >= 0) {
        queries[index] = updated;
        return;
      }
    }
  }
}

class FeedbackFilter {
  static bool matches(FeedbackEntry feedback, RatingFilter filter) {
    return switch (filter) {
      RatingFilter.all => true,
      RatingFilter.five => feedback.rating == 5,
      RatingFilter.four => feedback.rating == 4,
      RatingFilter.three => feedback.rating == 3,
      RatingFilter.lowest => feedback.rating <= 2,
    };
  }

  static List<FeedbackEntry> apply(List<FeedbackEntry> feedbacks, RatingFilter filter) {
    final List<FeedbackEntry> result = feedbacks.where((feedback) => matches(feedback, filter)).toList();
    result.sort((a, b) => (b.submittedAt ?? 0).compareTo(a.submittedAt ?? 0));
    return result;
  }
}
