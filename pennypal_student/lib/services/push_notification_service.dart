import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shows phone (system) notifications for budget alerts and goal milestones on Android / iOS.
///
/// The Web has no local notifications (business.md A-13): every function does nothing there,
/// and the student still sees the bell badge and the Notifications screen.
class PushNotificationService {
  static const String _askedKey = 'notificationPermissionAsked';
  static const String _channelId = 'pennypal_alerts';
  static const String _channelName = 'Budget and goal alerts';

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _isReady = false;

  /// Called once in main(). Permission is not asked here: the student is asked on the S01 screen.
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

  /// Shows the system permission dialog (Android 13+ and iOS) and remembers that the student was asked.
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

  /// Saves that the permission question was already shown (also when the student pressed "Later").
  static Future<void> markAsked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_askedKey, true);
    } catch (e) {
      debugPrint('PushNotificationService.markAsked failed: $e');
    }
  }

  /// For students who signed in with an old account and never saw the S01 screen.
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

  /// Shows one notification. [notificationId] is the fixed id from NotificationBuilder.
  /// If permission was refused, Android / iOS simply do not show it; nothing breaks.
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
      // The plugin needs a number id; the same text id always gives the same number during a run.
      final int numberId = notificationId.hashCode & 0x7fffffff;
      await _plugin.show(numberId, title, body, details);
    } catch (e) {
      debugPrint('PushNotificationService.show failed: $e');
    }
  }
}
