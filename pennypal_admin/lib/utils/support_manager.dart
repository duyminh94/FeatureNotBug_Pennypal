import '../models/feedback_entry.dart';
import '../models/support_query.dart';
import 'constants.dart';

enum RatingFilter { all, five, four, three, lowest }

class SupportManager {
  static List<SupportQuery> withStatus(Map<String, List<SupportQuery>> supportByUser, String status) {
    final bool wantsResolved = status == SupportStatuses.resolved;
    final List<SupportQuery> result = [];
    for (final List<SupportQuery> queries in supportByUser.values) {
      for (final SupportQuery query in queries) {
        if (query.isResolved == wantsResolved) result.add(query);
      }
    }
    result.sort((a, b) => (b.submittedAt ?? 0).compareTo(a.submittedAt ?? 0));
    return result;
  }

  static String? ownerOf(Map<String, List<SupportQuery>> supportByUser, String queryId) {
    for (final String uid in supportByUser.keys) {
      for (final SupportQuery query in supportByUser[uid]!) {
        if (query.id == queryId) return uid;
      }
    }
    return null;
  }

  static bool canSendReply(String text) {
    return text.trim().isNotEmpty;
  }

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
    final List<FeedbackEntry> result = [];
    for (final FeedbackEntry feedback in feedbacks) {
      if (matches(feedback, filter)) result.add(feedback);
    }
    result.sort((a, b) => (b.submittedAt ?? 0).compareTo(a.submittedAt ?? 0));
    return result;
  }
}
