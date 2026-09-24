import '../utils/constants.dart';

/// App feedback from a student, stored at feedbacks/{feedbackId}.
class FeedbackEntry {
  final String id;
  final String userId;
  final String name;
  final String email;
  final int rating;
  final String comments;
  final int? submittedAt;

  FeedbackEntry({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.rating,
    this.comments = '',
    this.submittedAt,
  });

  /// Builds a feedback entry from the map read at feedbacks/{feedbackId}.
  factory FeedbackEntry.fromMap(String id, Map<dynamic, dynamic> map) {
    return FeedbackEntry(
      id: id,
      userId: map[DbFields.userId] ?? '',
      name: map[DbFields.name] ?? '',
      email: map[DbFields.email] ?? '',
      rating: map[DbFields.rating] ?? 0,
      comments: map[DbFields.comments] ?? '',
      submittedAt: map[DbFields.submittedAt],
    );
  }

  /// Converts the feedback to a map for writing.
  Map<String, dynamic> toMap() {
    return {
      DbFields.userId: userId,
      DbFields.name: name,
      DbFields.email: email,
      DbFields.rating: rating,
      DbFields.comments: comments,
      DbFields.submittedAt: submittedAt,
    };
  }
}
