import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:medora_git/features/notifications/data/models/notification_model.dart';
import 'package:medora_git/features/notifications/data/src/notifications_service.dart';

/// In-app notifications state: list, loading/error flags, read/unread
/// actions. Shared by the patient, doctor and admin side. Refreshes on app
/// resume so pushes missed while backgrounded still appear.
class NotificationsController extends GetxController
    with WidgetsBindingObserver {
  NotificationsController({NotificationsService? service})
      : _service = service ?? NotificationsService();

  final NotificationsService _service;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<AppNotificationModel> notifications =
      <AppNotificationModel>[].obs;

  /// Reactive unread badge count (bell icons listen to this).
  final RxInt unreadCount = 0.obs;

  void _syncUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchNotifications();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-fetch when the user brings the app back so anything that arrived
    // while backgrounded (push or polling) shows up without a manual
    // pull-to-refresh.
    if (state == AppLifecycleState.resumed) {
      fetchNotifications();
    }
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final items = await _service.fetchNotifications();
      notifications.assignAll(items);
      _syncUnreadCount();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
    } catch (_) {
      // Local state still reflects the read attempt.
    }
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _syncUnreadCount();
    }
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead(notifications.toList());
    notifications.assignAll(
      notifications.map((n) => n.copyWith(isRead: true)),
    );
    _syncUnreadCount();
  }
}
