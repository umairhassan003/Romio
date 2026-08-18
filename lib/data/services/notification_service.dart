import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around [FlutterLocalNotificationsPlugin] for the device-level
/// notifications Romio raises (currently booking confirmations). The in-app
/// notification list is handled separately by `NotificationsProvider`; this
/// class only pops the system banner.
///
/// All methods swallow their own errors: a notification failure must never
/// affect a booking result or crash the app.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'booking_confirmations';
  static const String _channelName = 'Booking confirmations';
  static const String _channelDescription =
      'Notifications about your Romio room bookings.';

  bool _initialized = false;

  /// Initializes the plugin and requests permission. Safe to call more than
  /// once; the work only runs the first time.
  Future<void> init() async {
    if (_initialized) return;
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );

      // Android 13+ requires an explicit runtime permission request.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.init failed: $e');
    }
  }

  /// Shows a system notification. [title] and [body] must already be localized
  /// by the caller in the user's selected language.
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      if (!_initialized) await init();
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          // No explicit icon: falls back to the default set in init()
          // (@mipmap/ic_launcher — the Romio app icon).
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.show(id, title, body, details);
    } catch (e) {
      debugPrint('NotificationService.show failed: $e');
    }
  }
}
