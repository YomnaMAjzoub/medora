import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Wraps Firebase init + FCM token handling + anonymous sign-in.
/// Fails silently when the Firebase config files are missing
/// (google-services.json), so the app still starts.
class FirebaseService extends GetxService {
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

      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await GetStorage().write('fcm_token', token);
      }

      FirebaseMessaging.onMessage.listen((message) {
        Get.snackbar(
          message.notification?.title ?? 'Notification',
          message.notification?.body ?? '',
        );
      });
    } catch (e) {
      // Firebase config files not present yet; notifications stay disabled.
    }
  }
}
