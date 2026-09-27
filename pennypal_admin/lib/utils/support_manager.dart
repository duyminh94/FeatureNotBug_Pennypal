import '../models/feedback_entry.dart';
import '../models/support_query.dart';
import 'constants.dart';

enum RatingFilter { all, five, four, three, lowest }

/// Rules for the admin's support inbox.
class SupportManager {
  /// Requests with one status (open or resolved) from every student, newest first.
  /// "Open" means "not resolved", the same rule as the Overview count and the menu badge,
  /// so a request with a missing or unknown status still shows up and can be answered.
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

  /// Uid of the student who sent the request, or null when it is not found.
  /// Needed because a reply is saved under support_queries/{uid}/{queryId}.
  static String? ownerOf(Map<String, List<SupportQuery>> supportByUser, String queryId) {
    for (final String uid in supportByUser.keys) {
      for (final SupportQuery query in supportByUser[uid]!) {
        if (query.id == queryId) return uid;
      }
    }
    return null;
  }

  /// A reply must contain real text, spaces only are not allowed.
  static bool canSendReply(String text) {
    return text.trim().isNotEmpty;
  }

  /// The request after the admin answers: marked resolved with the reply time.
  /// studentNotified is reset so the student sees the answer once in their app.
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

/// Star filter of the Feedbacks screen.
class FeedbackFilter {
  /// True when a feedback belongs to the chosen star group (1 and 2 stars are grouped as lowest).
  static bool matches(FeedbackEntry feedback, RatingFilter filter) {
    return switch (filter) {
      RatingFilter.all => true,
      RatingFilter.five => feedback.rating == 5,
      RatingFilter.four => feedback.rating == 4,
      RatingFilter.three => feedback.rating == 3,
      RatingFilter.lowest => feedback.rating <= 2,
    };
  }

  /// Feedbacks of the chosen star group, newest first.
  static List<FeedbackEntry> apply(List<FeedbackEntry> feedbacks, RatingFilter filter) {
    final List<FeedbackEntry> result = [];
    for (final FeedbackEntry feedback in feedbacks) {
      if (matches(feedback, filter)) result.add(feedback);
    }
    result.sort((a, b) => (b.submittedAt ?? 0).compareTo(a.submittedAt ?? 0));
    return result;
  }
}
