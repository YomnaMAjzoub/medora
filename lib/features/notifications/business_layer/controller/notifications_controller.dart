import 'package:get/get.dart';
import 'package:medora_git/features/notifications/data/models/notification_model.dart';
import 'package:medora_git/features/notifications/data/src/notifications_service.dart';

/// In-app notifications state: list, loading/error flags, read/unread
/// actions. Shared by the patient and the doctor side.
class NotificationsController extends GetxController {
  NotificationsController({NotificationsService? service})
      : _service = service ?? NotificationsService();

  final NotificationsService _service;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<AppNotificationModel> notifications =
      <AppNotificationModel>[].obs;

  /// Number of notifications still unread.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final items = await _service.fetchNotifications();
      notifications.assignAll(items);
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
    }
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead(notifications.toList());
    notifications.assignAll(
      notifications.map((n) => n.copyWith(isRead: true)),
    );
  }
}