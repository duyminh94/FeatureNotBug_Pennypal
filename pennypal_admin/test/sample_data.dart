import 'package:pennypal_admin/models/admin_data.dart';
import 'package:pennypal_admin/models/app_settings.dart';
import 'package:pennypal_admin/models/feedback_entry.dart';
import 'package:pennypal_admin/models/support_query.dart';
import 'package:pennypal_admin/models/transaction_record.dart';
import 'package:pennypal_admin/models/user_profile.dart';
import 'package:pennypal_admin/utils/constants.dart';
import 'sample_lessons.dart';

class SampleData {
  static const String adminEmail = 'admin@pennypal.app';

  static AdminData adminData() {
    final DateTime now = DateTime.now();
    final List<UserProfile> users = _users(now);
    return AdminData(
      users: users,
      transactionsByUser: _transactions(users, now),
      supportByUser: _support(now),
      goalCountByUser: const {'u_minhan': 2, 'u_thuha': 1, 'u_quang': 3, 'u_ngoc': 1, 'u_khoa': 1, 'u_lan': 2},
      feedbacks: _feedbacks(now),
      lessons: SampleLessons.all(),
      settings: AppSettings(
        supportEmail: 'support@pennypal.app',
        announcementEn: 'Financial literacy week! 3 new budgeting lessons in the Learning corner.',
        announcementVi: 'Tuần lễ tài chính! 3 bài học mới về lập ngân sách trong Góc học tập.',
        announcementActive: true,
      ),
    );
  }

  static List<UserProfile> _users(DateTime now) {
    int monthsAgo(int months, int day) => DateTime(now.year, now.month - months, day, 9).millisecondsSinceEpoch;
    int hoursAgo(int hours) => now.subtract(Duration(hours: hours)).millisecondsSinceEpoch;

    UserProfile student(String uid, String name, String email, String mobile, int created, int lastLogin,
        {bool isActive = true, String status = StudentStatuses.undergraduate}) {
      return UserProfile(
        uid: uid,
        fullName: name,
        email: email,
        mobileNumber: mobile,
        studentStatus: status,
        createdAt: created,
        lastLogin: lastLogin,
        isActive: isActive,
      );
    }

    return [
      UserProfile(
        uid: 'admin_1',
        fullName: 'Admin',
        email: adminEmail,
        mobileNumber: '0900000000',
        role: UserRoles.admin,
        createdAt: monthsAgo(6, 1),
        lastLogin: hoursAgo(1),
      ),
      student('u_minhan', 'Nguyen Minh An', 'minhan@student.edu.vn', '0912345678', monthsAgo(5, 3), hoursAgo(2)),
      student('u_thuha', 'Le Thu Ha', 'thuha.le@gmail.com', '0987111222', monthsAgo(4, 12), hoursAgo(5)),
      student('u_nghia', 'Le Minh Nghia', 'nghia.lm@gmail.com', '0977333444', monthsAgo(4, 20), hoursAgo(400), isActive: false),
      student('u_quang', 'Pham Duc Quang', 'quang.pd@fpt.edu.vn', '0966555666', monthsAgo(3, 8), hoursAgo(26)),
      student('u_ngoc', 'Tran Bao Ngoc', 'ngoc.tb@student.edu.vn', '0955777888', monthsAgo(2, 15), hoursAgo(30)),
      student('u_binh', 'Tran Quoc Binh', 'binh.tq@student.edu.vn', '0944999000', monthsAgo(2, 22), hoursAgo(72)),
      student('u_khoa', 'Nguyen Van Khoa', 'khoa.nv@gmail.com', '0933121212', monthsAgo(1, 5), hoursAgo(12)),
      student('u_hong', 'Do Thu Hong', 'hong.dt@fpt.edu.vn', '0922343434', monthsAgo(1, 18), hoursAgo(48), status: StudentStatuses.postgraduate),
      student('u_lan', 'Hoang Thi Lan', 'lan.ht@student.edu.vn', '0911565656', monthsAgo(0, 2), hoursAgo(3)),
      student('u_son', 'Vu Thanh Son', 'son.vt@gmail.com', '0908787878', monthsAgo(0, 4), hoursAgo(20), status: StudentStatuses.highSchool),
    ];
  }

  static Map<String, List<TransactionRecord>> _transactions(List<UserProfile> users, DateTime now) {
    const List<String> expenseCategories = [
      CategoryKeys.food,
      CategoryKeys.transport,
      CategoryKeys.entertainment,
      CategoryKeys.shopping,
      CategoryKeys.education,
      CategoryKeys.bills,
    ];
    final Map<String, List<TransactionRecord>> result = {};

    for (int userIndex = 0; userIndex < users.length; userIndex++) {
      final UserProfile user = users[userIndex];
      if (user.role != UserRoles.student) continue;
      final DateTime created = DateTime.fromMillisecondsSinceEpoch(user.createdAt ?? 0);
      final List<TransactionRecord> records = [];

      for (int back = 0; back < 6; back++) {
        final DateTime month = DateTime(now.year, now.month - back);
        if (month.isBefore(DateTime(created.year, created.month))) continue;
        final int day = back == 0 ? 1 : 10;
        int dateOf(int hour) => DateTime(month.year, month.month, day, hour).millisecondsSinceEpoch;

        records.add(TransactionRecord(
          id: '${user.uid}_${back}_income',
          type: TransactionTypes.income,
          amount: 2500000 + userIndex * 100000,
          categoryId: CategoryKeys.allowance,
          date: dateOf(8),
        ));
        for (int item = 0; item < 3; item++) {
          records.add(TransactionRecord(
            id: '${user.uid}_${back}_expense_$item',
            type: TransactionTypes.expense,
            amount: 150000 + (userIndex + item) * 50000,
            categoryId: expenseCategories[(userIndex + item) % expenseCategories.length],
            date: dateOf(12 + item),
          ));
        }
        if (userIndex.isEven) {
          records.add(TransactionRecord(
            id: '${user.uid}_${back}_custom',
            type: TransactionTypes.expense,
            amount: 200000,
            categoryId: 'cat_gym',
            date: dateOf(18),
          ));
          records.add(TransactionRecord(
            id: '${user.uid}_${back}_savings',
            type: TransactionTypes.expense,
            amount: 300000,
            categoryId: CategoryKeys.savings,
            date: dateOf(19),
            goalId: 'goal_${user.uid}',
          ));
        }
      }
      result[user.uid] = records;
    }
    return result;
  }

  static Map<String, List<SupportQuery>> _support(DateTime now) {
    int hoursAgo(int hours) => now.subtract(Duration(hours: hours)).millisecondsSinceEpoch;

    return {
      'u_minhan': [
        SupportQuery(
          id: 'sq_export',
          userEmail: 'minhan@student.edu.vn',
          subject: 'Want to export report to Excel',
          message: 'Can I export my monthly report to an Excel file to share with my parents?',
          submittedAt: hoursAgo(2),
        ),
        SupportQuery(
          id: 'sq_currency',
          userEmail: 'minhan@student.edu.vn',
          subject: 'Currency does not change',
          message: 'I switched to USD in Settings but my old amounts look the same.',
          status: SupportStatuses.resolved,
          adminResponse: 'Hi An, changing the currency only changes how amounts are shown. Your saved numbers stay the same.',
          submittedAt: hoursAgo(120),
          respondedAt: hoursAgo(100),
          studentNotified: true,
        ),
      ],
      'u_thuha': [
        SupportQuery(
          id: 'sq_alert',
          userEmail: 'thuha.le@gmail.com',
          subject: 'Budget alert not showing',
          message: 'I set a food budget with an 80% alert but did not get any notification.',
          submittedAt: hoursAgo(5),
        ),
      ],
      'u_quang': [
        SupportQuery(
          id: 'sq_category',
          userEmail: 'quang.pd@fpt.edu.vn',
          subject: 'How to delete a category?',
          message: 'I created a category by mistake. How can I remove it without losing my transactions?',
          submittedAt: hoursAgo(26),
        ),
      ],
      'u_ngoc': [
        SupportQuery(
          id: 'sq_scan',
          userEmail: 'ngoc.tb@student.edu.vn',
          subject: 'Scan receipt reads wrong total',
          message: 'The receipt scan picked the phone number instead of the total amount.',
          submittedAt: hoursAgo(40),
        ),
        SupportQuery(
          id: 'sq_password',
          userEmail: 'ngoc.tb@student.edu.vn',
          subject: 'Forgot password email',
          message: 'I did not receive the reset password email.',
          status: SupportStatuses.resolved,
          adminResponse: 'Please check your spam folder. The email comes from noreply@pennypal.app.',
          submittedAt: hoursAgo(200),
          respondedAt: hoursAgo(190),
          studentNotified: true,
        ),
      ],
    };
  }

  static List<FeedbackEntry> _feedbacks(DateTime now) {
    int daysAgo(int days) => now.subtract(Duration(days: days)).millisecondsSinceEpoch;

    return [
      FeedbackEntry(id: 'fb1', userId: 'u_minhan', name: 'Nguyen Minh An', email: 'minhan@student.edu.vn', rating: 5, comments: 'I love the receipt scan!', submittedAt: daysAgo(1)),
      FeedbackEntry(id: 'fb2', userId: 'u_thuha', name: 'Le Thu Ha', email: 'thuha.le@gmail.com', rating: 4, comments: 'Please add weekly charts.', submittedAt: daysAgo(3)),
      FeedbackEntry(id: 'fb3', userId: 'u_quang', name: 'Pham Duc Quang', email: 'quang.pd@fpt.edu.vn', rating: 5, comments: 'Penny chatbot is fun and useful.', submittedAt: daysAgo(6)),
      FeedbackEntry(id: 'fb4', userId: 'u_ngoc', name: 'Tran Bao Ngoc', email: 'ngoc.tb@student.edu.vn', rating: 3, comments: 'Scan sometimes reads the wrong total.', submittedAt: daysAgo(9)),
      FeedbackEntry(id: 'fb5', userId: 'u_khoa', name: 'Nguyen Van Khoa', email: 'khoa.nv@gmail.com', rating: 4, submittedAt: daysAgo(12)),
      FeedbackEntry(id: 'fb6', userId: 'u_lan', name: 'Hoang Thi Lan', email: 'lan.ht@student.edu.vn', rating: 5, comments: 'Goals keep me motivated.', submittedAt: daysAgo(15)),
    ];
  }
}
