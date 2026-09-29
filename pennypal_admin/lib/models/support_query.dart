import '../utils/constants.dart';

class SupportQuery {
  final String id;
  final String userEmail;
  final String subject;
  final String message;
  final String status;
  final String? adminResponse;
  final int? submittedAt;
  final int? respondedAt;
  final bool studentNotified;

  SupportQuery({
    required this.id,
    required this.userEmail,
    required this.subject,
    required this.message,
    this.status = SupportStatuses.open,
    this.adminResponse,
    this.submittedAt,
    this.respondedAt,
    this.studentNotified = false,
  });

  factory SupportQuery.fromMap(String id, Map<dynamic, dynamic> map) {
    return SupportQuery(
      id: id,
      userEmail: map[DbFields.userEmail] ?? '',
      subject: map[DbFields.subject] ?? '',
      message: map[DbFields.message] ?? '',
      status: map[DbFields.status] ?? SupportStatuses.open,
      adminResponse: map[DbFields.adminResponse],
      submittedAt: map[DbFields.submittedAt],
      respondedAt: map[DbFields.respondedAt],
      studentNotified: map[DbFields.studentNotified] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DbFields.userEmail: userEmail,
      DbFields.subject: subject,
      DbFields.message: message,
      DbFields.status: status,
      DbFields.adminResponse: adminResponse,
      DbFields.submittedAt: submittedAt,
      DbFields.respondedAt: respondedAt,
      DbFields.studentNotified: studentNotified,
    };
  }

  bool get isResolved => status == SupportStatuses.resolved;
}
