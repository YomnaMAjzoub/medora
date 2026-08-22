import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medora_git/core/routing/app_router.dart';
import 'package:medora_git/features/admin/business_layer/controller/admin_controller.dart';
import 'package:medora_git/features/notifications/business_layer/controller/notifications_controller.dart';

/// Matches Laravel Flutter push `notification_type` values:
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

/// Parsed FCM / in-app data payload (aligned with Laravel).
///
/// Backend data keys:
///   notification_type: appointment_reminder | appointment_cancelled |
///                      payment_completed | low_stock | item_restocked
///   appointment_id    : string|int
///   action_required   : confirm_and_pay (reminders)
///   item_id           : string|int (stock events)
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
      PushNotificationPayload.fromData(
        Map<String, dynamic>.from(message.data),
      );

  /// Prefer exact Laravel type strings, then safe fallbacks.
  PushNotificationKind get kind {
    final raw = (type ?? '').toLowerCase().trim();
    switch (raw) {
      case 'item_restocked':
      case 'restock':
        return PushNotificationKind.itemRestocked;
      case 'payment_completed':
      case 'deposit_paid':
      case 'payment':
      case 'paid':
      case 'deposit':
        return PushNotificationKind.payment;
      case 'appointment_reminder':
      case 'reminder':
        return PushNotificationKind.appointmentReminder;
      case 'appointment_cancelled':
      case 'cancellation':
      case 'cancelled':
        return PushNotificationKind.appointmentCancelled;
      case 'low_stock':
        return PushNotificationKind.lowStock;
      default:
        break;
    }
    if (raw.contains('restock')) return PushNotificationKind.itemRestocked;
    if (raw.contains('payment') || raw.contains('paid')) {
      return PushNotificationKind.payment;
    }
    if (raw.contains('reminder')) return PushNotificationKind.appointmentReminder;
    if (raw.contains('cancel')) return PushNotificationKind.appointmentCancelled;
    if (raw.contains('low_stock') || raw == 'stock') {
      return PushNotificationKind.lowStock;
    }
    if (raw.contains('chat') || raw.contains('message')) {
      return PushNotificationKind.chatMessage;
    }
    return PushNotificationKind.general;
  }

  bool get requiresConfirmAndPay =>
      actionRequired == 'confirm_and_pay' ||
      kind == PushNotificationKind.appointmentReminder;

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

/// Routes a tapped push / in-app notification by role + Laravel type.
class NotificationRouter {
  static const _lastHandledKey = 'last_notification_handled';

  static bool route({required PushNotificationPayload payload}) {
    final storage = GetStorage();
    final hasToken = storage.read<String>('access_token')?.isNotEmpty ?? false;
    if (!hasToken) return false;

    final signature = payload.toData().toString();
    if (Get.currentRoute != AppRouter.splash &&
        storage.read<String>(_lastHandledKey) == signature) {
      return true;
    }
    storage.write(_lastHandledKey, signature);

    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().fetchNotifications();
    }

    final role = storage.read<String>('role') ?? '';
    final appointmentId = payload.appointmentId;

    switch (role) {
      case 'doctor':
        return _routeDoctor(payload, appointmentId);
      case 'admin':
      case 'super_admin':
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
        // Laravel reminder: notification_type=appointment_reminder +
        // action_required=confirm_and_pay + appointment_id
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
        // Laravel sends payment_completed after full payment.
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
