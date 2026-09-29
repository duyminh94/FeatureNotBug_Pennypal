import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService {
  static const String _askedKey = 'notificationPermissionAsked';
  static const String _channelId = 'pennypal_alerts';
  static const String _channelName = 'Budget and goal alerts';

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _isReady = false;

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      const InitializationSettings settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _plugin.initialize(settings);
      _isReady = true;
    } catch (e) {
      debugPrint('PushNotificationService.init failed: $e');
    }
  }

  static Future<void> requestPermission() async {
    if (kIsWeb) return;
    try {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();

      final IOSFlutterLocalNotificationsPlugin? ios =
          _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('PushNotificationService.requestPermission failed: $e');
    }
    await markAsked();
  }

  static Future<void> markAsked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_askedKey, true);
    } catch (e) {
      debugPrint('PushNotificationService.markAsked failed: $e');
    }
  }

  static Future<void> requestPermissionIfNeverAsked() async {
    if (kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool wasAsked = prefs.getBool(_askedKey) ?? false;
      if (!wasAsked) await requestPermission();
    } catch (e) {
      debugPrint('PushNotificationService.requestPermissionIfNeverAsked failed: $e');
    }
  }

  static Future<void> show(String notificationId, String title, String body) async {
    if (kIsWeb || !_isReady) return;
    try {
      const NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      );
      final int numberId = notificationId.hashCode & 0x7fffffff;
      await _plugin.show(numberId, title, body, details);
    } catch (e) {
      debugPrint('PushNotificationService.show failed: $e');
    }
  }
}
