import 'package:flutter_test/flutter_test.dart';
import 'package:pennypal_admin/controllers/admin_data_service.dart';
import 'package:pennypal_admin/controllers/feedback_service.dart';
import 'package:pennypal_admin/controllers/learning_service.dart';
import 'package:pennypal_admin/controllers/support_service.dart';
import 'package:pennypal_admin/controllers/user_service.dart';

void main() {
  test('a transaction with amount "abc" is skipped, the others still load', () {
    final result = AdminDataService.transactionsByUserFromValue({
      'student1': {
        'good': {'type': 'expense', 'amount': 50000, 'categoryId': 'food', 'date': 1758000000000},
        'bad': {'type': 'expense', 'amount': 'abc', 'categoryId': 'food', 'date': 1758000000000},
      },
    });

    expect(result['student1']!.length, 1);
    expect(result['student1']!.single.id, 'good');
  });

  test('a feedback with rating 4.5 is skipped', () {
    final feedbacks = FeedbackService.listFromValue({
      'good': {'userId': 'student1', 'rating': 5, 'comments': 'Nice'},
      'bad': {'userId': 'student1', 'rating': 4.5, 'comments': 'Half star'},
    });

    expect(feedbacks.map((feedback) => feedback.id), ['good']);
  });

  test('a user with isActive "yes" is skipped', () {
    final users = UserService.listFromValue({
      'good': {'fullName': 'Minh', 'role': 'student', 'isActive': true},
      'bad': {'fullName': 'Broken', 'role': 'student', 'isActive': 'yes'},
    });

    expect(users.map((user) => user.uid), ['good']);
  });

  test('a support query with a number as subject is skipped', () {
    final result = SupportService.byUserFromValue({
      'student1': {
        'good': {'subject': 'Help', 'message': 'Hi', 'status': 'open'},
        'bad': {'subject': 123, 'message': 'Hi', 'status': 'open'},
      },
    });

    expect(result['student1']!.map((query) => query.id), ['good']);
  });

  test('a lesson with isActive 1 is skipped', () {
    final lessons = LearningService.listFromValue({
      'good': {'title_en': 'Budget', 'isActive': true},
      'bad': {'title_en': 'Broken', 'isActive': 1},
    });

    expect(lessons.map((lesson) => lesson.id), ['good']);
  });
}
