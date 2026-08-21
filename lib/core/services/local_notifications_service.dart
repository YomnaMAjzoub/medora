import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notification display layer on top of FCM.
///
/// Foreground pushes are not shown by the system on Android/iOS by default,
/// so this service renders them as a local notification banner. Background
/// data-only messages are rendered here too (from the background isolate).
/// Tapping any locally-displayed notification calls [onTap] with the JSON
/// payload so the app can route to the right screen.
class LocalNotificationsService {
  LocalNotificationsService._();

  static const String channelId = 'medora_notifications';
  static const String channelName = 'Medora Notifications';
  static const String channelDescription =
      'Appointment reminders and clinic updates';

  static FlutterLocalNotificationsPlugin? _plugin;

  static FlutterLocalNotificationsPlugin get _instance =>
      _plugin ??= FlutterLocalNotificationsPlugin();

  /// Wires the plugin for the main isolate. [onTap] receives the JSON-encoded
  /// data payload attached to the notification that was tapped.
  static Future<void> init({
    void Function(Map<String, dynamic> data)? onTap,
  }) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _instance.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          onTap?.call(data);
        } catch (_) {
          // Malformed payload; nothing to route.
        }
      },
    );
    await _createChannel();
  }

  /// Standalone setup used inside the background isolate handler, where the
  /// main-isolate singleton state is not shared.
  static Future<void> initForBackgroundIsolate() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _instance.initialize(settings: settings);
    await _createChannel();
  }

  static Future<void> _createChannel() async {
    if (!_isMobile) return;
    try {
      await _instance
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              channelName,
              description: channelDescription,
              importance: Importance.high,
            ),
          );
    } catch (_) {
      // Channel creation is best-effort; notifications still fall back to
      // the default channel.
    }
  }

  /// Shows a notification banner. [payload] is the JSON-encoded data map so a
  /// later tap can be routed back to the correct screen.
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isMobile) return;
    await _createChannel();
    try {
      await _instance.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (_) {
      // Best-effort: the push may still be delivered by the system.
    }
  }

  static bool get _isMobile {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Stable notification id derived from the message data, so a repeated
  /// notification for the same entity replaces the previous one instead of
  /// stacking banners.
  static int idFor(Map<String, dynamic> data) {
    final raw = data['appointment_id'] ??
        data['appointmentId'] ??
        data['id'] ??
        data['type'] ??
        'general';
    return raw.hashCode & 0x7fffffff;
  }
}