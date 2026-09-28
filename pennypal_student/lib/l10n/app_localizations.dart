import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PennyPal'**
  String get appTitle;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get commonFilter;

  /// No description provided for @commonClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get commonClearFilter;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get commonNoData;

  /// No description provided for @commonDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get commonDeleteConfirm;

  /// No description provided for @commonSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Submitted successfully'**
  String get commonSubmitSuccess;

  /// No description provided for @commonNotSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get commonNotSynced;

  /// No description provided for @commonPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get commonPreviousMonth;

  /// No description provided for @commonNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get commonNextMonth;

  /// No description provided for @commonOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Changes will sync automatically.'**
  String get commonOffline;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get validationEmail;

  /// No description provided for @validationPassword.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters with letters and numbers'**
  String get validationPassword;

  /// No description provided for @validationPasswordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMatch;

  /// No description provided for @validationMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be 9-15 digits'**
  String get validationMobile;

  /// No description provided for @validationAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get validationAmountPositive;

  /// No description provided for @validationAmountMax.
  ///
  /// In en, this message translates to:
  /// **'Amount is too large'**
  String get validationAmountMax;

  /// No description provided for @validationDateFuture.
  ///
  /// In en, this message translates to:
  /// **'Date cannot be in the future'**
  String get validationDateFuture;

  /// No description provided for @validationDateRange.
  ///
  /// In en, this message translates to:
  /// **'Start date must be before end date'**
  String get validationDateRange;

  /// No description provided for @validationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Maximum {max} characters'**
  String validationMaxLength(int max);

  /// No description provided for @validationRating.
  ///
  /// In en, this message translates to:
  /// **'Please choose a rating'**
  String get validationRating;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get errorEmailInUse;

  /// No description provided for @errorInvalidLogin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get errorInvalidLogin;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get errorWeakPassword;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts, try again later'**
  String get errorTooManyRequests;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNetwork;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission'**
  String get errorPermission;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again'**
  String get errorUnknown;

  /// No description provided for @errorWrongApp.
  ///
  /// In en, this message translates to:
  /// **'This account cannot use this app'**
  String get errorWrongApp;

  /// No description provided for @errorAccountLocked.
  ///
  /// In en, this message translates to:
  /// **'Your account has been locked'**
  String get errorAccountLocked;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryBills;

  /// No description provided for @categorySavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get categorySavings;

  /// No description provided for @categoryMiscellaneous.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get categoryMiscellaneous;

  /// No description provided for @categoryAllowance.
  ///
  /// In en, this message translates to:
  /// **'Allowance'**
  String get categoryAllowance;

  /// No description provided for @categoryScholarship.
  ///
  /// In en, this message translates to:
  /// **'Scholarship'**
  String get categoryScholarship;

  /// No description provided for @categoryPartTime.
  ///
  /// In en, this message translates to:
  /// **'Part-time job'**
  String get categoryPartTime;

  /// No description provided for @categoryInternship.
  ///
  /// In en, this message translates to:
  /// **'Internship'**
  String get categoryInternship;

  /// No description provided for @categoryGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get categoryGift;

  /// No description provided for @categoryOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOtherIncome;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This screen is coming soon'**
  String get commonComingSoon;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'A cheerful money diary for students'**
  String get splashTagline;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track spending, set budgets and save up, a little every day.'**
  String get splashSubtitle;

  /// No description provided for @splashGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get splashGetStarted;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to keep tracking your spending.'**
  String get authLoginSubtitle;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginButton;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authRegisterNow.
  ///
  /// In en, this message translates to:
  /// **'Sign up now'**
  String get authRegisterNow;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It only takes a minute!'**
  String get authRegisterSubtitle;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullName;

  /// No description provided for @authMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get authMobile;

  /// No description provided for @authStudentStatus.
  ///
  /// In en, this message translates to:
  /// **'Student status (optional)'**
  String get authStudentStatus;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authRegisterButton;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @studentStatusHighSchool.
  ///
  /// In en, this message translates to:
  /// **'High school student'**
  String get studentStatusHighSchool;

  /// No description provided for @studentStatusUndergraduate.
  ///
  /// In en, this message translates to:
  /// **'University / college student'**
  String get studentStatusUndergraduate;

  /// No description provided for @studentStatusPostgraduate.
  ///
  /// In en, this message translates to:
  /// **'Postgraduate student'**
  String get studentStatusPostgraduate;

  /// No description provided for @studentStatusOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get studentStatusOther;

  /// No description provided for @authForgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email and Penny will send you a link to reset your password.'**
  String get authForgotSubtitle;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authResetSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent!'**
  String get authResetSentTitle;

  /// No description provided for @authResetSentBody.
  ///
  /// In en, this message translates to:
  /// **'Check the inbox of {email} (including Spam) to reset your password.'**
  String authResetSentBody(String email);

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} seconds'**
  String authResendIn(int seconds);

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to log in'**
  String get authBackToLogin;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Let Penny remind you!'**
  String get notifTitle;

  /// No description provided for @notifSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications so you never miss the important moments:'**
  String get notifSubtitle;

  /// No description provided for @notifBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Close to your budget limit'**
  String get notifBudgetTitle;

  /// No description provided for @notifBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'A reminder when you reach the alert level'**
  String get notifBudgetBody;

  /// No description provided for @notifGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal milestones reached'**
  String get notifGoalTitle;

  /// No description provided for @notifGoalBody.
  ///
  /// In en, this message translates to:
  /// **'25%, 50%, 75% and 100%'**
  String get notifGoalBody;

  /// No description provided for @notifSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support has replied'**
  String get notifSupportTitle;

  /// No description provided for @notifSupportBody.
  ///
  /// In en, this message translates to:
  /// **'Know as soon as there is an answer'**
  String get notifSupportBody;

  /// No description provided for @notifAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get notifAllow;

  /// No description provided for @notifLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get notifLater;

  /// No description provided for @notifFootnote.
  ///
  /// In en, this message translates to:
  /// **'You can still use the app if you decline · change it in Settings'**
  String get notifFootnote;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @navBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get navBudget;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @dashGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get dashGreetingMorning;

  /// No description provided for @dashGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get dashGreetingAfternoon;

  /// No description provided for @dashGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get dashGreetingEvening;

  /// No description provided for @dashNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get dashNotifications;

  /// No description provided for @dashBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get dashBalance;

  /// No description provided for @dashBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'Updated from your whole income and expense history'**
  String get dashBalanceHint;

  /// No description provided for @dashBalanceEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Start recording to see your balance'**
  String get dashBalanceEmptyHint;

  /// No description provided for @dashBalanceNegativeHint.
  ///
  /// In en, this message translates to:
  /// **'Spending is ahead of income.'**
  String get dashBalanceNegativeHint;

  /// No description provided for @dashMonthIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get dashMonthIncome;

  /// No description provided for @dashMonthExpense.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get dashMonthExpense;

  /// No description provided for @dashMonthSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get dashMonthSavings;

  /// No description provided for @dashSavedInGoals.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get dashSavedInGoals;

  /// No description provided for @dashBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'{month} budget'**
  String dashBudgetTitle(String month);

  /// No description provided for @dashBudgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String dashBudgetLeft(String amount);

  /// No description provided for @dashBudgetOver.
  ///
  /// In en, this message translates to:
  /// **'Over by {amount}'**
  String dashBudgetOver(String amount);

  /// No description provided for @dashBudgetUsed.
  ///
  /// In en, this message translates to:
  /// **'{percent}% used'**
  String dashBudgetUsed(int percent);

  /// No description provided for @dashNoBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'No budget yet'**
  String get dashNoBudgetTitle;

  /// No description provided for @dashNoBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Set a limit to get reminded before you overspend.'**
  String get dashNoBudgetBody;

  /// No description provided for @dashCreateBudget.
  ///
  /// In en, this message translates to:
  /// **'Create budget'**
  String get dashCreateBudget;

  /// No description provided for @dashGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals in progress'**
  String get dashGoalsTitle;

  /// No description provided for @dashGoalDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline {date}'**
  String dashGoalDeadline(String date);

  /// No description provided for @dashShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get dashShortcuts;

  /// No description provided for @dashAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get dashAddIncome;

  /// No description provided for @dashAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get dashAddExpense;

  /// No description provided for @dashHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get dashHistory;

  /// No description provided for @dashLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get dashLearning;

  /// No description provided for @dashFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get dashFeedback;

  /// No description provided for @dashSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get dashSupport;

  /// No description provided for @dashRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get dashRecent;

  /// No description provided for @dashNoTxTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get dashNoTxTitle;

  /// No description provided for @dashNoTxBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense so Penny can show where your money goes.'**
  String get dashNoTxBody;

  /// No description provided for @dashAskPenny.
  ///
  /// In en, this message translates to:
  /// **'Ask Penny!'**
  String get dashAskPenny;

  /// No description provided for @txAddExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get txAddExpenseTitle;

  /// No description provided for @txAddIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get txAddIncomeTitle;

  /// No description provided for @txEditExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get txEditExpenseTitle;

  /// No description provided for @txEditIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit income'**
  String get txEditIncomeTitle;

  /// No description provided for @txAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get txAmount;

  /// No description provided for @txCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get txCategory;

  /// No description provided for @txIncomeSource.
  ///
  /// In en, this message translates to:
  /// **'Income source'**
  String get txIncomeSource;

  /// No description provided for @txManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get txManage;

  /// No description provided for @txDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get txDate;

  /// No description provided for @txDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get txDescription;

  /// No description provided for @txDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a description'**
  String get txDescriptionHint;

  /// No description provided for @txPaymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get txPaymentMode;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentBankTransfer;

  /// No description provided for @paymentEWallet.
  ///
  /// In en, this message translates to:
  /// **'E-wallet'**
  String get paymentEWallet;

  /// No description provided for @paymentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get paymentOther;

  /// No description provided for @txScanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get txScanReceipt;

  /// No description provided for @txSaveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get txSaveExpense;

  /// No description provided for @txSaveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save income'**
  String get txSaveIncome;

  /// No description provided for @txSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get txSaveChanges;

  /// No description provided for @txSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get txSaved;

  /// No description provided for @recurringSwitch.
  ///
  /// In en, this message translates to:
  /// **'Repeat every month'**
  String get recurringSwitch;

  /// No description provided for @recurringSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Added automatically on day {day} of each month.'**
  String recurringSwitchHint(int day);

  /// No description provided for @recurringMonthEndNote.
  ///
  /// In en, this message translates to:
  /// **'Shorter months use their last day.'**
  String get recurringMonthEndNote;

  /// No description provided for @menuRecurring.
  ///
  /// In en, this message translates to:
  /// **'Fixed items'**
  String get menuRecurring;

  /// No description provided for @recurringEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fixed items yet. Turn on \"Repeat every month\" when you add an income or expense.'**
  String get recurringEmpty;

  /// No description provided for @recurringNote.
  ///
  /// In en, this message translates to:
  /// **'These are added automatically when you open the app on or after their day.'**
  String get recurringNote;

  /// No description provided for @recurringDay.
  ///
  /// In en, this message translates to:
  /// **'day {day} every month'**
  String recurringDay(int day);

  /// No description provided for @recurringStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get recurringStopped;

  /// No description provided for @recurringEditAmount.
  ///
  /// In en, this message translates to:
  /// **'Change amount'**
  String get recurringEditAmount;

  /// No description provided for @recurringAmountSaved.
  ///
  /// In en, this message translates to:
  /// **'Amount changed. It applies from the next time it is added.'**
  String get recurringAmountSaved;

  /// No description provided for @recurringStoppedMessage.
  ///
  /// In en, this message translates to:
  /// **'Stopped. Transactions already added are kept.'**
  String get recurringStoppedMessage;

  /// No description provided for @recurringResumedMessage.
  ///
  /// In en, this message translates to:
  /// **'Turned back on. Months while it was stopped are not added.'**
  String get recurringResumedMessage;

  /// No description provided for @recurringDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this fixed item?'**
  String get recurringDeleteTitle;

  /// No description provided for @recurringDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It will not be added any more. Transactions already added are kept.'**
  String get recurringDeleteBody;

  /// No description provided for @recurringDeleted.
  ///
  /// In en, this message translates to:
  /// **'Fixed item deleted'**
  String get recurringDeleted;

  /// No description provided for @txDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get txDeleted;

  /// No description provided for @txDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction?'**
  String get txDeleteTitle;

  /// No description provided for @txDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" {amount} will be deleted. Your balance and budgets will be recalculated.'**
  String txDeleteBody(String name, String amount);

  /// No description provided for @validationCategory.
  ///
  /// In en, this message translates to:
  /// **'Please choose a category'**
  String get validationCategory;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by description, e.g. lunch'**
  String get historySearchHint;

  /// No description provided for @historyAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get historyAddTransaction;

  /// No description provided for @filterAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAllTypes;

  /// No description provided for @filterExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get filterExpense;

  /// No description provided for @filterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// No description provided for @filterAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get filterAllCategories;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions match your filters'**
  String get historyEmpty;

  /// No description provided for @historyShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more ({count} left)'**
  String historyShowMore(int count);

  /// No description provided for @historyMonthEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions in {month}'**
  String historyMonthEmpty(String month);

  /// No description provided for @historyTxCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String historyTxCount(int count);

  /// No description provided for @historyAllDays.
  ///
  /// In en, this message translates to:
  /// **'All days'**
  String get historyAllDays;

  /// No description provided for @historyThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get historyThisMonth;

  /// No description provided for @historyDeletedNamed.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\"'**
  String historyDeletedNamed(String name);

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get detailTitle;

  /// No description provided for @detailType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get detailType;

  /// No description provided for @typeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get typeExpense;

  /// No description provided for @typeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get typeIncome;

  /// No description provided for @detailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get detailEdit;

  /// No description provided for @detailContributionLocked.
  ///
  /// In en, this message translates to:
  /// **'Goal contribution. Edit or delete it in the Goals tab.'**
  String get detailContributionLocked;

  /// No description provided for @scanSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Penny reads the text right on your phone and never uploads the photo.'**
  String get scanSheetBody;

  /// No description provided for @scanFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get scanFromCamera;

  /// No description provided for @scanFromCameraHint.
  ///
  /// In en, this message translates to:
  /// **'Use the camera to capture a receipt'**
  String get scanFromCameraHint;

  /// No description provided for @scanFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get scanFromGallery;

  /// No description provided for @scanFromGalleryHint.
  ///
  /// In en, this message translates to:
  /// **'A receipt photo you already have'**
  String get scanFromGalleryHint;

  /// No description provided for @scanReading.
  ///
  /// In en, this message translates to:
  /// **'Reading receipt...'**
  String get scanReading;

  /// No description provided for @scanFilledHint.
  ///
  /// In en, this message translates to:
  /// **'Please check the highlighted fields'**
  String get scanFilledHint;

  /// No description provided for @scanFilledFromReceipt.
  ///
  /// In en, this message translates to:
  /// **'Filled from receipt'**
  String get scanFilledFromReceipt;

  /// No description provided for @scanSuggested.
  ///
  /// In en, this message translates to:
  /// **'suggested: {name}'**
  String scanSuggested(String name);

  /// No description provided for @scanNoText.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read this receipt'**
  String get scanNoText;

  /// No description provided for @scanNoTextBody.
  ///
  /// In en, this message translates to:
  /// **'The photo is still attached. Enter the details yourself, or retake it in better light.'**
  String get scanNoTextBody;

  /// No description provided for @scanNoAmount.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find the amount'**
  String get scanNoAmount;

  /// No description provided for @scanNoAmountBody.
  ///
  /// In en, this message translates to:
  /// **'Other fields are filled in. Enter the amount and check again.'**
  String get scanNoAmountBody;

  /// No description provided for @scanEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get scanEnterAmount;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get scanAgain;

  /// No description provided for @scanPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is needed to scan receipts'**
  String get scanPermissionDenied;

  /// No description provided for @scanPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'PennyPal can\'t use the camera. Turn it on in your phone Settings, or choose a photo you already have. You can still fill the form by hand.'**
  String get scanPermissionBody;

  /// No description provided for @scanEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get scanEnterManually;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the photo. Please try again.'**
  String get scanFailed;

  /// No description provided for @receiptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo'**
  String get receiptPhoto;

  /// No description provided for @receiptPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to view · saved on this phone only'**
  String get receiptPhotoHint;

  /// No description provided for @receiptRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get receiptRemove;

  /// No description provided for @budgetAdd.
  ///
  /// In en, this message translates to:
  /// **'Add budget'**
  String get budgetAdd;

  /// No description provided for @budgetEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get budgetEditTitle;

  /// No description provided for @budgetTotal.
  ///
  /// In en, this message translates to:
  /// **'Total budget'**
  String get budgetTotal;

  /// No description provided for @budgetOfLimit.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String budgetOfLimit(String amount);

  /// No description provided for @budgetByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get budgetByCategory;

  /// No description provided for @budgetCategoryOverTotal.
  ///
  /// In en, this message translates to:
  /// **'Category limits ({amount}) are more than the total budget.'**
  String budgetCategoryOverTotal(String amount);

  /// No description provided for @budgetOverBadge.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get budgetOverBadge;

  /// No description provided for @budgetNearBadge.
  ///
  /// In en, this message translates to:
  /// **'Near limit'**
  String get budgetNearBadge;

  /// No description provided for @budgetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No budget for this month yet. Set a limit so Penny can remind you before you overspend.'**
  String get budgetEmpty;

  /// No description provided for @budgetCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create first budget'**
  String get budgetCreateFirst;

  /// No description provided for @budgetNoTotal.
  ///
  /// In en, this message translates to:
  /// **'No total budget for this month'**
  String get budgetNoTotal;

  /// No description provided for @budgetMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get budgetMonth;

  /// No description provided for @budgetType.
  ///
  /// In en, this message translates to:
  /// **'Budget type'**
  String get budgetType;

  /// No description provided for @budgetTypeTotal.
  ///
  /// In en, this message translates to:
  /// **'Monthly total'**
  String get budgetTypeTotal;

  /// No description provided for @budgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get budgetLimit;

  /// No description provided for @budgetThreshold.
  ///
  /// In en, this message translates to:
  /// **'Alert threshold'**
  String get budgetThreshold;

  /// No description provided for @budgetThresholdHint.
  ///
  /// In en, this message translates to:
  /// **'Penny will remind you when you have spent {amount}.'**
  String budgetThresholdHint(String amount);

  /// No description provided for @budgetLocked.
  ///
  /// In en, this message translates to:
  /// **'Month and category can\'t be changed. Delete this budget and create a new one instead.'**
  String get budgetLocked;

  /// No description provided for @budgetSpentIn.
  ///
  /// In en, this message translates to:
  /// **'Spent in {month}'**
  String budgetSpentIn(String month);

  /// No description provided for @budgetSave.
  ///
  /// In en, this message translates to:
  /// **'Save budget'**
  String get budgetSave;

  /// No description provided for @budgetDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This budget already exists'**
  String get budgetDuplicate;

  /// No description provided for @budgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget saved'**
  String get budgetSaved;

  /// No description provided for @budgetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeleted;

  /// No description provided for @budgetDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this budget?'**
  String get budgetDeleteTitle;

  /// No description provided for @budgetDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The {name} budget for {month} will be removed. Your transactions stay the same.'**
  String budgetDeleteBody(String name, String month);

  /// No description provided for @goalAdd.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get goalAdd;

  /// No description provided for @goalEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get goalEditTitle;

  /// No description provided for @goalTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active · {count}'**
  String goalTabActive(int count);

  /// No description provided for @goalTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History · {count}'**
  String goalTabHistory(int count);

  /// No description provided for @goalEstimate.
  ///
  /// In en, this message translates to:
  /// **'Est. {estimated} · due {due}'**
  String goalEstimate(String estimated, String due);

  /// No description provided for @goalEstimateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not estimated · due {due}'**
  String goalEstimateUnknown(String due);

  /// No description provided for @goalOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get goalOnTrack;

  /// No description provided for @goalBehind.
  ///
  /// In en, this message translates to:
  /// **'Behind schedule'**
  String get goalBehind;

  /// No description provided for @goalNotEstimated.
  ///
  /// In en, this message translates to:
  /// **'Not estimated'**
  String get goalNotEstimated;

  /// No description provided for @goalCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new goal'**
  String get goalCreateNew;

  /// No description provided for @goalEmptyActive.
  ///
  /// In en, this message translates to:
  /// **'No goals in progress. Set a savings goal and Penny will help you reach it.'**
  String get goalEmptyActive;

  /// No description provided for @goalEmptyHistory.
  ///
  /// In en, this message translates to:
  /// **'Completed and cancelled goals will appear here.'**
  String get goalEmptyHistory;

  /// No description provided for @goalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get goalCompleted;

  /// No description provided for @goalCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get goalCancelled;

  /// No description provided for @goalCompletedOn.
  ///
  /// In en, this message translates to:
  /// **'{amount} · done {date}'**
  String goalCompletedOn(String amount, String date);

  /// No description provided for @goalSavedOf.
  ///
  /// In en, this message translates to:
  /// **'Saved {current} of {target}'**
  String goalSavedOf(String current, String target);

  /// No description provided for @goalKeptContributions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No contributions} =1{1 contribution kept} other{{count} contributions kept}}'**
  String goalKeptContributions(int count);

  /// No description provided for @goalHistoryBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You completed 1 goal!} other{You completed {count} goals!}} Total saved: {amount}.'**
  String goalHistoryBanner(int count, String amount);

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @goalNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. New laptop'**
  String get goalNameHint;

  /// No description provided for @goalTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalTargetAmount;

  /// No description provided for @goalCurrentSavings.
  ///
  /// In en, this message translates to:
  /// **'Current savings'**
  String get goalCurrentSavings;

  /// No description provided for @goalCurrentSavingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Money you saved before using the app. It is not a transaction and does not change your balance.'**
  String get goalCurrentSavingsHelp;

  /// No description provided for @goalCurrentSavingsLocked.
  ///
  /// In en, this message translates to:
  /// **'Current savings can\'t be changed after you have contributed to this goal.'**
  String get goalCurrentSavingsLocked;

  /// No description provided for @goalTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Target date'**
  String get goalTargetDate;

  /// No description provided for @goalMonthlyContribution.
  ///
  /// In en, this message translates to:
  /// **'Monthly contribution'**
  String get goalMonthlyContribution;

  /// No description provided for @goalMonthlyContributionHelp.
  ///
  /// In en, this message translates to:
  /// **'Used for the estimate. You can also have it contributed automatically.'**
  String get goalMonthlyContributionHelp;

  /// No description provided for @goalAutoContribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute automatically'**
  String get goalAutoContribute;

  /// No description provided for @goalAutoContributeNewHint.
  ///
  /// In en, this message translates to:
  /// **'{amount} goes into this goal on day {day} of each month, starting next month.'**
  String goalAutoContributeNewHint(String amount, int day);

  /// No description provided for @goalAutoContributeHint.
  ///
  /// In en, this message translates to:
  /// **'{amount} goes into this goal on day {day} of each month.'**
  String goalAutoContributeHint(String amount, int day);

  /// No description provided for @recurringGoalName.
  ///
  /// In en, this message translates to:
  /// **'Save for {name}'**
  String recurringGoalName(String name);

  /// No description provided for @goalEstimateTitle.
  ///
  /// In en, this message translates to:
  /// **'Penny\'s estimate'**
  String get goalEstimateTitle;

  /// No description provided for @goalRemainingMonths.
  ///
  /// In en, this message translates to:
  /// **'{amount} left · {months, plural, =1{1 month} other{{months} months}}'**
  String goalRemainingMonths(String amount, int months);

  /// No description provided for @goalFinishAround.
  ///
  /// In en, this message translates to:
  /// **'Done around {date}'**
  String goalFinishAround(String date);

  /// No description provided for @goalValidationInitial.
  ///
  /// In en, this message translates to:
  /// **'Current savings must be less than the target. Set a higher target.'**
  String get goalValidationInitial;

  /// No description provided for @goalValidationDate.
  ///
  /// In en, this message translates to:
  /// **'Target date must be after today'**
  String get goalValidationDate;

  /// No description provided for @goalSaved.
  ///
  /// In en, this message translates to:
  /// **'Goal saved'**
  String get goalSaved;

  /// No description provided for @goalValidationTargetBelowSaved.
  ///
  /// In en, this message translates to:
  /// **'Target must be more than the {amount} already saved'**
  String goalValidationTargetBelowSaved(String amount);

  /// No description provided for @goalSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get goalSavedLabel;

  /// No description provided for @goalRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Still needed'**
  String get goalRemainingLabel;

  /// No description provided for @goalMonthsLabel.
  ///
  /// In en, this message translates to:
  /// **'Time left'**
  String get goalMonthsLabel;

  /// No description provided for @goalMonthsValue.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =0{Done} =1{1 month} other{{months} months}}'**
  String goalMonthsValue(int months);

  /// No description provided for @goalEstimatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated finish'**
  String get goalEstimatedLabel;

  /// No description provided for @goalMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get goalMilestones;

  /// No description provided for @goalMark.
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get goalMark;

  /// No description provided for @goalMilestoneMarked.
  ///
  /// In en, this message translates to:
  /// **'{percent}% milestone marked!'**
  String goalMilestoneMarked(int percent);

  /// No description provided for @goalMilestoneLocked.
  ///
  /// In en, this message translates to:
  /// **'{percent}% not reached yet'**
  String goalMilestoneLocked(int percent);

  /// No description provided for @goalContributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get goalContributions;

  /// No description provided for @goalNoContributions.
  ///
  /// In en, this message translates to:
  /// **'No contributions yet'**
  String get goalNoContributions;

  /// No description provided for @goalCreatedInfo.
  ///
  /// In en, this message translates to:
  /// **'Current savings when created: {initial} · {monthly}/month · due {due}'**
  String goalCreatedInfo(String initial, String monthly, String due);

  /// No description provided for @goalDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get goalDelete;

  /// No description provided for @goalContribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get goalContribute;

  /// No description provided for @goalContributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contribution'**
  String get goalContributionTitle;

  /// No description provided for @goalContributeTo.
  ///
  /// In en, this message translates to:
  /// **'Contribute to \"{name}\"'**
  String goalContributeTo(String name);

  /// No description provided for @goalEditContribution.
  ///
  /// In en, this message translates to:
  /// **'Edit contribution'**
  String get goalEditContribution;

  /// No description provided for @goalContributionAmount.
  ///
  /// In en, this message translates to:
  /// **'Contribution amount'**
  String get goalContributionAmount;

  /// No description provided for @goalContributionInfo.
  ///
  /// In en, this message translates to:
  /// **'Contributions reduce your balance but don\'t count toward your spending budget.'**
  String get goalContributionInfo;

  /// No description provided for @goalContributeButton.
  ///
  /// In en, this message translates to:
  /// **'Contribute {amount}'**
  String goalContributeButton(String amount);

  /// No description provided for @goalContributionTooMuch.
  ///
  /// In en, this message translates to:
  /// **'You only need {amount} more'**
  String goalContributionTooMuch(String amount);

  /// No description provided for @goalContributionOverBalance.
  ///
  /// In en, this message translates to:
  /// **'This is more than your balance ({amount}). You can still save it if you have cash you haven\'t recorded.'**
  String goalContributionOverBalance(String amount);

  /// No description provided for @goalNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get goalNote;

  /// No description provided for @goalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Saved from part-time pay'**
  String get goalNoteHint;

  /// No description provided for @goalContributed.
  ///
  /// In en, this message translates to:
  /// **'Added {amount} to your goal'**
  String goalContributed(String amount);

  /// No description provided for @goalContributionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Contribution updated'**
  String get goalContributionUpdated;

  /// No description provided for @goalContributionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Contribution deleted'**
  String get goalContributionDeleted;

  /// No description provided for @goalDeleteContributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this contribution?'**
  String get goalDeleteContributionTitle;

  /// No description provided for @goalDeleteContributionBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} will go back to your balance.'**
  String goalDeleteContributionBody(String amount);

  /// No description provided for @goalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this goal?'**
  String get goalDeleteTitle;

  /// No description provided for @goalDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed.'**
  String goalDeleteBody(String name);

  /// No description provided for @goalHasContributionsTitle.
  ///
  /// In en, this message translates to:
  /// **'This goal has contributions'**
  String get goalHasContributionsTitle;

  /// No description provided for @goalHasContributionsBody.
  ///
  /// In en, this message translates to:
  /// **'You have put {amount} into \"{name}\". What should happen to this money?'**
  String goalHasContributionsBody(String amount, String name);

  /// No description provided for @goalRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund {amount} to balance'**
  String goalRefund(String amount);

  /// No description provided for @goalRefundHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete the goal and 1 contribution. Your balance goes back up.} other{Delete the goal and {count} contributions. Your balance goes back up.}}'**
  String goalRefundHint(int count);

  /// No description provided for @goalKeepHistory.
  ///
  /// In en, this message translates to:
  /// **'Keep history'**
  String get goalKeepHistory;

  /// No description provided for @goalKeepHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Move it to the History tab as cancelled'**
  String get goalKeepHistoryHint;

  /// No description provided for @goalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted'**
  String get goalDeleted;

  /// No description provided for @goalRefunded.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted. {amount} is back in your balance.'**
  String goalRefunded(String amount);

  /// No description provided for @goalMovedToHistory.
  ///
  /// In en, this message translates to:
  /// **'Goal moved to History'**
  String get goalMovedToHistory;

  /// No description provided for @goalCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get goalCompletedTitle;

  /// No description provided for @goalCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'You saved the full {amount} for \"{name}\". Great discipline!'**
  String goalCompletedBody(String amount, String name);

  /// No description provided for @goalCompletedBadge.
  ///
  /// In en, this message translates to:
  /// **'Completed · {date}'**
  String goalCompletedBadge(String date);

  /// No description provided for @goalCreateNext.
  ///
  /// In en, this message translates to:
  /// **'Create next goal'**
  String get goalCreateNext;

  /// No description provided for @goalSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'See goal history'**
  String get goalSeeHistory;

  /// No description provided for @goalCancelledInfo.
  ///
  /// In en, this message translates to:
  /// **'This goal was cancelled. Its contributions are kept in your history.'**
  String get goalCancelledInfo;

  /// No description provided for @menuReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get menuReports;

  /// No description provided for @menuCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get menuCategories;

  /// No description provided for @menuChatbot.
  ///
  /// In en, this message translates to:
  /// **'Penny assistant'**
  String get menuChatbot;

  /// No description provided for @menuLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning corner'**
  String get menuLearning;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About PennyPal'**
  String get menuAbout;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What is PennyPal?'**
  String get aboutWhatTitle;

  /// No description provided for @aboutWhatBody.
  ///
  /// In en, this message translates to:
  /// **'A money diary, reminder and finance tutor for students: record income and expenses, set budgets, save for goals and learn how to manage money.'**
  String get aboutWhatBody;

  /// No description provided for @aboutNotBank.
  ///
  /// In en, this message translates to:
  /// **'PennyPal is not a bank, wallet, payment or investment service. It does not connect to bank accounts, store cards or make real payments. All tips are for learning only.'**
  String get aboutNotBank;

  /// No description provided for @aboutDataTitle.
  ///
  /// In en, this message translates to:
  /// **'How your data is protected'**
  String get aboutDataTitle;

  /// No description provided for @aboutData1.
  ///
  /// In en, this message translates to:
  /// **'Data travels over encrypted TLS connections and is stored encrypted on Firebase.'**
  String get aboutData1;

  /// No description provided for @aboutData2.
  ///
  /// In en, this message translates to:
  /// **'Passwords are handled by Firebase Authentication. PennyPal never stores your password.'**
  String get aboutData2;

  /// No description provided for @aboutData3.
  ///
  /// In en, this message translates to:
  /// **'Receipt photos stay on your phone only.'**
  String get aboutData3;

  /// No description provided for @aboutData4.
  ///
  /// In en, this message translates to:
  /// **'Admins only see summary numbers, never your individual transactions.'**
  String get aboutData4;

  /// No description provided for @aboutContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutContactTitle;

  /// No description provided for @aboutTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Development team'**
  String get aboutTeamTitle;

  /// No description provided for @aboutTeamBody.
  ///
  /// In en, this message translates to:
  /// **'{team} · TechWiz 7 · Multi-Platform App Computing'**
  String aboutTeamBody(String team);

  /// No description provided for @aboutToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Libraries & AI tools'**
  String get aboutToolsTitle;

  /// No description provided for @aboutLibraries.
  ///
  /// In en, this message translates to:
  /// **'Libraries: Flutter, Firebase Authentication, Firebase Realtime Database, Google ML Kit Text Recognition, image_picker, fl_chart, string_similarity, shared_preferences, intl.'**
  String get aboutLibraries;

  /// No description provided for @aboutAiTools.
  ///
  /// In en, this message translates to:
  /// **'AI tools: Claude (code assistant and UI design reference).'**
  String get aboutAiTools;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'Changing the currency only changes how amounts are shown.'**
  String get settingsCurrencyNote;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts and goal milestones'**
  String get settingsNotificationsBody;

  /// No description provided for @settingsStudentStatus.
  ///
  /// In en, this message translates to:
  /// **'Student status'**
  String get settingsStudentStatus;

  /// No description provided for @settingsNoStatus.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get settingsNoStatus;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get settingsSaved;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of PennyPal?'**
  String get settingsLogoutTitle;

  /// No description provided for @settingsLogoutBody.
  ///
  /// In en, this message translates to:
  /// **'You can log in again any time with your email and password.'**
  String get settingsLogoutBody;

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters'**
  String validationMinLength(int min);

  /// No description provided for @commonBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get commonBackHome;

  /// No description provided for @feedbackQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do you like PennyPal?'**
  String get feedbackQuestion;

  /// No description provided for @feedbackRating1.
  ///
  /// In en, this message translates to:
  /// **'Not good'**
  String get feedbackRating1;

  /// No description provided for @feedbackRating2.
  ///
  /// In en, this message translates to:
  /// **'Could be better'**
  String get feedbackRating2;

  /// No description provided for @feedbackRating3.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay'**
  String get feedbackRating3;

  /// No description provided for @feedbackRating4.
  ///
  /// In en, this message translates to:
  /// **'Really like it!'**
  String get feedbackRating4;

  /// No description provided for @feedbackRating5.
  ///
  /// In en, this message translates to:
  /// **'Love it!'**
  String get feedbackRating5;

  /// No description provided for @feedbackStar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String feedbackStar(int count);

  /// No description provided for @feedbackComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get feedbackComments;

  /// No description provided for @feedbackCommentsHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you like or what we can improve'**
  String get feedbackCommentsHint;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackSend;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you, {name}!'**
  String feedbackThanks(String name);

  /// No description provided for @feedbackThanksBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Penny got your 1-star feedback.} other{Penny got your {count}-star feedback.}} The team will read it carefully to make PennyPal better.'**
  String feedbackThanksBody(int count);

  /// No description provided for @feedbackSendAnother.
  ///
  /// In en, this message translates to:
  /// **'Send more feedback'**
  String get feedbackSendAnother;

  /// No description provided for @supportEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Support email'**
  String get supportEmailLabel;

  /// No description provided for @supportMyRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get supportMyRequests;

  /// No description provided for @supportNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests yet. Ask us anything about using PennyPal.'**
  String get supportNoRequests;

  /// No description provided for @supportNew.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get supportNew;

  /// No description provided for @supportReplied.
  ///
  /// In en, this message translates to:
  /// **'Replied'**
  String get supportReplied;

  /// No description provided for @supportWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get supportWaiting;

  /// No description provided for @supportSentOn.
  ///
  /// In en, this message translates to:
  /// **'Sent {date}'**
  String supportSentOn(String date);

  /// No description provided for @supportReplyFrom.
  ///
  /// In en, this message translates to:
  /// **'PennyPal Support · {date}'**
  String supportReplyFrom(String date);

  /// No description provided for @supportSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get supportSubject;

  /// No description provided for @supportSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Can\'t change the currency'**
  String get supportSubjectHint;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get supportMessage;

  /// No description provided for @supportMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem so we can help'**
  String get supportMessageHint;

  /// No description provided for @supportSend.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get supportSend;

  /// No description provided for @supportSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request sent!'**
  String get supportSentTitle;

  /// No description provided for @supportSentBody.
  ///
  /// In en, this message translates to:
  /// **'Penny will let you know as soon as the support team replies.'**
  String get supportSentBody;

  /// No description provided for @supportSentAt.
  ///
  /// In en, this message translates to:
  /// **'Sent at {time}'**
  String supportSentAt(String time);

  /// No description provided for @supportSeeRequests.
  ///
  /// In en, this message translates to:
  /// **'See my requests'**
  String get supportSeeRequests;

  /// No description provided for @topicBudgeting.
  ///
  /// In en, this message translates to:
  /// **'Budgeting'**
  String get topicBudgeting;

  /// No description provided for @topicSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get topicSaving;

  /// No description provided for @topicIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get topicIncome;

  /// No description provided for @topicNeedsVsWants.
  ///
  /// In en, this message translates to:
  /// **'Needs vs. wants'**
  String get topicNeedsVsWants;

  /// No description provided for @topicSmartSpending.
  ///
  /// In en, this message translates to:
  /// **'Smart spending'**
  String get topicSmartSpending;

  /// No description provided for @levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// No description provided for @learningAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get learningAll;

  /// No description provided for @learningEmpty.
  ///
  /// In en, this message translates to:
  /// **'No lessons yet. New tips will appear here soon.'**
  String get learningEmpty;

  /// No description provided for @learningEmptyTopic.
  ///
  /// In en, this message translates to:
  /// **'No lessons in this topic yet.'**
  String get learningEmptyTopic;

  /// No description provided for @learningMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min read} other{{count} min read}}'**
  String learningMinutes(int count);

  /// No description provided for @learningDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'For learning only. This is not professional financial advice.'**
  String get learningDisclaimer;

  /// No description provided for @reportsByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get reportsByCategory;

  /// No description provided for @reportsTotalSpending.
  ///
  /// In en, this message translates to:
  /// **'Total spending'**
  String get reportsTotalSpending;

  /// No description provided for @reportsTrend.
  ///
  /// In en, this message translates to:
  /// **'Income and spending, 6 months'**
  String get reportsTrend;

  /// No description provided for @reportsTrendSummary.
  ///
  /// In en, this message translates to:
  /// **'{month}: income {income} · spending {spending}'**
  String reportsTrendSummary(String month, String income, String spending);

  /// No description provided for @reportsTop.
  ///
  /// In en, this message translates to:
  /// **'Top spending'**
  String get reportsTop;

  /// No description provided for @reportsNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get reportsNoData;

  /// No description provided for @reportsNoDataBody.
  ///
  /// In en, this message translates to:
  /// **'{month} has no transactions yet. Add a few expenses so Penny can draw your charts.'**
  String reportsNoDataBody(String month);

  /// No description provided for @reportsSeeMonth.
  ///
  /// In en, this message translates to:
  /// **'See the {month} report'**
  String reportsSeeMonth(String month);

  /// No description provided for @reportsNoSpending.
  ///
  /// In en, this message translates to:
  /// **'No spending this month. Savings contributions are not counted as spending.'**
  String get reportsNoSpending;

  /// No description provided for @inboxTitleBudgetWarning.
  ///
  /// In en, this message translates to:
  /// **'Close to your limit'**
  String get inboxTitleBudgetWarning;

  /// No description provided for @inboxTitleBudgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get inboxTitleBudgetExceeded;

  /// No description provided for @inboxTitleGoalMilestone.
  ///
  /// In en, this message translates to:
  /// **'New milestone'**
  String get inboxTitleGoalMilestone;

  /// No description provided for @inboxTitleGoalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goal completed'**
  String get inboxTitleGoalCompleted;

  /// No description provided for @inboxTitleSupportReplied.
  ///
  /// In en, this message translates to:
  /// **'Support replied'**
  String get inboxTitleSupportReplied;

  /// No description provided for @inboxBudgetWarning.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent}% of your {category} budget.'**
  String inboxBudgetWarning(int percent, String category);

  /// No description provided for @inboxBudgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'You\'re over your {category} budget by {amount}.'**
  String inboxBudgetExceeded(String category, String amount);

  /// No description provided for @inboxGoalMilestone.
  ///
  /// In en, this message translates to:
  /// **'\"{goal}\" reached {percent}%! Keep going.'**
  String inboxGoalMilestone(String goal, int percent);

  /// No description provided for @inboxGoalCompleted.
  ///
  /// In en, this message translates to:
  /// **'You completed \"{goal}\"!'**
  String inboxGoalCompleted(String goal);

  /// No description provided for @inboxSupportReplied.
  ///
  /// In en, this message translates to:
  /// **'Support replied to \"{subject}\".'**
  String inboxSupportReplied(String subject);

  /// No description provided for @inboxMonthly.
  ///
  /// In en, this message translates to:
  /// **'monthly'**
  String get inboxMonthly;

  /// No description provided for @inboxUnread.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String inboxUnread(int count);

  /// No description provided for @inboxMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get inboxMarkAllRead;

  /// No description provided for @inboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet. Penny will let you know about budgets, goals and support replies here.'**
  String get inboxEmpty;

  /// No description provided for @inboxJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get inboxJustNow;

  /// No description provided for @inboxMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String inboxMinutesAgo(int count);

  /// No description provided for @inboxHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String inboxHoursAgo(int count);

  /// No description provided for @categoryExpenseTab.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get categoryExpenseTab;

  /// No description provided for @categoryIncomeTab.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get categoryIncomeTab;

  /// No description provided for @categoryMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get categoryMine;

  /// No description provided for @categoryDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get categoryDefault;

  /// No description provided for @categoryNoCustom.
  ///
  /// In en, this message translates to:
  /// **'No categories of your own yet. Tap + to add one.'**
  String get categoryNoCustom;

  /// No description provided for @categoryNotUsed.
  ///
  /// In en, this message translates to:
  /// **'Not used'**
  String get categoryNotUsed;

  /// No description provided for @categoryUsage.
  ///
  /// In en, this message translates to:
  /// **'{transactions, plural, =1{1 transaction} other{{transactions} transactions}} · {budgets, plural, =1{1 budget} other{{budgets} budgets}}'**
  String categoryUsage(int transactions, int budgets);

  /// No description provided for @categorySavingsNote.
  ///
  /// In en, this message translates to:
  /// **'\"Savings\" is created automatically when you contribute to a goal.'**
  String get categorySavingsNote;

  /// No description provided for @categoryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoryAdd;

  /// No description provided for @categoryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryEdit;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @categoryNameHelp.
  ///
  /// In en, this message translates to:
  /// **'2-30 characters, not the same as another category of this type'**
  String get categoryNameHelp;

  /// No description provided for @categoryNameLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be 2-30 characters'**
  String get categoryNameLength;

  /// No description provided for @categoryNameExists.
  ///
  /// In en, this message translates to:
  /// **'This name already exists'**
  String get categoryNameExists;

  /// No description provided for @categoryType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get categoryType;

  /// No description provided for @categoryTypeLocked.
  ///
  /// In en, this message translates to:
  /// **'This category already has transactions, so its type can\'t change.'**
  String get categoryTypeLocked;

  /// No description provided for @categoryIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoryIcon;

  /// No description provided for @categoryColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryColor;

  /// No description provided for @categorySave.
  ///
  /// In en, this message translates to:
  /// **'Save category'**
  String get categorySave;

  /// No description provided for @categorySaved.
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get categorySaved;

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String categoryDeleteTitle(String name);

  /// No description provided for @categoryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This category is not used yet, so nothing else changes.'**
  String get categoryDeleteBody;

  /// No description provided for @categoryInUse.
  ///
  /// In en, this message translates to:
  /// **'This category is used by {transactions, plural, =1{1 transaction} other{{transactions} transactions}} and {budgets, plural, =1{1 budget} other{{budgets} budgets}}, so it can\'t be deleted.'**
  String categoryInUse(int transactions, int budgets);

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answers from your own data'**
  String get chatSubtitle;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Penny about your money...'**
  String get chatHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Educational guidance only, not professional financial advice.'**
  String get chatDisclaimer;

  /// No description provided for @chatChipTop.
  ///
  /// In en, this message translates to:
  /// **'What did I spend most on?'**
  String get chatChipTop;

  /// No description provided for @chatChipBudget.
  ///
  /// In en, this message translates to:
  /// **'How much budget is left?'**
  String get chatChipBudget;

  /// No description provided for @chatChipGoal.
  ///
  /// In en, this message translates to:
  /// **'How is my savings goal?'**
  String get chatChipGoal;

  /// No description provided for @chatChipSave.
  ///
  /// In en, this message translates to:
  /// **'How can I save money?'**
  String get chatChipSave;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}! I\'m Penny. Ask me about your spending, budgets or goals.'**
  String chatWelcome(String name);

  /// No description provided for @chatHelp.
  ///
  /// In en, this message translates to:
  /// **'I can tell you where your money went this month, how much budget is left, how your goals are going and how this month compares to last month. I also share simple budgeting and saving tips.'**
  String get chatHelp;

  /// No description provided for @chatTopSpending.
  ///
  /// In en, this message translates to:
  /// **'In {month} you spent the most on {category}: {amount}, {percent} of your spending.'**
  String chatTopSpending(String month, String category, String amount, String percent);

  /// No description provided for @chatTopTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: a budget for your biggest category is the easiest way to keep it under control.'**
  String get chatTopTip;

  /// No description provided for @chatNoSpending.
  ///
  /// In en, this message translates to:
  /// **'You have no spending in {month} yet. Add an expense and ask me again.'**
  String chatNoSpending(String month);

  /// No description provided for @chatPercentOfLimit.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of limit'**
  String chatPercentOfLimit(int percent);

  /// No description provided for @chatMonthSummary.
  ///
  /// In en, this message translates to:
  /// **'In {month} you earned {income}, spent {spending} and saved {savings}.'**
  String chatMonthSummary(String month, String income, String spending, String savings);

  /// No description provided for @chatTotalBudgetName.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get chatTotalBudgetName;

  /// No description provided for @chatBudgetLeft.
  ///
  /// In en, this message translates to:
  /// **'Your {name} budget for {month}: {left} left of {limit} ({percent}% used).'**
  String chatBudgetLeft(String name, String month, String left, String limit, int percent);

  /// No description provided for @chatBudgetOver.
  ///
  /// In en, this message translates to:
  /// **'Your {name} budget for {month} is over by {amount} ({percent}% used).'**
  String chatBudgetOver(String name, String month, String amount, int percent);

  /// No description provided for @chatNoBudget.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a {name} budget for {month} yet. Create one in the Budget tab so I can keep track of it.'**
  String chatNoBudget(String name, String month);

  /// No description provided for @chatGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'\"{goal}\": {current} of {target} ({percent}%). {pace}'**
  String chatGoalProgress(String goal, String current, String target, int percent, String pace);

  /// No description provided for @chatPaceOnTrack.
  ///
  /// In en, this message translates to:
  /// **'You\'re on track to finish around {date}.'**
  String chatPaceOnTrack(String date);

  /// No description provided for @chatPaceBehind.
  ///
  /// In en, this message translates to:
  /// **'At this pace you\'ll finish around {date}, after your deadline {due}.'**
  String chatPaceBehind(String date, String due);

  /// No description provided for @chatPaceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly contribution so I can estimate when you\'ll finish.'**
  String get chatPaceUnknown;

  /// No description provided for @chatNoGoal.
  ///
  /// In en, this message translates to:
  /// **'You have no active goals. Create one in the Goals tab and start saving!'**
  String get chatNoGoal;

  /// No description provided for @chatCompareMore.
  ///
  /// In en, this message translates to:
  /// **'So far this month you spent {current}. By this day last month you had spent {last}: {percent} more.'**
  String chatCompareMore(String current, String last, String percent);

  /// No description provided for @chatCompareLess.
  ///
  /// In en, this message translates to:
  /// **'So far this month you spent {current}. By this day last month you had spent {last}: {percent} less. Nice!'**
  String chatCompareLess(String current, String last, String percent);

  /// No description provided for @chatCompareNoLast.
  ///
  /// In en, this message translates to:
  /// **'There\'s no spending in the same days of last month to compare with. So far this month you spent {current}.'**
  String chatCompareNoLast(String current);

  /// No description provided for @chatCompareSame.
  ///
  /// In en, this message translates to:
  /// **'So far this month you spent {current}, the same as by this day last month.'**
  String chatCompareSame(String current);

  /// No description provided for @chatBudgetingTips.
  ///
  /// In en, this message translates to:
  /// **'Try the 50/30/20 rule: 50% for needs, 30% for wants and 20% for savings. Set a total budget for the month, then add budgets for the categories you spend most on.'**
  String get chatBudgetingTips;

  /// No description provided for @chatSavingTips.
  ///
  /// In en, this message translates to:
  /// **'Save a fixed part, like 10%, on the day you get money, before spending. Give your savings a name by creating a goal, and wait 24 hours before buying things you don\'t need.'**
  String get chatSavingTips;

  /// No description provided for @chatNeedsWants.
  ///
  /// In en, this message translates to:
  /// **'Needs are things you must pay for to live and study: meals, rent, transport, textbooks. Wants make life nicer but can wait. Ask yourself: what happens if I don\'t buy this?'**
  String get chatNeedsWants;

  /// No description provided for @chatUnknown.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t understand that yet. Try one of these:'**
  String get chatUnknown;

  /// No description provided for @chatDataLoading.
  ///
  /// In en, this message translates to:
  /// **'I\'m still loading your data. Please ask again in a moment.'**
  String get chatDataLoading;

  /// No description provided for @chatDataFailed.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t load your data right now, so I can\'t answer with your numbers. You can still ask me for budgeting or saving tips.'**
  String get chatDataFailed;

  /// No description provided for @chatCategorySpending.
  ///
  /// In en, this message translates to:
  /// **'In {month} you spent {amount} on {category}, {percent} of your spending.'**
  String chatCategorySpending(String month, String amount, String category, String percent);

  /// No description provided for @chatOnlyThisMonth.
  ///
  /// In en, this message translates to:
  /// **'I can only answer about {month}. To see another month, open Reports.'**
  String chatOnlyThisMonth(String month);

  /// No description provided for @reportsTypeSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get reportsTypeSpending;

  /// No description provided for @reportsTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get reportsTypeIncome;

  /// No description provided for @reportsIncomeByCategory.
  ///
  /// In en, this message translates to:
  /// **'Income by source'**
  String get reportsIncomeByCategory;

  /// No description provided for @reportsTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get reportsTotalIncome;

  /// No description provided for @reportsTopIncome.
  ///
  /// In en, this message translates to:
  /// **'Biggest income sources'**
  String get reportsTopIncome;

  /// No description provided for @reportsNoIncome.
  ///
  /// In en, this message translates to:
  /// **'No income this month yet.'**
  String get reportsNoIncome;

  /// No description provided for @reportsBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance (income − expenses)'**
  String get reportsBalance;

  /// No description provided for @reportsBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget vs actual'**
  String get reportsBudgetTitle;

  /// No description provided for @reportsNoBudget.
  ///
  /// In en, this message translates to:
  /// **'No budget set for this month.'**
  String get reportsNoBudget;

  /// No description provided for @reportsBudgetUsed.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit} · {percent}%'**
  String reportsBudgetUsed(String spent, String limit, int percent);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
