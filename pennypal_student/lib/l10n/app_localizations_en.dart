// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PennyPal';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonClearFilter => 'Clear filters';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonNoData => 'No data yet';

  @override
  String get commonDeleteConfirm => 'Are you sure you want to delete this?';

  @override
  String get commonSubmitSuccess => 'Submitted successfully';

  @override
  String get commonNotSynced => 'Not synced yet';

  @override
  String get commonPreviousMonth => 'Previous month';

  @override
  String get commonNextMonth => 'Next month';

  @override
  String get commonOffline =>
      'You are offline. Changes will sync automatically.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Invalid email address';

  @override
  String get validationPassword =>
      'At least 8 characters with letters and numbers';

  @override
  String get validationPasswordMatch => 'Passwords do not match';

  @override
  String get validationMobile => 'Mobile number must be 9–15 digits';

  @override
  String get validationAmountPositive => 'Amount must be greater than 0';

  @override
  String get validationAmountMax => 'Amount is too large';

  @override
  String get validationDateFuture => 'Date cannot be in the future';

  @override
  String get validationDateRange => 'Start date must be before end date';

  @override
  String validationMaxLength(int max) {
    return 'Maximum $max characters';
  }

  @override
  String get validationRating => 'Please choose a rating';

  @override
  String get errorEmailInUse => 'This email is already registered';

  @override
  String get errorInvalidLogin => 'Incorrect email or password';

  @override
  String get errorWeakPassword => 'Password is too weak';

  @override
  String get errorTooManyRequests => 'Too many attempts, try again later';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorPermission => 'You don\'t have permission';

  @override
  String get errorUnknown => 'Something went wrong, please try again';

  @override
  String get errorWrongApp => 'This account cannot use this app';

  @override
  String get errorAccountLocked => 'Your account has been locked';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categorySavings => 'Savings';

  @override
  String get categoryMiscellaneous => 'Miscellaneous';

  @override
  String get categoryAllowance => 'Allowance';

  @override
  String get categoryScholarship => 'Scholarship';

  @override
  String get categoryPartTime => 'Part-time job';

  @override
  String get categoryInternship => 'Internship';

  @override
  String get categoryGift => 'Gift';

  @override
  String get categoryOtherIncome => 'Other';

  @override
  String get commonComingSoon => 'This screen is coming soon';

  @override
  String get commonBack => 'Back';

  @override
  String get splashTagline => 'A cheerful money diary for students';

  @override
  String get splashSubtitle =>
      'Track spending, set budgets and save up — a little every day.';

  @override
  String get splashGetStarted => 'Get started';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authLoginTitle => 'Welcome back!';

  @override
  String get authLoginSubtitle => 'Log in to keep tracking your spending.';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authLoginButton => 'Log in';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authRegisterNow => 'Sign up now';

  @override
  String get authRegisterTitle => 'Create an account';

  @override
  String get authRegisterSubtitle => 'It only takes a minute!';

  @override
  String get authFullName => 'Full name';

  @override
  String get authMobile => 'Mobile number';

  @override
  String get authStudentStatus => 'Student status (optional)';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authRegisterButton => 'Sign up';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get studentStatusHighSchool => 'High school student';

  @override
  String get studentStatusUndergraduate => 'University / college student';

  @override
  String get studentStatusPostgraduate => 'Postgraduate student';

  @override
  String get studentStatusOther => 'Other';

  @override
  String get authForgotSubtitle =>
      'Enter your registered email and Penny will send you a link to reset your password.';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authResetSentTitle => 'Sent!';

  @override
  String authResetSentBody(String email) {
    return 'Check the inbox of $email (including Spam) to reset your password.';
  }

  @override
  String authResendIn(int seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String get authBackToLogin => 'Back to log in';

  @override
  String get notifTitle => 'Let Penny remind you!';

  @override
  String get notifSubtitle =>
      'Turn on notifications so you never miss the important moments:';

  @override
  String get notifBudgetTitle => 'Close to your budget limit';

  @override
  String get notifBudgetBody => 'A reminder when you reach the alert level';

  @override
  String get notifGoalTitle => 'Goal milestones reached';

  @override
  String get notifGoalBody => '25%, 50%, 75% and 100%';

  @override
  String get notifSupportTitle => 'Support has replied';

  @override
  String get notifSupportBody => 'Know as soon as there is an answer';

  @override
  String get notifAllow => 'Allow notifications';

  @override
  String get notifLater => 'Later';

  @override
  String get notifFootnote =>
      'You can still use the app if you decline · change it in Settings';

  @override
  String get commonToday => 'Today';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonClose => 'Close';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navBudget => 'Budget';

  @override
  String get navGoals => 'Goals';

  @override
  String get navMore => 'More';

  @override
  String get dashGreetingMorning => 'Good morning,';

  @override
  String get dashGreetingAfternoon => 'Good afternoon,';

  @override
  String get dashGreetingEvening => 'Good evening,';

  @override
  String get dashNotifications => 'Notifications';

  @override
  String get dashBalance => 'Current balance';

  @override
  String get dashBalanceHint =>
      'Updated from your whole income and expense history';

  @override
  String get dashBalanceEmptyHint => 'Start recording to see your balance';

  @override
  String get dashBalanceNegativeHint => 'Spending is ahead of income.';

  @override
  String get dashMonthIncome => 'Income';

  @override
  String get dashMonthExpense => 'Spending';

  @override
  String get dashMonthSavings => 'Savings';

  @override
  String get dashSavedInGoals => 'Saved';

  @override
  String dashBudgetTitle(String month) {
    return '$month budget';
  }

  @override
  String dashBudgetLeft(String amount) {
    return '$amount left';
  }

  @override
  String dashBudgetOver(String amount) {
    return 'Over by $amount';
  }

  @override
  String dashBudgetUsed(int percent) {
    return '$percent% used';
  }

  @override
  String get dashNoBudgetTitle => 'No budget yet';

  @override
  String get dashNoBudgetBody =>
      'Set a limit to get reminded before you overspend.';

  @override
  String get dashCreateBudget => 'Create budget';

  @override
  String get dashGoalsTitle => 'Goals in progress';

  @override
  String dashGoalDeadline(String date) {
    return 'Deadline $date';
  }

  @override
  String get dashShortcuts => 'Shortcuts';

  @override
  String get dashAddIncome => 'Add income';

  @override
  String get dashAddExpense => 'Add expense';

  @override
  String get dashHistory => 'History';

  @override
  String get dashLearning => 'Learning';

  @override
  String get dashFeedback => 'Feedback';

  @override
  String get dashSupport => 'Support';

  @override
  String get dashRecent => 'Recent transactions';

  @override
  String get dashNoTxTitle => 'No transactions yet';

  @override
  String get dashNoTxBody =>
      'Add your first expense so Penny can show where your money goes.';

  @override
  String get dashAskPenny => 'Ask Penny!';

  @override
  String get txAddExpenseTitle => 'Add expense';

  @override
  String get txAddIncomeTitle => 'Add income';

  @override
  String get txEditExpenseTitle => 'Edit expense';

  @override
  String get txEditIncomeTitle => 'Edit income';

  @override
  String get txAmount => 'Amount';

  @override
  String get txCategory => 'Category';

  @override
  String get txIncomeSource => 'Income source';

  @override
  String get txManage => 'Manage';

  @override
  String get txDate => 'Date';

  @override
  String get txDescription => 'Description';

  @override
  String get txDescriptionHint => 'Add a description';

  @override
  String get txPaymentMode => 'Payment method';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentBankTransfer => 'Bank transfer';

  @override
  String get paymentEWallet => 'E-wallet';

  @override
  String get paymentOther => 'Other';

  @override
  String get txScanReceipt => 'Scan receipt';

  @override
  String get txSaveExpense => 'Save expense';

  @override
  String get txSaveIncome => 'Save income';

  @override
  String get txSaveChanges => 'Save changes';

  @override
  String get txSaved => 'Saved';

  @override
  String get txDeleted => 'Transaction deleted';

  @override
  String get txDeleteTitle => 'Delete this transaction?';

  @override
  String txDeleteBody(String name, String amount) {
    return '“$name” $amount will be deleted. Your balance and budgets will be recalculated.';
  }

  @override
  String get validationCategory => 'Please choose a category';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get commonUndo => 'Undo';

  @override
  String get historySearchHint => 'Search by description, e.g. lunch';

  @override
  String get historyAddTransaction => 'Add transaction';

  @override
  String get filterAllTypes => 'All types';

  @override
  String get filterExpense => 'Expense';

  @override
  String get filterIncome => 'Income';

  @override
  String get filterAllCategories => 'All categories';

  @override
  String get historyEmpty => 'No transactions match your filters';

  @override
  String historyMonthEmpty(String month) {
    return 'No transactions in $month';
  }

  @override
  String historyTxCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get historyAllDays => 'All days';

  @override
  String get historyThisMonth => 'This month';

  @override
  String historyDeletedNamed(String name) {
    return 'Deleted “$name”';
  }

  @override
  String get detailTitle => 'Transaction details';

  @override
  String get detailType => 'Type';

  @override
  String get typeExpense => 'Expense';

  @override
  String get typeIncome => 'Income';

  @override
  String get detailEdit => 'Edit transaction';

  @override
  String get detailContributionLocked =>
      'Goal contribution — edit or delete it in the Goals tab.';

  @override
  String get scanSheetBody =>
      'Penny reads the text right on your phone and never uploads the photo.';

  @override
  String get scanFromCamera => 'Take photo';

  @override
  String get scanFromCameraHint => 'Use the camera to capture a receipt';

  @override
  String get scanFromGallery => 'Choose from gallery';

  @override
  String get scanFromGalleryHint => 'A receipt photo you already have';

  @override
  String get scanReading => 'Reading receipt…';

  @override
  String get scanFilledHint => 'Please check the highlighted fields';

  @override
  String get scanFilledFromReceipt => 'Filled from receipt';

  @override
  String scanSuggested(String name) {
    return 'suggested: $name';
  }

  @override
  String get scanNoText => 'Couldn\'t read this receipt';

  @override
  String get scanNoTextBody =>
      'The photo is still attached. Enter the details yourself, or retake it in better light.';

  @override
  String get scanNoAmount => 'Couldn\'t find the amount';

  @override
  String get scanNoAmountBody =>
      'Other fields are filled in — enter the amount and check again.';

  @override
  String get scanEnterAmount => 'Enter amount';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get scanPermissionDenied =>
      'Camera permission is needed to scan receipts';

  @override
  String get scanPermissionBody =>
      'PennyPal can\'t use the camera. Turn it on in your phone Settings, or choose a photo you already have. You can still fill the form by hand.';

  @override
  String get scanEnterManually => 'Enter manually';

  @override
  String get scanFailed => 'Couldn\'t open the photo. Please try again.';

  @override
  String get receiptPhoto => 'Receipt photo';

  @override
  String get receiptPhotoHint => 'Tap to view · saved on this phone only';

  @override
  String get receiptRemove => 'Remove photo';

  @override
  String get budgetAdd => 'Add budget';

  @override
  String get budgetEditTitle => 'Edit budget';

  @override
  String get budgetTotal => 'Total budget';

  @override
  String budgetOfLimit(String amount) {
    return 'of $amount';
  }

  @override
  String get budgetByCategory => 'By category';

  @override
  String budgetCategoryOverTotal(String amount) {
    return 'Category limits ($amount) are more than the total budget.';
  }

  @override
  String get budgetOverBadge => 'Over budget';

  @override
  String get budgetNearBadge => 'Near limit';

  @override
  String get budgetEmpty =>
      'No budget for this month yet. Set a limit so Penny can remind you before you overspend.';

  @override
  String get budgetCreateFirst => 'Create first budget';

  @override
  String get budgetNoTotal => 'No total budget for this month';

  @override
  String get budgetMonth => 'Month';

  @override
  String get budgetType => 'Budget type';

  @override
  String get budgetTypeTotal => 'Monthly total';

  @override
  String get budgetLimit => 'Limit';

  @override
  String get budgetThreshold => 'Alert threshold';

  @override
  String budgetThresholdHint(String amount) {
    return 'Penny will remind you when you have spent $amount.';
  }

  @override
  String get budgetLocked =>
      'Month and category can\'t be changed. Delete this budget and create a new one instead.';

  @override
  String budgetSpentIn(String month) {
    return 'Spent in $month';
  }

  @override
  String get budgetSave => 'Save budget';

  @override
  String get budgetDuplicate => 'This budget already exists';

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get budgetDeleteTitle => 'Delete this budget?';

  @override
  String budgetDeleteBody(String name, String month) {
    return 'The $name budget for $month will be removed. Your transactions stay the same.';
  }

  @override
  String get goalAdd => 'Create goal';

  @override
  String get goalEditTitle => 'Edit goal';

  @override
  String goalTabActive(int count) {
    return 'Active · $count';
  }

  @override
  String goalTabHistory(int count) {
    return 'History · $count';
  }

  @override
  String goalEstimate(String estimated, String due) {
    return 'Est. $estimated · due $due';
  }

  @override
  String goalEstimateUnknown(String due) {
    return 'Not estimated · due $due';
  }

  @override
  String get goalOnTrack => 'On track';

  @override
  String get goalBehind => 'Behind schedule';

  @override
  String get goalNotEstimated => 'Not estimated';

  @override
  String get goalCreateNew => 'Create new goal';

  @override
  String get goalEmptyActive =>
      'No goals in progress. Set a savings goal and Penny will help you reach it.';

  @override
  String get goalEmptyHistory =>
      'Completed and cancelled goals will appear here.';

  @override
  String get goalCompleted => 'Completed';

  @override
  String get goalCancelled => 'Cancelled';

  @override
  String goalCompletedOn(String amount, String date) {
    return '$amount · done $date';
  }

  @override
  String goalSavedOf(String current, String target) {
    return 'Saved $current of $target';
  }

  @override
  String goalKeptContributions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contributions kept',
      one: '1 contribution kept',
      zero: 'No contributions',
    );
    return '$_temp0';
  }

  @override
  String goalHistoryBanner(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You completed $count goals!',
      one: 'You completed 1 goal!',
    );
    return '$_temp0 Total saved: $amount.';
  }

  @override
  String get goalName => 'Goal name';

  @override
  String get goalNameHint => 'e.g. New laptop';

  @override
  String get goalTargetAmount => 'Target amount';

  @override
  String get goalCurrentSavings => 'Current savings';

  @override
  String get goalCurrentSavingsHelp =>
      'Money you have already saved. It is not a transaction and does not change your balance.';

  @override
  String get goalCurrentSavingsLocked =>
      'Current savings can\'t be changed after you have contributed to this goal.';

  @override
  String get goalTargetDate => 'Target date';

  @override
  String get goalMonthlyContribution => 'Monthly contribution';

  @override
  String get goalMonthlyContributionHelp =>
      'Only used for the estimate. The app never takes money automatically.';

  @override
  String get goalEstimateTitle => 'Penny\'s estimate';

  @override
  String goalRemainingMonths(String amount, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$amount left · $_temp0';
  }

  @override
  String goalFinishAround(String date) {
    return 'Done around $date';
  }

  @override
  String get goalValidationInitial =>
      'Current savings must be less than the target. Set a higher target.';

  @override
  String get goalValidationDate => 'Target date must be after today';

  @override
  String get goalSaved => 'Goal saved';

  @override
  String goalValidationTargetBelowSaved(String amount) {
    return 'Target must be more than the $amount already saved';
  }

  @override
  String get goalSavedLabel => 'saved';

  @override
  String get goalRemainingLabel => 'Still needed';

  @override
  String get goalMonthsLabel => 'Time left';

  @override
  String goalMonthsValue(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
      zero: 'Done',
    );
    return '$_temp0';
  }

  @override
  String get goalEstimatedLabel => 'Estimated finish';

  @override
  String get goalMilestones => 'Milestones';

  @override
  String get goalMark => 'Mark';

  @override
  String goalMilestoneMarked(int percent) {
    return '$percent% milestone marked!';
  }

  @override
  String goalMilestoneLocked(int percent) {
    return '$percent% not reached yet';
  }

  @override
  String get goalContributions => 'Contributions';

  @override
  String get goalNoContributions => 'No contributions yet';

  @override
  String goalCreatedInfo(String initial, String monthly, String due) {
    return 'Current savings when created: $initial · $monthly/month · due $due';
  }

  @override
  String get goalDelete => 'Delete goal';

  @override
  String get goalContribute => 'Contribute';

  @override
  String goalContributeTo(String name) {
    return 'Contribute to “$name”';
  }

  @override
  String get goalEditContribution => 'Edit contribution';

  @override
  String get goalContributionAmount => 'Contribution amount';

  @override
  String get goalContributionInfo =>
      'Contributions reduce your balance but don\'t count toward your spending budget.';

  @override
  String goalContributeButton(String amount) {
    return 'Contribute $amount';
  }

  @override
  String goalContributionTooMuch(String amount) {
    return 'You only need $amount more';
  }

  @override
  String goalContributionOverBalance(String amount) {
    return 'This is more than your balance ($amount). You can still save it if you have cash you haven\'t recorded.';
  }

  @override
  String get goalNote => 'Note';

  @override
  String get goalNoteHint => 'e.g. Saved from part-time pay';

  @override
  String goalContributed(String amount) {
    return 'Added $amount to your goal';
  }

  @override
  String get goalContributionUpdated => 'Contribution updated';

  @override
  String get goalContributionDeleted => 'Contribution deleted';

  @override
  String get goalDeleteContributionTitle => 'Delete this contribution?';

  @override
  String goalDeleteContributionBody(String amount) {
    return '$amount will go back to your balance.';
  }

  @override
  String get goalDeleteTitle => 'Delete this goal?';

  @override
  String goalDeleteBody(String name) {
    return '“$name” will be removed.';
  }

  @override
  String get goalHasContributionsTitle => 'This goal has contributions';

  @override
  String goalHasContributionsBody(String amount, String name) {
    return 'You have put $amount into “$name”. What should happen to this money?';
  }

  @override
  String goalRefund(String amount) {
    return 'Refund $amount to balance';
  }

  @override
  String goalRefundHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Delete the goal and $count contributions. Your balance goes back up.',
      one: 'Delete the goal and 1 contribution. Your balance goes back up.',
    );
    return '$_temp0';
  }

  @override
  String get goalKeepHistory => 'Keep history';

  @override
  String get goalKeepHistoryHint => 'Move it to the History tab as cancelled';

  @override
  String get goalDeleted => 'Goal deleted';

  @override
  String goalRefunded(String amount) {
    return 'Goal deleted. $amount is back in your balance.';
  }

  @override
  String get goalMovedToHistory => 'Goal moved to History';

  @override
  String get goalCompletedTitle => 'Well done!';

  @override
  String goalCompletedBody(String amount, String name) {
    return 'You saved the full $amount for “$name”. Great discipline!';
  }

  @override
  String goalCompletedBadge(String date) {
    return 'Completed · $date';
  }

  @override
  String get goalCreateNext => 'Create next goal';

  @override
  String get goalSeeHistory => 'See goal history';

  @override
  String get goalCancelledInfo =>
      'This goal was cancelled. Its contributions are kept in your history.';

  @override
  String get menuReports => 'Reports';

  @override
  String get menuCategories => 'Categories';

  @override
  String get menuChatbot => 'Penny assistant';

  @override
  String get menuLearning => 'Learning corner';

  @override
  String get menuAbout => 'About PennyPal';

  @override
  String get menuSettings => 'Settings';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutWhatTitle => 'What is PennyPal?';

  @override
  String get aboutWhatBody =>
      'A money diary, reminder and finance tutor for students: record income and expenses, set budgets, save for goals and learn how to manage money.';

  @override
  String get aboutNotBank =>
      'PennyPal is not a bank, wallet, payment or investment service. It does not connect to bank accounts, store cards or make real payments. All tips are for learning only.';

  @override
  String get aboutDataTitle => 'How your data is protected';

  @override
  String get aboutData1 =>
      'Data travels over encrypted TLS connections and is stored encrypted on Firebase.';

  @override
  String get aboutData2 =>
      'Passwords are handled by Firebase Authentication. PennyPal never stores your password.';

  @override
  String get aboutData3 => 'Receipt photos stay on your phone only.';

  @override
  String get aboutData4 =>
      'Admins only see summary numbers, never your individual transactions.';

  @override
  String get aboutContactTitle => 'Contact';

  @override
  String get aboutTeamTitle => 'Development team';

  @override
  String aboutTeamBody(String team) {
    return '$team · TechWiz 7 — Multi-Platform App Computing';
  }

  @override
  String get aboutToolsTitle => 'Libraries & AI tools';

  @override
  String get aboutLibraries =>
      'Libraries: Flutter, Firebase Authentication, Firebase Realtime Database, Google ML Kit Text Recognition, image_picker, fl_chart, string_similarity, shared_preferences, intl.';

  @override
  String get aboutAiTools =>
      'AI tools: Claude (code assistant and UI design reference).';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsCurrencyNote =>
      'Changing the currency only changes how amounts are shown.';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsBody => 'Budget alerts and goal milestones';

  @override
  String get settingsStudentStatus => 'Student status';

  @override
  String get settingsNoStatus => 'Not specified';

  @override
  String get settingsSaved => 'Profile saved';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutTitle => 'Log out of PennyPal?';

  @override
  String get settingsLogoutBody =>
      'You can log in again any time with your email and password.';

  @override
  String validationMinLength(int min) {
    return 'At least $min characters';
  }

  @override
  String get commonBackHome => 'Back to home';

  @override
  String get feedbackQuestion => 'How do you like PennyPal?';

  @override
  String get feedbackRating1 => 'Not good';

  @override
  String get feedbackRating2 => 'Could be better';

  @override
  String get feedbackRating3 => 'It\'s okay';

  @override
  String get feedbackRating4 => 'Really like it!';

  @override
  String get feedbackRating5 => 'Love it!';

  @override
  String feedbackStar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get feedbackComments => 'Comments';

  @override
  String get feedbackCommentsHint =>
      'Tell us what you like or what we can improve';

  @override
  String get feedbackSend => 'Send feedback';

  @override
  String feedbackThanks(String name) {
    return 'Thank you, $name!';
  }

  @override
  String feedbackThanksBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Penny got your $count-star feedback.',
      one: 'Penny got your 1-star feedback.',
    );
    return '$_temp0 The team will read it carefully to make PennyPal better.';
  }

  @override
  String get feedbackSendAnother => 'Send more feedback';

  @override
  String get supportEmailLabel => 'Support email';

  @override
  String get supportMyRequests => 'My requests';

  @override
  String get supportNoRequests =>
      'No requests yet. Ask us anything about using PennyPal.';

  @override
  String get supportNew => 'New request';

  @override
  String get supportReplied => 'Replied';

  @override
  String get supportWaiting => 'Waiting';

  @override
  String supportSentOn(String date) {
    return 'Sent $date';
  }

  @override
  String supportReplyFrom(String date) {
    return 'PennyPal Support · $date';
  }

  @override
  String get supportSubject => 'Subject';

  @override
  String get supportSubjectHint => 'e.g. Can\'t change the currency';

  @override
  String get supportMessage => 'Message';

  @override
  String get supportMessageHint => 'Describe the problem so we can help';

  @override
  String get supportSend => 'Send request';

  @override
  String get supportSentTitle => 'Request sent!';

  @override
  String get supportSentBody =>
      'Penny will let you know as soon as the support team replies.';

  @override
  String supportSentAt(String time) {
    return 'Sent at $time';
  }

  @override
  String get supportSeeRequests => 'See my requests';

  @override
  String get topicBudgeting => 'Budgeting';

  @override
  String get topicSaving => 'Saving';

  @override
  String get topicIncome => 'Income';

  @override
  String get topicNeedsVsWants => 'Needs vs. wants';

  @override
  String get topicSmartSpending => 'Smart spending';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get learningAll => 'All';

  @override
  String get learningEmpty => 'No lessons yet. New tips will appear here soon.';

  @override
  String get learningEmptyTopic => 'No lessons in this topic yet.';

  @override
  String learningMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min read',
      one: '1 min read',
    );
    return '$_temp0';
  }

  @override
  String get learningDisclaimer =>
      'For learning only. This is not professional financial advice.';

  @override
  String get reportsByCategory => 'Spending by category';

  @override
  String get reportsTotalSpending => 'Total spending';

  @override
  String get reportsTrend => 'Income and spending, 6 months';

  @override
  String reportsTrendSummary(String month, String income, String spending) {
    return '$month: income $income · spending $spending';
  }

  @override
  String get reportsTop => 'Top spending';

  @override
  String get reportsNoData => 'Not enough data';

  @override
  String reportsNoDataBody(String month) {
    return '$month has no transactions yet. Add a few expenses so Penny can draw your charts.';
  }

  @override
  String reportsSeeMonth(String month) {
    return 'See the $month report';
  }

  @override
  String get reportsNoSpending =>
      'No spending this month. Savings contributions are not counted as spending.';

  @override
  String get inboxTitleBudgetWarning => 'Close to your limit';

  @override
  String get inboxTitleBudgetExceeded => 'Over budget';

  @override
  String get inboxTitleGoalMilestone => 'New milestone';

  @override
  String get inboxTitleGoalCompleted => 'Goal completed';

  @override
  String get inboxTitleSupportReplied => 'Support replied';

  @override
  String inboxBudgetWarning(int percent, String category) {
    return 'You\'ve used $percent% of your $category budget.';
  }

  @override
  String inboxBudgetExceeded(String category, String amount) {
    return 'You\'re over your $category budget by $amount.';
  }

  @override
  String inboxGoalMilestone(String goal, int percent) {
    return '“$goal” reached $percent%! Keep going.';
  }

  @override
  String inboxGoalCompleted(String goal) {
    return 'You completed “$goal”! 🎉';
  }

  @override
  String inboxSupportReplied(String subject) {
    return 'Support replied to “$subject”.';
  }

  @override
  String get inboxMonthly => 'monthly';

  @override
  String inboxUnread(int count) {
    return '$count unread';
  }

  @override
  String get inboxMarkAllRead => 'Mark all as read';

  @override
  String get inboxEmpty =>
      'No notifications yet. Penny will let you know about budgets, goals and support replies here.';

  @override
  String get inboxJustNow => 'Just now';

  @override
  String inboxMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String inboxHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get categoryExpenseTab => 'Expenses';

  @override
  String get categoryIncomeTab => 'Income';

  @override
  String get categoryMine => 'Mine';

  @override
  String get categoryDefault => 'Default';

  @override
  String get categoryNoCustom =>
      'No categories of your own yet. Tap + to add one.';

  @override
  String get categoryNotUsed => 'Not used';

  @override
  String categoryUsage(int transactions, int budgets) {
    String _temp0 = intl.Intl.pluralLogic(
      transactions,
      locale: localeName,
      other: '$transactions transactions',
      one: '1 transaction',
    );
    String _temp1 = intl.Intl.pluralLogic(
      budgets,
      locale: localeName,
      other: '$budgets budgets',
      one: '1 budget',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get categorySavingsNote =>
      '“Savings” is created automatically when you contribute to a goal.';

  @override
  String get categoryAdd => 'Add category';

  @override
  String get categoryEdit => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameHelp =>
      '2–30 characters, not the same as another category of this type';

  @override
  String get categoryNameLength => 'Name must be 2–30 characters';

  @override
  String get categoryNameExists => 'This name already exists';

  @override
  String get categoryType => 'Type';

  @override
  String get categoryTypeLocked =>
      'This category already has transactions, so its type can\'t change.';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get categorySave => 'Save category';

  @override
  String get categorySaved => 'Category saved';

  @override
  String categoryDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get categoryDeleteBody =>
      'This category is not used yet, so nothing else changes.';

  @override
  String categoryInUse(int transactions, int budgets) {
    String _temp0 = intl.Intl.pluralLogic(
      transactions,
      locale: localeName,
      other: '$transactions transactions',
      one: '1 transaction',
    );
    String _temp1 = intl.Intl.pluralLogic(
      budgets,
      locale: localeName,
      other: '$budgets budgets',
      one: '1 budget',
    );
    return 'This category is used by $_temp0 and $_temp1, so it can\'t be deleted.';
  }

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get chatSubtitle => 'Answers from your own data';

  @override
  String get chatHint => 'Ask Penny about your money…';

  @override
  String get chatSend => 'Send';

  @override
  String get chatDisclaimer =>
      'Educational guidance only, not professional financial advice.';

  @override
  String get chatChipTop => 'What did I spend most on?';

  @override
  String get chatChipBudget => 'How much budget is left?';

  @override
  String get chatChipGoal => 'How is my savings goal?';

  @override
  String get chatChipSave => 'How can I save money?';

  @override
  String chatWelcome(String name) {
    return 'Hi $name! I\'m Penny. Ask me about your spending, budgets or goals.';
  }

  @override
  String get chatHelp =>
      'I can tell you where your money went this month, how much budget is left, how your goals are going and how this month compares to last month. I also share simple budgeting and saving tips.';

  @override
  String chatTopSpending(
      String month, String category, String amount, String percent) {
    return 'In $month you spent the most on $category: $amount, $percent of your spending.';
  }

  @override
  String get chatTopTip =>
      'Tip: a budget for your biggest category is the easiest way to keep it under control.';

  @override
  String chatNoSpending(String month) {
    return 'You have no spending in $month yet. Add an expense and ask me again.';
  }

  @override
  String chatPercentOfLimit(int percent) {
    return '$percent% of limit';
  }

  @override
  String chatMonthSummary(
      String month, String income, String spending, String savings) {
    return 'In $month you earned $income, spent $spending and saved $savings.';
  }

  @override
  String get chatTotalBudgetName => 'total';

  @override
  String chatBudgetLeft(
      String name, String month, String left, String limit, int percent) {
    return 'Your $name budget for $month: $left left of $limit ($percent% used).';
  }

  @override
  String chatBudgetOver(String name, String month, String amount, int percent) {
    return 'Your $name budget for $month is over by $amount ($percent% used).';
  }

  @override
  String chatNoBudget(String name, String month) {
    return 'You don\'t have a $name budget for $month yet. Create one in the Budget tab so I can keep track of it.';
  }

  @override
  String chatGoalProgress(
      String goal, String current, String target, int percent, String pace) {
    return '“$goal”: $current of $target ($percent%). $pace';
  }

  @override
  String chatPaceOnTrack(String date) {
    return 'You\'re on track to finish around $date.';
  }

  @override
  String chatPaceBehind(String date, String due) {
    return 'At this pace you\'ll finish around $date, after your deadline $due.';
  }

  @override
  String get chatPaceUnknown =>
      'Set a monthly contribution so I can estimate when you\'ll finish.';

  @override
  String get chatNoGoal =>
      'You have no active goals. Create one in the Goals tab and start saving!';

  @override
  String chatCompareMore(String current, String last, String percent) {
    return 'So far this month you spent $current. By this day last month you had spent $last: $percent more.';
  }

  @override
  String chatCompareLess(String current, String last, String percent) {
    return 'So far this month you spent $current. By this day last month you had spent $last: $percent less. Nice!';
  }

  @override
  String chatCompareNoLast(String current) {
    return 'There\'s no spending in the same days of last month to compare with. So far this month you spent $current.';
  }

  @override
  String chatCompareSame(String current) {
    return 'So far this month you spent $current, the same as by this day last month.';
  }

  @override
  String get chatBudgetingTips =>
      'Try the 50/30/20 rule: 50% for needs, 30% for wants and 20% for savings. Set a total budget for the month, then add budgets for the categories you spend most on.';

  @override
  String get chatSavingTips =>
      'Save a fixed part, like 10%, on the day you get money, before spending. Give your savings a name by creating a goal, and wait 24 hours before buying things you don\'t need.';

  @override
  String get chatNeedsWants =>
      'Needs are things you must pay for to live and study: meals, rent, transport, textbooks. Wants make life nicer but can wait. Ask yourself: what happens if I don\'t buy this?';

  @override
  String get chatUnknown => 'I didn\'t understand that yet. Try one of these:';

  @override
  String get chatDataLoading =>
      'I\'m still loading your data. Please ask again in a moment.';

  @override
  String get chatDataFailed =>
      'I couldn\'t load your data right now, so I can\'t answer with your numbers. You can still ask me for budgeting or saving tips.';

  @override
  String chatCategorySpending(
      String month, String amount, String category, String percent) {
    return 'In $month you spent $amount on $category, $percent of your spending.';
  }

  @override
  String chatOnlyThisMonth(String month) {
    return 'I can only answer about $month. To see another month, open Reports.';
  }

  @override
  String get reportsTypeSpending => 'Spending';

  @override
  String get reportsTypeIncome => 'Income';

  @override
  String get reportsIncomeByCategory => 'Income by source';

  @override
  String get reportsTotalIncome => 'Total income';

  @override
  String get reportsTopIncome => 'Biggest income sources';

  @override
  String get reportsNoIncome => 'No income this month yet.';

  @override
  String get reportsBalance => 'Balance (income − expenses)';

  @override
  String get reportsBudgetTitle => 'Budget vs actual';

  @override
  String get reportsNoBudget => 'No budget set for this month.';

  @override
  String reportsBudgetUsed(String spent, String limit, int percent) {
    return '$spent of $limit · $percent%';
  }
}
