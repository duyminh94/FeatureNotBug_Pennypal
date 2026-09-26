/// Root node names in Firebase Realtime Database.
class DbNodes {
  static const String users = 'users';
  static const String categories = 'categories';
  static const String userCategories = 'user_categories';
  static const String transactions = 'transactions';
  static const String budgets = 'budgets';
  static const String savingsGoals = 'savings_goals';
  static const String notifications = 'notifications';
  static const String learningContents = 'learning_contents';
  static const String supportQueries = 'support_queries';
  static const String feedbacks = 'feedbacks';
  static const String appSettings = 'app_settings';

  /// Key of the overall budget under budgets/{uid}/{month}/.
  static const String budgetTotalKey = 'total';
}

/// Field names used inside the database nodes.
class DbFields {
  // users
  static const String fullName = 'fullName';
  static const String email = 'email';
  static const String mobileNumber = 'mobileNumber';
  static const String studentStatus = 'studentStatus';
  static const String role = 'role';
  static const String isActive = 'isActive';
  static const String currency = 'currency';
  static const String notificationsEnabled = 'notificationsEnabled';
  static const String lastLogin = 'lastLogin';

  // shared
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String type = 'type';
  static const String name = 'name';
  static const String icon = 'icon';
  static const String sortOrder = 'sortOrder';
  static const String status = 'status';
  static const String userId = 'userId';

  // categories
  static const String isSelectable = 'isSelectable';

  // transactions
  static const String amount = 'amount';
  static const String categoryId = 'categoryId';
  static const String description = 'description';
  static const String date = 'date';
  static const String paymentMode = 'paymentMode';
  static const String goalId = 'goalId';
  static const String receiptLocalPath = 'receiptLocalPath';

  // budgets
  static const String limitAmount = 'limitAmount';
  static const String alertThreshold = 'alertThreshold';
  static const String alertLevel = 'alertLevel';

  // savings_goals
  static const String targetAmount = 'targetAmount';
  static const String initialAmount = 'initialAmount';
  static const String currentAmount = 'currentAmount';
  static const String targetDate = 'targetDate';
  static const String monthlyContribution = 'monthlyContribution';
  static const String milestones = 'milestones';
  static const String completedAt = 'completedAt';

  // notifications
  static const String params = 'params';
  static const String isRead = 'isRead';

  // learning_contents
  static const String titleEn = 'title_en';
  static const String titleVi = 'title_vi';
  static const String bodyEn = 'body_en';
  static const String bodyVi = 'body_vi';
  static const String topic = 'topic';
  static const String level = 'level';
  static const String imageUrl = 'imageUrl';

  // support_queries
  static const String userEmail = 'userEmail';
  static const String subject = 'subject';
  static const String message = 'message';
  static const String adminResponse = 'adminResponse';
  static const String submittedAt = 'submittedAt';
  static const String respondedAt = 'respondedAt';
  static const String studentNotified = 'studentNotified';

  // feedbacks
  static const String rating = 'rating';
  static const String comments = 'comments';

  // app_settings
  static const String defaultAlertThreshold = 'defaultAlertThreshold';
  static const String supportEmail = 'supportEmail';
  static const String announcementEn = 'announcement_en';
  static const String announcementVi = 'announcement_vi';
  static const String announcementActive = 'announcementActive';
}

/// Values of transactions.type and categories.type.
class TransactionTypes {
  static const String income = 'income';
  static const String expense = 'expense';
}

/// Values of transactions.paymentMode.
class PaymentModes {
  static const String cash = 'cash';
  static const String bankTransfer = 'bank_transfer';
  static const String eWallet = 'e_wallet';
  static const String other = 'other';

  static const List<String> values = [cash, bankTransfer, eWallet, other];
}

/// Values of users.role.
class UserRoles {
  static const String student = 'student';
  static const String admin = 'admin';
}

/// Values of users.studentStatus.
class StudentStatuses {
  static const String highSchool = 'high_school';
  static const String undergraduate = 'undergraduate';
  static const String postgraduate = 'postgraduate';
  static const String other = 'other';

  static const List<String> values = [
    highSchool,
    undergraduate,
    postgraduate,
    other
  ];
}

/// Values of users.currency.
class Currencies {
  static const String vnd = 'VND';
  static const String usd = 'USD';
}

/// Values of budgets.alertLevel.
class AlertLevels {
  static const String none = 'none';
  static const String warning = 'warning';
  static const String exceeded = 'exceeded';
}

/// Values of savings_goals.status.
class GoalStatuses {
  static const String active = 'active';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

/// Keys of savings_goals.milestones (prefix "m" stops RTDB turning the map into a list).
class MilestoneKeys {
  static const String m25 = 'm25';
  static const String m50 = 'm50';
  static const String m75 = 'm75';
  static const String m100 = 'm100';

  static const List<String> values = [m25, m50, m75, m100];
}

/// Values of support_queries.status.
class SupportStatuses {
  static const String open = 'open';
  static const String resolved = 'resolved';
}

/// Values of learning_contents.level.
class LearningLevels {
  static const String beginner = 'beginner';
  static const String intermediate = 'intermediate';
}

/// Values of learning_contents.topic.
class LearningTopics {
  static const String budgeting = 'budgeting';
  static const String saving = 'saving';
  static const String income = 'income';
  static const String needsVsWants = 'needs_vs_wants';
  static const String smartSpending = 'smart_spending';

  static const List<String> values = [
    budgeting,
    saving,
    income,
    needsVsWants,
    smartSpending
  ];
}

/// Values of notifications.type.
class NotificationTypes {
  static const String budgetWarning = 'budget_warning';
  static const String budgetExceeded = 'budget_exceeded';
  static const String goalMilestone = 'goal_milestone';
  static const String goalCompleted = 'goal_completed';
  static const String supportReplied = 'support_replied';
}

/// Keys of the 13 default categories (8 expense + 5 income).
class CategoryKeys {
  static const String food = 'food';
  static const String transport = 'transport';
  static const String education = 'education';
  static const String shopping = 'shopping';
  static const String entertainment = 'entertainment';
  static const String bills = 'bills';
  static const String savings = 'savings';
  static const String miscellaneous = 'miscellaneous';

  static const String allowance = 'allowance';
  static const String scholarship = 'scholarship';
  static const String partTime = 'part_time';
  static const String internship = 'internship';
  static const String otherIncome = 'other_income';

  /// Expense categories a student can pick by hand (savings is only created by goal contributions).
  static const List<String> selectableExpense = [
    food,
    transport,
    education,
    shopping,
    entertainment,
    bills,
    miscellaneous,
  ];

  static const List<String> income = [partTime, allowance, scholarship, internship, otherIncome];
}

/// The 12 icons a student can pick for a custom category.
class CustomCategoryIcons {
  static const List<String> values = [
    'fitness_center',
    'pets',
    'local_cafe',
    'sports_esports',
    'flight',
    'card_giftcard',
    'health_and_safety',
    'phone_android',
    'home',
    'child_care',
    'volunteer_activism',
    'category',
  ];
}

/// Default values used when a field is missing.
class AppDefaults {
  static const int alertThreshold = 80;
  static const String currency = Currencies.vnd;
  static const int customCategorySortOrder = 100;
  static const double maxAmount = 1000000000;
  static const int descriptionMaxLength = 100;
}

class FormLimits {
  static const int subjectMin = 3;
  static const int subjectMax = 100;
  static const int messageMin = 10;
  static const int messageMax = 1000;
  static const int commentsMax = 500;
}

class AppInfo {
  static const String version = '1.0.0';
  static const String teamName = 'Feature Not Bug';
}

/// Image paths declared under assets/images/ in pubspec.yaml.
class AppAssets {
  static const String logo = 'assets/images/logo.png';
  static const String pig = 'assets/images/pig.png';
}

/// Tab indexes of the bottom navigation bar.
class MainTabs {
  static const int home = 0;
  static const int transactions = 1;
  static const int budget = 2;
  static const int goals = 3;
  static const int more = 4;
}

/// Values a form screen returns with Navigator.pop, so the previous screen knows what happened.
class FormResults {
  static const String saved = 'saved';
  static const String deleted = 'deleted';
}
