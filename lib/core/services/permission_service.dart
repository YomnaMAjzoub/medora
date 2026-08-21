import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide Trans;

/// Startup permission handling.
///
/// Runs early in the app lifecycle (splash) and covers the two checks that
/// matter for the booking flows:
///  - Location *services* (the device GPS toggle) -- when turned off the
///    user is prompted and redirected to the system location settings.
///  - Notification permission -- the system prompt is raised on both
///    Android 13+ (POST_NOTIFICATIONS) and iOS, so FCM/local banners can
///    be delivered.
class PermissionService {
  PermissionService._();

  static bool _locationPromptShown = false;

  static bool get _isMobile {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Checks that the device location services (GPS toggle) are switched on.
  /// When they are off, shows a dialog that redirects the user to the
  /// system location settings. Only prompts once per app session to avoid
  /// nagging, and never blocks the app.
  static Future<void> ensureLocationServicesEnabled() async {
    if (!_isMobile || _locationPromptShown) return;
    try {
      if (await Geolocator.isLocationServiceEnabled()) return;
      _locationPromptShown = true;

      await Get.dialog(
        AlertDialog(
          title: Text('location_services_title'.tr()),
          content: Text('location_services_body'.tr()),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('not_now'.tr()),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Geolocator.openLocationSettings();
              },
              child: Text('enable_location_services'.tr()),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    } catch (_) {
      // Best-effort: the in-flow map picker still surfaces its own message.
    }
  }

  /// Raises the system notification permission prompt when it has not been
  /// granted yet. Android 13+ uses the POST_NOTIFICATIONS runtime
  /// permission; iOS uses the FCM permission request (a no-op when already
  /// granted).
  static Future<void> requestNotificationPermission() async {
    if (!_isMobile) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await FlutterLocalNotificationsPlugin()
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      }
    } catch (_) {
      // Firebase/plugin not available yet; FCM init re-requests on iOS.
    }
  }
}