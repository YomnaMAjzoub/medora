import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medora_git/core/network/api_client.dart';
import 'package:medora_git/features/notifications/data/models/notification_model.dart';

/// In-app notifications source backed by the real backend.
///
/// - [fetchNotifications] reads `GET /notifications`, which returns a bare
///   JSON array of notification rows.
/// - [markAsRead] calls `POST /notifications/{id}/read`.
/// - There is no backend endpoint to clear notifications, so the clear-all
///   action is intentionally not exposed.
class NotificationsService {
  /// Notifications for the logged-in user.
  Future<List<AppNotificationModel>> fetchNotifications() async {
    try {
      final response = await ApiClient.dio.get('/notifications');
      final data = response.data;
      final list = data is List ? data : null;
      if (list != null) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(AppNotificationModel.fromJson)
            .toList();
      }
      throw Exception('invalid_notifications_response'.tr());
    } on DioException catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Marks a single notification as read on the backend.
  Future<void> markAsRead(String id) async {
    await ApiClient.dio.post('/notifications/$id/read');
  }

  /// Marks every notification as read by calling the read endpoint for each.
  Future<void> markAllAsRead(List<AppNotificationModel> items) async {
    for (final item in items) {
      if (item.isRead) continue;
      try {
        await markAsRead(item.id);
      } on DioException {
        // Keep going: a single failure should not block the rest.
      }
    }
  }
}