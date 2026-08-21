import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/notifications/business_layer/controller/notifications_controller.dart';

/// The kind of push a notification represents. Classified from the backend
/// `notification_type` value, which the Laravel source sends as:
/// `appointment_reminder`, `appointment_cancelled`, `payment_completed`,
/// `low_stock`, `item_restocked`.
enum PushNotificationKind {
  appointmentReminder,
  appointmentCancelled,
  payment,
  lowStock,
  itemRestocked,
  chatMessage,
  general,
}

/// Parsed FCM data payload.
///
/// The backend payload (verified against the Laravel source) uses:
///   notification_type: 'appointment_reminder' | 'appointment_cancelled' |
///                      'payment_completed' | 'low_stock'
///   appointment_id    : (string) the appointment id
///   action_required   : 'confirm_and_pay' on reminders
/// Older/alternative key names (`type`, `id`, `appointmentId`) are read
/// defensively so nothing breaks if the backend varies.
class PushNotificationPayload {
  const PushNotificationPayload({
    this.type,
    this.id,
    this.appointmentId,
    this.title,
    this.body,
    this.actionRequired,
  });

  final String? type;
  final String? id;
  final int? appointmentId;
  final String? title;
  final String? body;
  final String? actionRequired;

  factory PushNotificationPayload.fromData(Map<String, dynamic> data) {
    final type = (data['notification_type'] ?? data['type'] ?? data['kind'])
        ?.toString();
    final idRaw = data['id'] ?? data['entity_id'] ?? data['appointment_id'];
    final appointmentRaw = data['appointment_id'] ??
        data['appointmentId'] ??
        (type != null && type.contains('appointment') ? idRaw : null);
    return PushNotificationPayload(
      type: type,
      id: idRaw?.toString(),
      appointmentId: int.tryParse(appointmentRaw?.toString() ?? ''),
      title: data['title']?.toString() ?? data['notification_title']?.toString(),
      body: data['body']?.toString() ?? data['notification_body']?.toString(),
      actionRequired: data['action_required']?.toString(),
    );
  }

  factory PushNotificationPayload.fromMessage(RemoteMessage message) =>
      PushNotificationPayload.fromData(message.data);

  PushNotificationKind get kind {
    final raw = (type ?? '').toLowerCase();
    if (raw.contains('restock') || raw == 'item_restocked') {
      return PushNotificationKind.itemRestocked;
    }
    if (raw.contains('payment') || raw == 'paid' || raw == 'deposit') {
      return PushNotificationKind.payment;
    }
    if (raw.contains('reminder') || raw.contains('confirm')) {
      return PushNotificationKind.appointmentReminder;
    }
    if (raw.contains('cancelled') || raw.contains('cancel')) {
      return PushNotificationKind.appointmentCancelled;
    }
    if (raw.contains('low_stock') || raw.contains('stock')) {
      return PushNotificationKind.lowStock;
    }
    if (raw.contains('chat') || raw.contains('message')) {
      return PushNotificationKind.chatMessage;
    }
    return PushNotificationKind.general;
  }

  Map<String, dynamic> toData() => {
        if (type != null) 'notification_type': type,
        if (id != null) 'id': id,
        if (appointmentId != null) 'appointment_id': appointmentId,
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (actionRequired != null) 'action_required': actionRequired,
      };

  String encode() => jsonEncode(toData());
}

/// Decides where a notification tap should navigate, based on the logged-in
/// role and the notification kind. Called from the foreground, background and
/// terminated handlers.
class NotificationRouter {
  static const _lastHandledKey = 'last_notification_handled';

  /// Routes a tapped push to the appropriate screen for the current role.
  /// Returns true when a route was opened.
  static bool route({required PushNotificationPayload payload}) {
    final storage = GetStorage();
    final hasToken = storage.read<String>('access_token')?.isNotEmpty ?? false;
    if (!hasToken) return false;

    // Ignore duplicate taps of the same notification while the app is open.
    final signature = payload.toData().toString();
    if (Get.currentRoute != AppRouter.splash &&
        storage.read<String>(_lastHandledKey) == signature) {
      return true;
    }
    storage.write(_lastHandledKey, signature);

    // The tapped push is already stored server-side (GET /notifications);
    // refresh the in-app list so the unread badge stays accurate.
    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().fetchNotifications();
    }

    final role = storage.read<String>('role') ?? '';
    final appointmentId = payload.appointmentId;

    switch (role) {
      case 'doctor':
        return _routeDoctor(payload, appointmentId);
      case 'admin':
        return _routeAdmin(payload);
      default:
        return _routePatient(payload, appointmentId);
    }
  }

  static bool _routePatient(
    PushNotificationPayload payload,
    int? appointmentId,
  ) {
    switch (payload.kind) {
      case PushNotificationKind.appointmentReminder:
        // "confirm_and_pay" reminders open the confirmation screen so the
        // patient can keep the visit; anything else lands on the schedule.
        if (appointmentId != null) {
          Get.toNamed(
            AppRouter.reminderConfirm,
            arguments: {'appointment_id': appointmentId},
          );
        } else {
          _openPatientTab(2);
        }
        return true;
      case PushNotificationKind.appointmentCancelled:
      case PushNotificationKind.payment:
      case PushNotificationKind.lowStock:
      case PushNotificationKind.itemRestocked:
      case PushNotificationKind.chatMessage:
      case PushNotificationKind.general:
        _openPatientTab(2);
        return true;
    }
  }

  static void _openPatientTab(int index) {
    Get.toNamed(
      AppRouter.main,
      arguments: {'tab': index},
      preventDuplicates: true,
    );
  }

  static bool _routeDoctor(PushNotificationPayload payload, int? _) {
    switch (payload.kind) {
      case PushNotificationKind.payment:
        // "payment_completed" pushes: the patient paid, so the doctor is
        // sent to their appointments (a new record was created).
        Get.toNamed(AppRouter.doctorAppointments, preventDuplicates: true);
        return true;
      case PushNotificationKind.appointmentReminder:
      case PushNotificationKind.appointmentCancelled:
        Get.toNamed(AppRouter.doctorAppointments, preventDuplicates: true);
        return true;
      case PushNotificationKind.chatMessage:
        Get.toNamed(AppRouter.conversations, preventDuplicates: true);
        return true;
      case PushNotificationKind.lowStock:
      case PushNotificationKind.itemRestocked:
      case PushNotificationKind.general:
        Get.toNamed(AppRouter.doctorNotifications, preventDuplicates: true);
        return true;
    }
  }

  static bool _routeAdmin(PushNotificationPayload payload) {
    // A stock-related push refreshes the inventory in the background so the
    // next time the admin opens the list it is already up to date.
    if (payload.kind == PushNotificationKind.lowStock ||
        payload.kind == PushNotificationKind.itemRestocked) {
      if (Get.isRegistered<AdminController>()) {
        final admin = Get.find<AdminController>();
        admin.fetchItems();
      }
    }
    Get.toNamed(AppRouter.adminHome, preventDuplicates: true);
    return true;
  }
}