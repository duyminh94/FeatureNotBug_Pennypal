// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'PennyPal';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonCancel => 'Huỷ';

  @override
  String get commonDelete => 'Xoá';

  @override
  String get commonEdit => 'Sửa';

  @override
  String get commonAdd => 'Thêm';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonSearch => 'Tìm kiếm';

  @override
  String get commonFilter => 'Lọc';

  @override
  String get commonClearFilter => 'Xoá bộ lọc';

  @override
  String get commonLoading => 'Đang tải…';

  @override
  String get commonNoData => 'Chưa có dữ liệu';

  @override
  String get commonDeleteConfirm => 'Bạn chắc chắn muốn xoá?';

  @override
  String get commonSubmitSuccess => 'Gửi thành công';

  @override
  String get commonNotSynced => 'Chưa đồng bộ';

  @override
  String get commonPreviousMonth => 'Tháng trước';

  @override
  String get commonNextMonth => 'Tháng sau';

  @override
  String get commonOffline =>
      'Đang offline. Dữ liệu sẽ tự đồng bộ khi có mạng.';

  @override
  String get validationRequired => 'Vui lòng nhập thông tin';

  @override
  String get validationEmail => 'Email không hợp lệ';

  @override
  String get validationPassword => 'Tối thiểu 8 ký tự, gồm chữ và số';

  @override
  String get validationPasswordMatch => 'Mật khẩu không khớp';

  @override
  String get validationMobile => 'Số điện thoại gồm 9–15 chữ số';

  @override
  String get validationAmountPositive => 'Số tiền phải lớn hơn 0';

  @override
  String get validationAmountMax => 'Số tiền quá lớn';

  @override
  String get validationDateFuture => 'Ngày không được ở tương lai';

  @override
  String get validationDateRange => 'Ngày bắt đầu phải trước ngày kết thúc';

  @override
  String validationMaxLength(int max) {
    return 'Tối đa $max ký tự';
  }

  @override
  String get validationRating => 'Vui lòng chọn số sao';

  @override
  String get errorEmailInUse => 'Email đã được sử dụng';

  @override
  String get errorInvalidLogin => 'Email hoặc mật khẩu không đúng';

  @override
  String get errorWeakPassword => 'Mật khẩu quá yếu';

  @override
  String get errorTooManyRequests => 'Thử quá nhiều lần, vui lòng thử lại sau';

  @override
  String get errorNetwork => 'Không có kết nối mạng';

  @override
  String get errorPermission => 'Bạn không có quyền thực hiện';

  @override
  String get errorUnknown => 'Đã có lỗi, vui lòng thử lại';

  @override
  String get errorWrongApp => 'Tài khoản không dùng cho app này';

  @override
  String get errorAccountLocked => 'Tài khoản đã bị khoá';

  @override
  String get categoryFood => 'Ăn uống';

  @override
  String get categoryTransport => 'Đi lại';

  @override
  String get categoryEducation => 'Học tập';

  @override
  String get categoryShopping => 'Mua sắm';

  @override
  String get categoryEntertainment => 'Giải trí';

  @override
  String get categoryBills => 'Hoá đơn';

  @override
  String get categorySavings => 'Tiết kiệm';

  @override
  String get categoryMiscellaneous => 'Khác';

  @override
  String get categoryAllowance => 'Trợ cấp';

  @override
  String get categoryScholarship => 'Học bổng';

  @override
  String get categoryPartTime => 'Làm thêm';

  @override
  String get categoryInternship => 'Thực tập';

  @override
  String get categoryGift => 'Quà tặng';

  @override
  String get categoryOtherIncome => 'Khác';

  @override
  String get commonComingSoon => 'Màn này sẽ sớm có';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get splashTagline => 'Sổ thu chi vui vẻ cho sinh viên';

  @override
  String get splashSubtitle =>
      'Ghi chép, đặt ngân sách và để dành — nhẹ nhàng mỗi ngày.';

  @override
  String get splashGetStarted => 'Bắt đầu';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authShowPassword => 'Hiện mật khẩu';

  @override
  String get authHidePassword => 'Ẩn mật khẩu';

  @override
  String get authLoginTitle => 'Chào mừng quay lại!';

  @override
  String get authLoginSubtitle =>
      'Đăng nhập để tiếp tục theo dõi chi tiêu nhé.';

  @override
  String get authForgotPassword => 'Quên mật khẩu?';

  @override
  String get authLoginButton => 'Đăng nhập';

  @override
  String get authNoAccount => 'Chưa có tài khoản?';

  @override
  String get authRegisterNow => 'Đăng ký ngay';

  @override
  String get authRegisterTitle => 'Tạo tài khoản';

  @override
  String get authRegisterSubtitle => 'Chỉ mất 1 phút thôi!';

  @override
  String get authFullName => 'Họ và tên';

  @override
  String get authMobile => 'Số điện thoại';

  @override
  String get authStudentStatus => 'Tình trạng học tập (không bắt buộc)';

  @override
  String get authConfirmPassword => 'Nhập lại mật khẩu';

  @override
  String get authRegisterButton => 'Đăng ký';

  @override
  String get authHaveAccount => 'Đã có tài khoản?';

  @override
  String get studentStatusHighSchool => 'Học sinh THPT';

  @override
  String get studentStatusUndergraduate => 'Sinh viên đại học / cao đẳng';

  @override
  String get studentStatusPostgraduate => 'Học viên sau đại học';

  @override
  String get studentStatusOther => 'Khác';

  @override
  String get authForgotSubtitle =>
      'Nhập email đã đăng ký, Penny sẽ gửi link để bạn đặt lại mật khẩu.';

  @override
  String get authSendResetLink => 'Gửi link đặt lại';

  @override
  String get authResetSentTitle => 'Đã gửi!';

  @override
  String authResetSentBody(String email) {
    return 'Kiểm tra hộp thư $email (cả mục Spam) để đặt lại mật khẩu.';
  }

  @override
  String authResendIn(int seconds) {
    return 'Gửi lại sau $seconds giây';
  }

  @override
  String get authBackToLogin => 'Quay về đăng nhập';

  @override
  String get notifTitle => 'Để Penny nhắc bạn nhé!';

  @override
  String get notifSubtitle => 'Bật thông báo để không lỡ những lúc quan trọng:';

  @override
  String get notifBudgetTitle => 'Sắp tiêu lố ngân sách';

  @override
  String get notifBudgetBody => 'Nhắc khi bạn chạm ngưỡng cảnh báo';

  @override
  String get notifGoalTitle => 'Đạt cột mốc mục tiêu';

  @override
  String get notifGoalBody => '25%, 50%, 75% và 100%';

  @override
  String get notifSupportTitle => 'Hỗ trợ đã trả lời';

  @override
  String get notifSupportBody => 'Biết ngay khi có phản hồi';

  @override
  String get notifAllow => 'Cho phép thông báo';

  @override
  String get notifLater => 'Để sau';

  @override
  String get notifFootnote =>
      'Từ chối vẫn dùng app bình thường · đổi lại trong Cài đặt';

  @override
  String get commonToday => 'Hôm nay';

  @override
  String get commonSeeAll => 'Xem tất cả';

  @override
  String get commonClose => 'Đóng';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navTransactions => 'Giao dịch';

  @override
  String get navBudget => 'Ngân sách';

  @override
  String get navGoals => 'Mục tiêu';

  @override
  String get navMore => 'Thêm';

  @override
  String get dashGreetingMorning => 'Chào buổi sáng,';

  @override
  String get dashGreetingAfternoon => 'Chào buổi chiều,';

  @override
  String get dashGreetingEvening => 'Chào buổi tối,';

  @override
  String get dashNotifications => 'Thông báo';

  @override
  String get dashBalance => 'Số dư hiện có';

  @override
  String get dashBalanceHint => 'Cập nhật từ toàn bộ lịch sử thu chi';

  @override
  String get dashBalanceEmptyHint => 'Bắt đầu ghi chép để thấy số dư';

  @override
  String get dashBalanceNegativeHint => 'Chi đang vượt thu.';

  @override
  String get dashMonthIncome => 'Thu tháng';

  @override
  String get dashMonthExpense => 'Chi tiêu';

  @override
  String get dashMonthSavings => 'Tiết kiệm';

  @override
  String get dashSavedInGoals => 'Đã tiết kiệm';

  @override
  String dashBudgetTitle(String month) {
    return 'Ngân sách $month';
  }

  @override
  String dashBudgetLeft(String amount) {
    return 'Còn $amount';
  }

  @override
  String dashBudgetOver(String amount) {
    return 'Vượt $amount';
  }

  @override
  String dashBudgetUsed(int percent) {
    return 'Đã dùng $percent%';
  }

  @override
  String get dashNoBudgetTitle => 'Chưa có ngân sách';

  @override
  String get dashNoBudgetBody => 'Đặt hạn mức để được nhắc khi sắp tiêu lố.';

  @override
  String get dashCreateBudget => 'Tạo ngân sách';

  @override
  String get dashGoalsTitle => 'Mục tiêu đang theo';

  @override
  String dashGoalDeadline(String date) {
    return 'Hạn $date';
  }

  @override
  String get dashShortcuts => 'Lối tắt';

  @override
  String get dashAddIncome => 'Thêm thu';

  @override
  String get dashAddExpense => 'Thêm chi';

  @override
  String get dashHistory => 'Lịch sử';

  @override
  String get dashLearning => 'Học tập';

  @override
  String get dashFeedback => 'Góp ý';

  @override
  String get dashSupport => 'Hỗ trợ';

  @override
  String get dashRecent => 'Giao dịch gần đây';

  @override
  String get dashNoTxTitle => 'Chưa có giao dịch nào';

  @override
  String get dashNoTxBody =>
      'Ghi khoản chi đầu tiên để Penny giúp bạn biết tiền đi đâu nhé.';

  @override
  String get dashAskPenny => 'Hỏi Penny nè!';

  @override
  String get txAddExpenseTitle => 'Thêm khoản chi';

  @override
  String get txAddIncomeTitle => 'Thêm khoản thu';

  @override
  String get txEditExpenseTitle => 'Sửa khoản chi';

  @override
  String get txEditIncomeTitle => 'Sửa khoản thu';

  @override
  String get txAmount => 'Số tiền';

  @override
  String get txCategory => 'Danh mục';

  @override
  String get txIncomeSource => 'Nguồn thu';

  @override
  String get txManage => 'Quản lý';

  @override
  String get txDate => 'Ngày';

  @override
  String get txDescription => 'Mô tả';

  @override
  String get txDescriptionHint => 'Thêm mô tả';

  @override
  String get txPaymentMode => 'Hình thức thanh toán';

  @override
  String get paymentCash => 'Tiền mặt';

  @override
  String get paymentBankTransfer => 'Chuyển khoản';

  @override
  String get paymentEWallet => 'Ví điện tử';

  @override
  String get paymentOther => 'Khác';

  @override
  String get txScanReceipt => 'Quét hoá đơn';

  @override
  String get txSaveExpense => 'Lưu khoản chi';

  @override
  String get txSaveIncome => 'Lưu khoản thu';

  @override
  String get txSaveChanges => 'Lưu thay đổi';

  @override
  String get txSaved => 'Đã lưu';

  @override
  String get txDeleted => 'Đã xoá giao dịch';

  @override
  String get txDeleteTitle => 'Xoá giao dịch này?';

  @override
  String txDeleteBody(String name, String amount) {
    return '“$name” $amount sẽ bị xoá. Số dư và ngân sách sẽ được tính lại.';
  }

  @override
  String get validationCategory => 'Vui lòng chọn danh mục';

  @override
  String get commonYesterday => 'Hôm qua';

  @override
  String get commonUndo => 'Hoàn tác';

  @override
  String get historySearchHint => 'Tìm theo mô tả, vd: cơm trưa';

  @override
  String get historyAddTransaction => 'Thêm giao dịch';

  @override
  String get filterAllTypes => 'Tất cả';

  @override
  String get filterExpense => 'Chi';

  @override
  String get filterIncome => 'Thu';

  @override
  String get filterAllCategories => 'Tất cả danh mục';

  @override
  String get filterAllDates => 'Mọi ngày';

  @override
  String get historyEmpty => 'Không có giao dịch phù hợp';

  @override
  String historyDeletedNamed(String name) {
    return 'Đã xoá “$name”';
  }

  @override
  String get detailTitle => 'Chi tiết giao dịch';

  @override
  String get detailType => 'Loại';

  @override
  String get typeExpense => 'Khoản chi';

  @override
  String get typeIncome => 'Khoản thu';

  @override
  String get detailEdit => 'Sửa giao dịch';

  @override
  String get detailContributionLocked =>
      'Khoản góp cho mục tiêu — sửa hoặc xoá trong tab Mục tiêu.';

  @override
  String get scanSheetBody =>
      'Penny đọc chữ ngay trên máy, không gửi ảnh lên mạng.';

  @override
  String get scanFromCamera => 'Chụp ảnh';

  @override
  String get scanFromCameraHint => 'Dùng camera để chụp hoá đơn';

  @override
  String get scanFromGallery => 'Chọn từ thư viện';

  @override
  String get scanFromGalleryHint => 'Ảnh hoá đơn đã có sẵn';

  @override
  String get scanReading => 'Đang đọc hoá đơn…';

  @override
  String get scanFilledHint => 'Vui lòng kiểm tra các ô được đánh dấu';

  @override
  String get scanFilledFromReceipt => 'Điền từ hoá đơn';

  @override
  String scanSuggested(String name) {
    return 'gợi ý: $name';
  }

  @override
  String get scanNoText => 'Không đọc được hoá đơn';

  @override
  String get scanNoTextBody =>
      'Ảnh vẫn được gắn vào khoản chi. Bạn nhập tay giúp Penny, hoặc chụp lại chỗ đủ sáng nhé.';

  @override
  String get scanNoAmount => 'Không tìm thấy số tiền';

  @override
  String get scanNoAmountBody =>
      'Các ô khác đã điền sẵn — bạn nhập số tiền và kiểm tra lại nhé.';

  @override
  String get scanEnterAmount => 'Nhập số tiền';

  @override
  String get scanAgain => 'Quét lại';

  @override
  String get scanPermissionDenied => 'Cần quyền camera để quét hoá đơn';

  @override
  String get scanPermissionBody =>
      'PennyPal chưa được dùng camera. Bật lại trong Cài đặt của máy, hoặc chọn ảnh có sẵn. Form vẫn nhập tay bình thường.';

  @override
  String get scanEnterManually => 'Nhập tay';

  @override
  String get scanFailed => 'Không mở được ảnh, vui lòng thử lại.';

  @override
  String get receiptPhoto => 'Ảnh hoá đơn';

  @override
  String get receiptPhotoHint => 'Chạm để xem · chỉ lưu trên máy này';

  @override
  String get receiptRemove => 'Xoá ảnh';

  @override
  String get budgetAdd => 'Thêm ngân sách';

  @override
  String get budgetEditTitle => 'Sửa ngân sách';

  @override
  String get budgetTotal => 'Ngân sách tổng';

  @override
  String budgetOfLimit(String amount) {
    return 'trên $amount';
  }

  @override
  String get budgetByCategory => 'Theo danh mục';

  @override
  String budgetCategoryOverTotal(String amount) {
    return 'Tổng hạn mức các danh mục ($amount) đang lớn hơn ngân sách tổng.';
  }

  @override
  String get budgetOverBadge => 'Vượt ngân sách';

  @override
  String get budgetNearBadge => 'Sắp chạm hạn mức';

  @override
  String get budgetEmpty =>
      'Tháng này chưa có ngân sách. Đặt hạn mức để Penny nhắc trước khi bạn tiêu lố.';

  @override
  String get budgetCreateFirst => 'Tạo ngân sách đầu tiên';

  @override
  String get budgetNoTotal => 'Tháng này chưa có ngân sách tổng';

  @override
  String get budgetMonth => 'Tháng';

  @override
  String get budgetType => 'Loại ngân sách';

  @override
  String get budgetTypeTotal => 'Tổng tháng';

  @override
  String get budgetLimit => 'Hạn mức';

  @override
  String get budgetThreshold => 'Ngưỡng cảnh báo';

  @override
  String budgetThresholdHint(String amount) {
    return 'Penny sẽ nhắc khi bạn tiêu tới $amount.';
  }

  @override
  String get budgetLocked =>
      'Không đổi được tháng và danh mục khi sửa — hãy xoá và tạo mới.';

  @override
  String budgetSpentIn(String month) {
    return 'Đã chi $month';
  }

  @override
  String get budgetSave => 'Lưu ngân sách';

  @override
  String get budgetDuplicate => 'Ngân sách này đã tồn tại';

  @override
  String get budgetSaved => 'Đã lưu ngân sách';

  @override
  String get budgetDeleted => 'Đã xoá ngân sách';

  @override
  String get budgetDeleteTitle => 'Xoá ngân sách này?';

  @override
  String budgetDeleteBody(String name, String month) {
    return 'Ngân sách $name $month sẽ bị xoá. Giao dịch của bạn vẫn giữ nguyên.';
  }

  @override
  String get goalAdd => 'Tạo mục tiêu';

  @override
  String get goalEditTitle => 'Sửa mục tiêu';

  @override
  String goalTabActive(int count) {
    return 'Đang thực hiện · $count';
  }

  @override
  String goalTabHistory(int count) {
    return 'Lịch sử · $count';
  }

  @override
  String goalEstimate(String estimated, String due) {
    return 'Dự kiến $estimated · hạn $due';
  }

  @override
  String goalEstimateUnknown(String due) {
    return 'Chưa xác định · hạn $due';
  }

  @override
  String get goalOnTrack => 'Đúng tiến độ';

  @override
  String get goalBehind => 'Không kịp hạn';

  @override
  String get goalNotEstimated => 'Chưa xác định';

  @override
  String get goalCreateNew => 'Tạo mục tiêu mới';

  @override
  String get goalEmptyActive =>
      'Chưa có mục tiêu nào. Đặt một mục tiêu tiết kiệm để Penny giúp bạn theo dõi.';

  @override
  String get goalEmptyHistory =>
      'Mục tiêu đã hoàn thành hoặc đã huỷ sẽ hiện ở đây.';

  @override
  String get goalCompleted => 'Hoàn thành';

  @override
  String get goalCancelled => 'Đã huỷ';

  @override
  String goalCompletedOn(String amount, String date) {
    return '$amount · xong $date';
  }

  @override
  String goalSavedOf(String current, String target) {
    return 'Đã góp $current / $target';
  }

  @override
  String goalKeptContributions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Giữ lịch sử $count khoản góp',
      zero: 'Không có khoản góp',
    );
    return '$_temp0';
  }

  @override
  String goalHistoryBanner(int count, String amount) {
    return 'Bạn đã hoàn thành $count mục tiêu! Tổng đã để dành: $amount.';
  }

  @override
  String get goalName => 'Tên mục tiêu';

  @override
  String get goalNameHint => 'VD: Laptop mới';

  @override
  String get goalTargetAmount => 'Số tiền mục tiêu';

  @override
  String get goalCurrentSavings => 'Tiền tiết kiệm hiện có';

  @override
  String get goalCurrentSavingsHelp =>
      'Số tiền bạn đã để dành trước — không tính là giao dịch, không trừ số dư.';

  @override
  String get goalCurrentSavingsLocked =>
      'Không sửa được tiền tiết kiệm hiện có khi mục tiêu đã có khoản góp.';

  @override
  String get goalTargetDate => 'Hạn hoàn thành';

  @override
  String get goalMonthlyContribution => 'Dự định góp mỗi tháng';

  @override
  String get goalMonthlyContributionHelp =>
      'Chỉ dùng để ước tính, app không tự trừ tiền.';

  @override
  String get goalEstimateTitle => 'Penny ước tính';

  @override
  String goalRemainingMonths(String amount, int months) {
    return 'Còn $amount · $months tháng';
  }

  @override
  String goalFinishAround(String date) {
    return 'Xong khoảng $date';
  }

  @override
  String get goalValidationInitial =>
      'Tiền tiết kiệm hiện có phải nhỏ hơn số tiền mục tiêu. Hãy đặt mục tiêu cao hơn.';

  @override
  String get goalValidationDate => 'Hạn hoàn thành phải sau hôm nay';

  @override
  String get goalSaved => 'Đã lưu mục tiêu';

  @override
  String goalValidationTargetBelowSaved(String amount) {
    return 'Số tiền mục tiêu phải lớn hơn $amount đã để dành';
  }

  @override
  String get goalSavedLabel => 'đã tiết kiệm';

  @override
  String get goalRemainingLabel => 'Còn thiếu';

  @override
  String get goalMonthsLabel => 'Còn khoảng';

  @override
  String goalMonthsValue(int months) {
    return '$months tháng';
  }

  @override
  String get goalEstimatedLabel => 'Dự kiến xong';

  @override
  String get goalMilestones => 'Cột mốc';

  @override
  String get goalMark => 'Đánh dấu';

  @override
  String goalMilestoneMarked(int percent) {
    return 'Đã đánh dấu mốc $percent%!';
  }

  @override
  String goalMilestoneLocked(int percent) {
    return 'Chưa đạt mốc $percent%';
  }

  @override
  String get goalContributions => 'Các lần góp';

  @override
  String get goalNoContributions => 'Chưa có lần góp nào';

  @override
  String goalCreatedInfo(String initial, String monthly, String due) {
    return 'Có sẵn lúc tạo mục tiêu: $initial · góp $monthly/tháng · hạn $due';
  }

  @override
  String get goalDelete => 'Xoá mục tiêu';

  @override
  String get goalContribute => 'Góp tiền';

  @override
  String goalContributeTo(String name) {
    return 'Góp vào “$name”';
  }

  @override
  String get goalEditContribution => 'Sửa khoản góp';

  @override
  String get goalContributionAmount => 'Số tiền góp';

  @override
  String get goalContributionInfo =>
      'Khoản góp sẽ trừ vào số dư nhưng không tính vào ngân sách chi tiêu.';

  @override
  String goalContributeButton(String amount) {
    return 'Góp $amount';
  }

  @override
  String goalContributionTooMuch(String amount) {
    return 'Chỉ cần góp thêm $amount';
  }

  @override
  String goalContributionOverBalance(String amount) {
    return 'Số này lớn hơn số dư hiện tại ($amount). Bạn vẫn góp được nếu có tiền mặt chưa ghi.';
  }

  @override
  String get goalNote => 'Ghi chú';

  @override
  String get goalNoteHint => 'VD: Tiết kiệm từ lương làm thêm';

  @override
  String goalContributed(String amount) {
    return 'Đã góp $amount';
  }

  @override
  String get goalContributionUpdated => 'Đã cập nhật khoản góp';

  @override
  String get goalContributionDeleted => 'Đã xoá khoản góp';

  @override
  String get goalDeleteContributionTitle => 'Xoá khoản góp này?';

  @override
  String goalDeleteContributionBody(String amount) {
    return '$amount sẽ được trả lại số dư.';
  }

  @override
  String get goalDeleteTitle => 'Xoá mục tiêu này?';

  @override
  String goalDeleteBody(String name) {
    return '“$name” sẽ bị xoá.';
  }

  @override
  String get goalHasContributionsTitle => 'Mục tiêu này đã có khoản góp';

  @override
  String goalHasContributionsBody(String amount, String name) {
    return 'Bạn đã góp $amount vào “$name”. Bạn muốn xử lý số tiền này thế nào?';
  }

  @override
  String goalRefund(String amount) {
    return 'Hoàn $amount về số dư';
  }

  @override
  String goalRefundHint(int count) {
    return 'Xoá mục tiêu và $count khoản góp, số dư tăng lại';
  }

  @override
  String get goalKeepHistory => 'Giữ lịch sử';

  @override
  String get goalKeepHistoryHint =>
      'Chuyển sang tab Lịch sử với trạng thái Đã huỷ';

  @override
  String get goalDeleted => 'Đã xoá mục tiêu';

  @override
  String goalRefunded(String amount) {
    return 'Đã xoá mục tiêu, hoàn $amount về số dư.';
  }

  @override
  String get goalMovedToHistory => 'Đã chuyển mục tiêu sang Lịch sử';

  @override
  String get goalCompletedTitle => 'Tuyệt vời!';

  @override
  String goalCompletedBody(String amount, String name) {
    return 'Bạn đã để dành đủ $amount cho “$name”. Kỷ luật quá đỉnh!';
  }

  @override
  String goalCompletedBadge(String date) {
    return 'Đã hoàn thành · $date';
  }

  @override
  String get goalCreateNext => 'Tạo mục tiêu tiếp theo';

  @override
  String get goalSeeHistory => 'Xem lịch sử mục tiêu';

  @override
  String get goalCancelledInfo =>
      'Mục tiêu này đã huỷ. Các khoản góp vẫn giữ trong lịch sử.';

  @override
  String get menuReports => 'Báo cáo';

  @override
  String get menuCategories => 'Danh mục';

  @override
  String get menuChatbot => 'Trợ lý Penny';

  @override
  String get menuLearning => 'Góc học tập';

  @override
  String get menuAbout => 'Giới thiệu PennyPal';

  @override
  String get menuSettings => 'Cài đặt';

  @override
  String get aboutTitle => 'Giới thiệu';

  @override
  String aboutVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get aboutWhatTitle => 'PennyPal là gì?';

  @override
  String get aboutWhatBody =>
      'Sổ thu chi, người nhắc nhở và người dạy kèm tài chính cho sinh viên: ghi thu chi, đặt ngân sách, để dành cho mục tiêu và học cách quản lý tiền.';

  @override
  String get aboutNotBank =>
      'PennyPal không phải ngân hàng, ví, dịch vụ thanh toán hay đầu tư. App không kết nối tài khoản ngân hàng, không lưu thẻ và không thực hiện giao dịch thật. Mọi gợi ý chỉ mang tính giáo dục.';

  @override
  String get aboutDataTitle => 'Dữ liệu của bạn được bảo vệ thế nào';

  @override
  String get aboutData1 =>
      'Truyền qua kết nối mã hoá TLS, lưu trữ mã hoá trên Firebase.';

  @override
  String get aboutData2 =>
      'Mật khẩu do Firebase Authentication quản lý, PennyPal không lưu mật khẩu.';

  @override
  String get aboutData3 => 'Ảnh hoá đơn chỉ nằm trên máy của bạn.';

  @override
  String get aboutData4 =>
      'Quản trị viên chỉ xem số liệu tổng hợp, không xem từng giao dịch.';

  @override
  String get aboutContactTitle => 'Liên hệ';

  @override
  String get aboutTeamTitle => 'Nhóm phát triển';

  @override
  String aboutTeamBody(String team) {
    return '$team · TechWiz 7 — Multi-Platform App Computing';
  }

  @override
  String get aboutToolsTitle => 'Thư viện & công cụ AI';

  @override
  String get aboutLibraries =>
      'Thư viện: Flutter, Firebase Authentication, Firebase Realtime Database, Google ML Kit Text Recognition, image_picker, fl_chart, string_similarity, shared_preferences, intl.';

  @override
  String get aboutAiTools =>
      'Công cụ AI: Claude (trợ lý lập trình và tham khảo thiết kế giao diện).';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsCurrency => 'Tiền tệ';

  @override
  String get settingsCurrencyNote =>
      'Đổi tiền tệ chỉ đổi cách hiển thị số tiền.';

  @override
  String get settingsNotifications => 'Thông báo';

  @override
  String get settingsNotificationsBody =>
      'Cảnh báo ngân sách, cột mốc mục tiêu';

  @override
  String get settingsStudentStatus => 'Tình trạng học tập';

  @override
  String get settingsNoStatus => 'Chưa chọn';

  @override
  String get settingsSaved => 'Đã lưu hồ sơ';

  @override
  String get settingsLogout => 'Đăng xuất';

  @override
  String get settingsLogoutTitle => 'Đăng xuất khỏi PennyPal?';

  @override
  String get settingsLogoutBody =>
      'Bạn có thể đăng nhập lại bất cứ lúc nào bằng email và mật khẩu.';

  @override
  String validationMinLength(int min) {
    return 'Tối thiểu $min ký tự';
  }

  @override
  String get commonBackHome => 'Về trang chủ';

  @override
  String get feedbackQuestion => 'Bạn thấy PennyPal thế nào?';

  @override
  String get feedbackRating1 => 'Chưa tốt';

  @override
  String get feedbackRating2 => 'Cần cải thiện';

  @override
  String get feedbackRating3 => 'Tạm ổn';

  @override
  String get feedbackRating4 => 'Rất thích!';

  @override
  String get feedbackRating5 => 'Tuyệt vời!';

  @override
  String feedbackStar(int count) {
    return '$count sao';
  }

  @override
  String get feedbackComments => 'Nhận xét';

  @override
  String get feedbackCommentsHint =>
      'Kể cho nhóm điều bạn thích hoặc điều cần cải thiện';

  @override
  String get feedbackSend => 'Gửi góp ý';

  @override
  String feedbackThanks(String name) {
    return 'Cảm ơn $name nhiều!';
  }

  @override
  String feedbackThanksBody(int count) {
    return 'Penny đã nhận góp ý $count sao của bạn. Nhóm sẽ đọc kỹ để PennyPal tốt hơn.';
  }

  @override
  String get feedbackSendAnother => 'Gửi góp ý khác';

  @override
  String get supportEmailLabel => 'Email hỗ trợ';

  @override
  String get supportMyRequests => 'Yêu cầu của tôi';

  @override
  String get supportNoRequests =>
      'Chưa có yêu cầu nào. Hãy hỏi nhóm bất cứ điều gì khi dùng PennyPal.';

  @override
  String get supportNew => 'Gửi yêu cầu mới';

  @override
  String get supportReplied => 'Đã phản hồi';

  @override
  String get supportWaiting => 'Đang chờ';

  @override
  String supportSentOn(String date) {
    return 'Gửi $date';
  }

  @override
  String supportReplyFrom(String date) {
    return 'PennyPal Support · $date';
  }

  @override
  String get supportSubject => 'Tiêu đề';

  @override
  String get supportSubjectHint => 'VD: Không đổi được tiền tệ';

  @override
  String get supportMessage => 'Nội dung';

  @override
  String get supportMessageHint => 'Mô tả vấn đề để nhóm hỗ trợ bạn';

  @override
  String get supportSend => 'Gửi yêu cầu';

  @override
  String get supportSentTitle => 'Đã gửi yêu cầu!';

  @override
  String get supportSentBody =>
      'Penny sẽ báo cho bạn ngay khi đội hỗ trợ trả lời.';

  @override
  String supportSentAt(String time) {
    return 'Gửi lúc $time';
  }

  @override
  String get supportSeeRequests => 'Xem yêu cầu của tôi';

  @override
  String get topicBudgeting => 'Lập ngân sách';

  @override
  String get topicSaving => 'Tiết kiệm';

  @override
  String get topicIncome => 'Thu nhập';

  @override
  String get topicNeedsVsWants => 'Chi tiêu cần thiết và tuỳ chọn';

  @override
  String get topicSmartSpending => 'Chi tiêu thông minh';

  @override
  String get levelBeginner => 'Cơ bản';

  @override
  String get levelIntermediate => 'Nâng cao';

  @override
  String get learningAll => 'Tất cả';

  @override
  String get learningEmpty =>
      'Chưa có bài học nào. Mẹo mới sẽ sớm xuất hiện ở đây.';

  @override
  String get learningEmptyTopic => 'Chủ đề này chưa có bài học.';

  @override
  String learningMinutes(int count) {
    return '$count phút đọc';
  }

  @override
  String get learningDisclaimer =>
      'Chỉ mang tính giáo dục, không phải tư vấn tài chính chuyên nghiệp.';

  @override
  String get reportsByCategory => 'Chi tiêu theo danh mục';

  @override
  String get reportsTotalSpending => 'Tổng chi tiêu';

  @override
  String get reportsTrend => 'Thu và chi 6 tháng';

  @override
  String reportsTrendSummary(String month, String income, String spending) {
    return '$month: thu $income · chi $spending';
  }

  @override
  String get reportsTop => 'Tiêu nhiều nhất';

  @override
  String get reportsNoData => 'Chưa đủ dữ liệu';

  @override
  String reportsNoDataBody(String month) {
    return '$month chưa có giao dịch nào. Ghi vài khoản chi để Penny vẽ biểu đồ cho bạn nhé.';
  }

  @override
  String reportsSeeMonth(String month) {
    return 'Xem báo cáo $month';
  }

  @override
  String get reportsNoSpending =>
      'Tháng này chưa có khoản chi tiêu. Khoản góp tiết kiệm không tính là chi tiêu.';

  @override
  String get inboxTitleBudgetWarning => 'Sắp chạm hạn mức';

  @override
  String get inboxTitleBudgetExceeded => 'Vượt ngân sách';

  @override
  String get inboxTitleGoalMilestone => 'Cột mốc mới';

  @override
  String get inboxTitleGoalCompleted => 'Hoàn thành mục tiêu';

  @override
  String get inboxTitleSupportReplied => 'Hỗ trợ đã trả lời';

  @override
  String inboxBudgetWarning(int percent, String category) {
    return 'Bạn đã dùng $percent% ngân sách $category.';
  }

  @override
  String inboxBudgetExceeded(String category, String amount) {
    return 'Bạn đã vượt ngân sách $category $amount.';
  }

  @override
  String inboxGoalMilestone(String goal, int percent) {
    return '“$goal” đã đạt $percent%! Cố lên nhé.';
  }

  @override
  String inboxGoalCompleted(String goal) {
    return 'Bạn đã hoàn thành “$goal”! 🎉';
  }

  @override
  String inboxSupportReplied(String subject) {
    return 'Bộ phận hỗ trợ đã trả lời “$subject”.';
  }

  @override
  String get inboxMonthly => 'tháng';

  @override
  String inboxUnread(int count) {
    return '$count chưa đọc';
  }

  @override
  String get inboxMarkAllRead => 'Đánh dấu tất cả đã đọc';

  @override
  String get inboxEmpty =>
      'Chưa có thông báo nào. Penny sẽ báo về ngân sách, mục tiêu và phản hồi hỗ trợ tại đây.';

  @override
  String get inboxJustNow => 'Vừa xong';

  @override
  String inboxMinutesAgo(int count) {
    return '$count phút trước';
  }

  @override
  String inboxHoursAgo(int count) {
    return '$count giờ trước';
  }

  @override
  String get categoryExpenseTab => 'Khoản chi';

  @override
  String get categoryIncomeTab => 'Khoản thu';

  @override
  String get categoryMine => 'Của tôi';

  @override
  String get categoryDefault => 'Mặc định';

  @override
  String get categoryNoCustom => 'Chưa có danh mục riêng. Bấm + để thêm.';

  @override
  String get categoryNotUsed => 'Chưa dùng';

  @override
  String categoryUsage(int transactions, int budgets) {
    return '$transactions giao dịch · $budgets ngân sách';
  }

  @override
  String get categorySavingsNote =>
      '“Tiết kiệm” chỉ được tạo tự động khi bạn góp tiền vào mục tiêu.';

  @override
  String get categoryAdd => 'Thêm danh mục';

  @override
  String get categoryEdit => 'Sửa danh mục';

  @override
  String get categoryName => 'Tên danh mục';

  @override
  String get categoryNameHelp => '2–30 ký tự, không trùng danh mục cùng loại';

  @override
  String get categoryNameLength => 'Tên phải có 2–30 ký tự';

  @override
  String get categoryNameExists => 'Tên đã tồn tại';

  @override
  String get categoryType => 'Loại';

  @override
  String get categoryTypeLocked =>
      'Danh mục đã có giao dịch nên không đổi được loại.';

  @override
  String get categoryIcon => 'Biểu tượng';

  @override
  String get categorySave => 'Lưu danh mục';

  @override
  String get categorySaved => 'Đã lưu danh mục';

  @override
  String categoryDeleteTitle(String name) {
    return 'Xoá “$name”?';
  }

  @override
  String get categoryDeleteBody =>
      'Danh mục chưa được dùng nên không ảnh hưởng gì khác.';

  @override
  String categoryInUse(int transactions, int budgets) {
    return 'Danh mục đang được dùng cho $transactions giao dịch và $budgets ngân sách nên không xoá được.';
  }

  @override
  String get categoryDeleted => 'Đã xoá danh mục';

  @override
  String get chatSubtitle => 'Trả lời từ dữ liệu của bạn';

  @override
  String get chatHint => 'Hỏi Penny về chi tiêu của bạn…';

  @override
  String get chatSend => 'Gửi';

  @override
  String get chatDisclaimer =>
      'Chỉ mang tính giáo dục, không phải tư vấn tài chính chuyên nghiệp.';

  @override
  String get chatChipTop => 'Tháng này tiêu nhiều nhất vào gì?';

  @override
  String get chatChipBudget => 'Ngân sách còn bao nhiêu?';

  @override
  String get chatChipGoal => 'Mục tiêu tiết kiệm tới đâu rồi?';

  @override
  String get chatChipSave => 'Làm sao để tiết kiệm?';

  @override
  String chatWelcome(String name) {
    return 'Chào $name! Mình là Penny. Hỏi mình về chi tiêu, ngân sách hay mục tiêu của bạn nhé.';
  }

  @override
  String get chatHelp =>
      'Mình có thể cho bạn biết tháng này tiền đi đâu, ngân sách còn bao nhiêu, mục tiêu tới đâu và so sánh với tháng trước. Mình cũng chia sẻ mẹo lập ngân sách và tiết kiệm đơn giản.';

  @override
  String chatTopSpending(
      String month, String category, String amount, String percent) {
    return '$month bạn chi nhiều nhất cho $category: $amount, chiếm $percent chi tiêu.';
  }

  @override
  String get chatTopTip =>
      'Mẹo: đặt ngân sách cho danh mục tốn nhất là cách dễ nhất để kiểm soát nó.';

  @override
  String chatNoSpending(String month) {
    return '$month chưa có khoản chi nào. Thêm một khoản chi rồi hỏi lại mình nhé.';
  }

  @override
  String chatPercentOfLimit(int percent) {
    return '$percent% hạn mức';
  }

  @override
  String chatMonthSummary(
      String month, String income, String spending, String savings) {
    return '$month bạn thu $income, chi tiêu $spending và tiết kiệm $savings.';
  }

  @override
  String get chatTotalBudgetName => 'tổng';

  @override
  String chatBudgetLeft(
      String name, String month, String left, String limit, int percent) {
    return 'Ngân sách $name $month: còn $left trên $limit (đã dùng $percent%).';
  }

  @override
  String chatBudgetOver(String name, String month, String amount, int percent) {
    return 'Ngân sách $name $month đã vượt $amount (đã dùng $percent%).';
  }

  @override
  String chatNoBudget(String name, String month) {
    return 'Bạn chưa có ngân sách $name cho $month. Tạo trong tab Ngân sách để mình theo dõi giúp nhé.';
  }

  @override
  String chatGoalProgress(
      String goal, String current, String target, int percent, String pace) {
    return '“$goal”: $current trên $target ($percent%). $pace';
  }

  @override
  String chatPaceOnTrack(String date) {
    return 'Bạn đang đúng tiến độ, dự kiến xong khoảng $date.';
  }

  @override
  String chatPaceBehind(String date, String due) {
    return 'Với tốc độ này bạn xong khoảng $date, trễ hơn hạn $due.';
  }

  @override
  String get chatPaceUnknown =>
      'Đặt số tiền góp mỗi tháng để mình ước tính khi nào xong nhé.';

  @override
  String get chatNoGoal =>
      'Bạn chưa có mục tiêu nào đang thực hiện. Tạo trong tab Mục tiêu và bắt đầu tiết kiệm nhé!';

  @override
  String chatCompareMore(String current, String last, String percent) {
    return 'Tháng này tới hôm nay bạn chi $current, cùng kỳ tháng trước $last: nhiều hơn $percent.';
  }

  @override
  String chatCompareLess(String current, String last, String percent) {
    return 'Tháng này tới hôm nay bạn chi $current, cùng kỳ tháng trước $last: ít hơn $percent. Tốt lắm!';
  }

  @override
  String chatCompareNoLast(String current) {
    return 'Cùng kỳ tháng trước chưa có khoản chi nào để so sánh. Tháng này tới hôm nay bạn chi $current.';
  }

  @override
  String chatCompareSame(String current) {
    return 'Tháng này tới hôm nay bạn chi $current, bằng đúng cùng kỳ tháng trước.';
  }

  @override
  String get chatBudgetingTips =>
      'Thử quy tắc 50/30/20: 50% cho thiết yếu, 30% cho mong muốn, 20% cho tiết kiệm. Đặt ngân sách tổng cho tháng rồi thêm ngân sách cho các danh mục bạn tiêu nhiều nhất.';

  @override
  String get chatSavingTips =>
      'Để dành một phần cố định, ví dụ 10%, ngay ngày nhận tiền, trước khi tiêu. Đặt tên cho khoản tiết kiệm bằng cách tạo mục tiêu, và chờ 24 giờ trước khi mua thứ không cần thiết.';

  @override
  String get chatNeedsWants =>
      'Thiết yếu là thứ phải trả để sống và học: ăn uống, tiền nhà, đi lại, giáo trình. Mong muốn làm cuộc sống vui hơn nhưng có thể chờ. Hãy tự hỏi: nếu không mua thì sao?';

  @override
  String get chatUnknown =>
      'Mình chưa hiểu câu này. Bạn thử hỏi một trong các câu sau nhé:';

  @override
  String get chatDataLoading =>
      'Mình đang tải dữ liệu của bạn. Bạn hỏi lại sau giây lát nhé.';

  @override
  String get chatDataFailed =>
      'Mình chưa tải được dữ liệu của bạn nên chưa trả lời bằng số liệu được. Bạn vẫn có thể hỏi mẹo lập ngân sách hoặc tiết kiệm nhé.';

  @override
  String chatCategorySpending(
      String month, String amount, String category, String percent) {
    return '$month bạn đã chi $amount cho $category, chiếm $percent chi tiêu.';
  }

  @override
  String chatOnlyThisMonth(String month) {
    return 'Mình chỉ trả lời được số liệu $month. Muốn xem tháng khác, bạn mở mục Báo cáo nhé.';
  }

  @override
  String get reportsTypeSpending => 'Chi tiêu';

  @override
  String get reportsTypeIncome => 'Thu nhập';

  @override
  String get reportsIncomeByCategory => 'Thu nhập theo nguồn';

  @override
  String get reportsTotalIncome => 'Tổng thu';

  @override
  String get reportsTopIncome => 'Nguồn thu lớn nhất';

  @override
  String get reportsNoIncome => 'Tháng này chưa có khoản thu.';

  @override
  String get reportsBalance => 'Cân bằng thu – chi';

  @override
  String get reportsBudgetTitle => 'So sánh ngân sách';

  @override
  String get reportsNoBudget => 'Tháng này chưa đặt ngân sách.';

  @override
  String reportsBudgetUsed(String spent, String limit, int percent) {
    return '$spent / $limit · $percent%';
  }
}
