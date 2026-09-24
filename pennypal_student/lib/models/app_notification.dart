import '../utils/constants.dart';

/// An in-app notification, stored at notifications/{uid}/{notificationId}.
class AppNotification {
  final String id;
  final String type;
  final Map<String, dynamic> params;
  final bool isRead;
  final int? createdAt;

  AppNotification({
    required this.id,
    required this.type,
    this.params = const {},
    this.isRead = false,
    this.createdAt,
  });

  /// Builds a notification from the map read at notifications/{uid}/{notificationId}.
  factory AppNotification.fromMap(String id, Map<dynamic, dynamic> map) {
    final Map<dynamic, dynamic> rawParams = map[DbFields.params] ?? {};
    return AppNotification(
      id: id,
      type: map[DbFields.type] ?? '',
      params: Map<String, dynamic>.from(rawParams),
      isRead: map[DbFields.isRead] ?? false,
      createdAt: map[DbFields.createdAt],
    );
  }

  /// Converts the notification to a map for writing.
  Map<String, dynamic> toMap() {
    return {
      DbFields.type: type,
      DbFields.params: params,
      DbFields.isRead: isRead,
      DbFields.createdAt: createdAt,
    };
  }
}
