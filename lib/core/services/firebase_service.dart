import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/auth/data/src/auth_service.dart';

/// Background isolate handler -- must be a top-level function. Runs when the
/// app is terminated (or in the background without the engine active) and a
/// push notification arrives.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The engine/plugins are not available here; only persist what matters
  // so the foreground side can react when the app is opened again.
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

  static Future<void> init() async {
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

      // Foreground: show a snackbar while the app is visible.
      FirebaseMessaging.onMessage.listen((message) {
        Get.snackbar(
          message.notification?.title ?? 'Notification',
          message.notification?.body ?? '',
        );
      });

      // Tapped while the app is in the background: open the chat inbox.
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleNotificationTap();
      });

      // Tapped from a terminated state.
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        // Delay until the router is mounted; splash is still on screen.
        Future.delayed(const Duration(seconds: 2), _handleNotificationTap);
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

  static void _handleNotificationTap() {
    // Guard: only navigate once the app shell is up.
    final storage = GetStorage();
    final hasToken = storage.read<String>('access_token')?.isNotEmpty ?? false;
    if (!hasToken) return;
    try {
      Get.toNamed(AppRouter.conversations);
    } catch (_) {
      // Route not ready yet -- the inbox screen handles its own state.
    }
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