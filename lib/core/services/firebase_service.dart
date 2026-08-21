import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/services/local_notifications_service.dart';
import 'package:medora_git/core/services/notification_router.dart';
import 'package:medora_git/features/auth/data/src/auth_service.dart';
import 'package:medora_git/features/notifications/business_layer/controller/notifications_controller.dart';

/// Background isolate handler -- must be a top-level function. Runs when the
/// app is in the background (or terminated) and a data-only push arrives.
/// Shows a local notification banner (the engine has no UI in this isolate)
/// and persists the payload so the foreground side can react on next open.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await LocalNotificationsService.initForBackgroundIsolate();
  final payload = PushNotificationPayload.fromMessage(message);
  await LocalNotificationsService.show(
    id: LocalNotificationsService.idFor(message.data),
    title: message.notification?.title ?? payload.title ?? 'Medora',
    body: message.notification?.body ?? payload.body ?? '',
    payload: message.data.isEmpty ? null : payload.encode(),
  );

  final box = GetStorage();
  if (message.data.isNotEmpty) {
    await box.write('last_notification', message.data);
  }
}

/// Wraps Firebase init + FCM token handling + anonymous sign-in.
/// Fails silently when the Firebase config files are missing
/// (google-services.json), so the app still starts.
class FirebaseService extends GetxService {
  /// Registers the background isolate handler. Call from `main()` before
  /// `runApp` so terminated-state notifications are delivered reliably.
  static Future<void> registerBackgroundHandler() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (_) {
      // Firebase not configured yet; nothing to register.
    }
  }

  static Future<void>? _initFuture;

  /// Idempotent: repeated calls return the already-running initialisation,
  /// so the splash can await it before raising permission prompts.
  static Future<void> init() => _initFuture ??= _doInit();

  static Future<void> _doInit() async {
    try {
      await Firebase.initializeApp();

      // Authenticates Firestore requests so security rules using
      // `request.auth != null` work (chat collections).
      try {
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously();
        }
      } catch (e) {
        // Anonymous auth unavailable; chat stays functional under open rules.
      }

      // Local banner layer: renders foreground pushes and routes taps to the
      // right screen (role + type aware).
      await LocalNotificationsService.init(
        onTap: _handleLocalNotificationTap,
      );

      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      _createNotificationChannel();

      await _saveToken(messaging);

      // Tokens rotate (reinstall, expiry, app restore) -- refresh the saved
      // token so the next login/register sends the current one.
      messaging.onTokenRefresh.listen((token) => _saveToken(messaging));

      // Foreground: the system does not show pushes by default, so render
      // them through the local notification banner. The in-app notifications
      // list (bell icon / unread badge) is refreshed so it reflects the
      // event immediately.
      FirebaseMessaging.onMessage.listen((message) {
        final payload = PushNotificationPayload.fromMessage(message);
        LocalNotificationsService.show(
          id: LocalNotificationsService.idFor(message.data),
          title: message.notification?.title ?? payload.title ?? 'Medora',
          body: message.notification?.body ?? payload.body ?? '',
          payload: message.data.isEmpty ? null : payload.encode(),
        );
        if (Get.isRegistered<NotificationsController>()) {
          Get.find<NotificationsController>().fetchNotifications();
        }
      });

      // Tapped while the app is in the background: route by role + type.
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        NotificationRouter.route(
          payload: PushNotificationPayload.fromMessage(message),
        );
      });

      // Tapped from a terminated state.
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        // Wait until the splash redirect (3s) has built the app shell, then
        // route the tap to the correct screen.
        Future.delayed(const Duration(milliseconds: 3500), () {
          NotificationRouter.route(
            payload: PushNotificationPayload.fromMessage(initialMessage),
          );
        });
      }
    } catch (e) {
      // Firebase config files not present yet; notifications stay disabled.
    }
  }

  static Future<void> _saveToken(FirebaseMessaging messaging) async {
    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      final storage = GetStorage();
      await storage.write('fcm_token', token);
      log('FCM token saved: $token');

      // Push the rotated token to the backend (POST /updateFcmToken,
      // Sanctum Bearer auth). No-op when the user is not logged in; the
      // token is also attached to login/register as a fallback.
      AuthService().updateFcmToken(token);
    }
  }

  /// Guarantees a current FCM token is stored locally AND pushed to the
  /// backend (POST /updateFcmToken). Used right after a successful login
  /// (the splash-time init may not have produced a token yet on first run)
  /// and whenever the session must be re-registered. Best-effort: failures
  /// are logged, never thrown into the login flow.
  static Future<void> ensureFcmTokenSent() async {
    try {
      await init();
      final messaging = FirebaseMessaging.instance;
      var token = await messaging.getToken().timeout(
            const Duration(seconds: 10),
          );
      token ??= await messaging.getAPNSToken();
      if (token != null && token.isNotEmpty) {
        final storage = GetStorage();
        await storage.write('fcm_token', token);
        await AuthService().updateFcmToken(token);
        log('ensureFcmTokenSent: token delivered (${token.length} chars)');
      } else {
        log('ensureFcmTokenSent: no token available from Firebase');
      }
    } catch (e) {
      // Firebase not configured / offline: notifications stay disabled but
      // login must not break.
      log('ensureFcmTokenSent failed: $e');
    }
  }

  /// Taps on locally-displayed banners (foreground pushes, background
  /// data-only pushes) arrive here with the JSON data payload.
  static void _handleLocalNotificationTap(Map<String, dynamic> data) {
    NotificationRouter.route(
      payload: PushNotificationPayload.fromData(data),
    );
  }

  /// Android 8+ notifications need a channel; the firebase_messaging plugin
  /// creates the default one. Here we just request foreground presentation.
  static void _createNotificationChannel() {
    try {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {
      // Best-effort; notifications still arrive.
    }
  }
}