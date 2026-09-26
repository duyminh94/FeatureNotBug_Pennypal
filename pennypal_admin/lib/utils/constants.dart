/// Field names used in the Realtime Database.
class DbFields {
  static const String fullName = 'fullName';
  static const String email = 'email';
  static const String mobileNumber = 'mobileNumber';
  static const String studentStatus = 'studentStatus';
  static const String role = 'role';
  static const String isActive = 'isActive';
  static const String currency = 'currency';
  static const String notificationsEnabled = 'notificationsEnabled';
  static const String lastLogin = 'lastLogin';

  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String type = 'type';
  static const String name = 'name';
  static const String status = 'status';
  static const String userId = 'userId';

  static const String amount = 'amount';
  static const String categoryId = 'categoryId';
  static const String description = 'description';
  static const String date = 'date';
  static const String paymentMode = 'paymentMode';
  static const String goalId = 'goalId';
  static const String receiptLocalPath = 'receiptLocalPath';

  static const String titleEn = 'title_en';
  static const String titleVi = 'title_vi';
  static const String bodyEn = 'body_en';
  static const String bodyVi = 'body_vi';
  static const String topic = 'topic';
  static const String level = 'level';
  static const String imageUrl = 'imageUrl';

  static const String userEmail = 'userEmail';
  static const String subject = 'subject';
  static const String message = 'message';
  static const String adminResponse = 'adminResponse';
  static const String submittedAt = 'submittedAt';
  static const String respondedAt = 'respondedAt';
  static const String studentNotified = 'studentNotified';

  static const String rating = 'rating';
  static const String comments = 'comments';

  static const String defaultAlertThreshold = 'defaultAlertThreshold';
  static const String supportEmail = 'supportEmail';
  static const String announcementEn = 'announcement_en';
  static const String announcementVi = 'announcement_vi';
  static const String announcementActive = 'announcementActive';
}

/// Values of the transaction "type" field.
class TransactionTypes {
  static const String income = 'income';
  static const String expense = 'expense';
}

/// Values of the user "role" field; only admin can open this app.
class UserRoles {
  static const String student = 'student';
  static const String admin = 'admin';
}

/// Education levels a student can pick when registering.
class StudentStatuses {
  static const String highSchool = 'high_school';
  static const String undergraduate = 'undergraduate';
  static const String postgraduate = 'postgraduate';
  static const String other = 'other';
}

/// Supported currencies.
class Currencies {
  static const String vnd = 'VND';
}

/// A support request is open until the admin replies.
class SupportStatuses {
  static const String open = 'open';
  static const String resolved = 'resolved';
}

/// Difficulty levels of a lesson.
class LearningLevels {
  static const String beginner = 'beginner';
  static const String intermediate = 'intermediate';

  static const List<String> values = [beginner, intermediate];
}

/// Topics a lesson can belong to.
class LearningTopics {
  static const String budgeting = 'budgeting';
  static const String saving = 'saving';
  static const String income = 'income';
  static const String needsVsWants = 'needs_vs_wants';
  static const String smartSpending = 'smart_spending';

  static const List<String> values = [budgeting, saving, income, needsVsWants, smartSpending];
}

/// Keys of the default categories created for every student.
class CategoryKeys {
  static const String food = 'food';
  static const String transport = 'transport';
  static const String education = 'education';
  static const String shopping = 'shopping';
  static const String entertainment = 'entertainment';
  static const String bills = 'bills';
  static const String savings = 'savings';
  static const String miscellaneous = 'miscellaneous';
  static const String partTime = 'part_time';
  static const String allowance = 'allowance';
}

/// Default values when a setting has not been saved yet.
class AppDefaults {
  /// Budget warning shows when a student has spent this percent of a budget.
  static const int alertThreshold = 80;
  static const String currency = Currencies.vnd;
}

/// Image paths inside assets/.
class AppAssets {
  static const String logo = 'assets/images/logo.png';
}
