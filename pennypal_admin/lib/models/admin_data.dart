import 'app_settings.dart';
import 'feedback_entry.dart';
import 'learning_content.dart';
import 'support_query.dart';
import 'transaction_record.dart';
import 'user_profile.dart';

class AdminData {
  final List<UserProfile> users;
  final Map<String, List<TransactionRecord>> transactionsByUser;
  final Map<String, List<SupportQuery>> supportByUser;
  final Map<String, int> goalCountByUser;
  final List<FeedbackEntry> feedbacks;
  final List<LearningContent> lessons;
  AppSettings settings;

  AdminData({
    required this.users,
    required this.transactionsByUser,
    required this.supportByUser,
    this.goalCountByUser = const {},
    required this.feedbacks,
    required this.lessons,
    required this.settings,
  });
}
