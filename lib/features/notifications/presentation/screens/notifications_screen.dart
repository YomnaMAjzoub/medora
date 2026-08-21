import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/services/notification_router.dart';
import 'package:medora_git/core/theme/app_theme.dart';
import 'package:medora_git/features/notifications/business_layer/controller/notifications_controller.dart';
import 'package:medora_git/features/notifications/data/models/notification_model.dart';

/// In-app notifications list with read/unread distinction.
/// Used as the patient's "Notifications" tab and as a pushed screen
/// from the doctor's bell icon.
class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  /// Marks the notification as read and, like a tapped push, routes to the
  /// screen relevant to its backend type (reminder -> confirm & pay,
  /// cancellation/payment -> appointments, stock -> inventory).
  void _handleTap(NotificationsController controller, AppNotificationModel item) {
    controller.markAsRead(item.id);
    NotificationRouter.route(
      payload: PushNotificationPayload.fromData({
        'notification_type': item.rawType,
        ...item.data,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        title: Text(
          'notifications'.tr(),
          style: GoogleFonts.inter(
            color: context.appColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'mark_all_read'.tr(),
              onPressed: controller.unreadCount == 0
                  ? null
                  : controller.markAllAsRead,
              icon: Icon(
                Icons.done_all_rounded,
                color: context.appColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: context.appColors.primary),
            );
          }
          if (controller.errorMessage.value.isNotEmpty &&
              controller.notifications.isEmpty) {
            return _ErrorRetry(
              message: controller.errorMessage.value,
              onRetry: controller.fetchNotifications,
            );
          }
          if (controller.notifications.isEmpty) {
            return _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.notifications[index];
              return _NotificationCard(
                notification: item,
                onTap: () => _handleTap(controller, item),
              );
            },
          );
        }),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotificationModel notification;
  final VoidCallback onTap;

  (IconData, Color) _typeStyle(BuildContext context) {
    switch (notification.type) {
      case NotificationType.appointmentBooked:
      case NotificationType.appointmentReminder:
        return (Icons.event_available_rounded, context.appColors.primary);
      case NotificationType.appointmentCancelled:
        return (Icons.event_busy_rounded, context.appColors.danger);
      case NotificationType.consultationStarted:
        return (Icons.videocam_rounded, context.appColors.primary);
      case NotificationType.depositPaid:
      case NotificationType.paymentCompleted:
        return (Icons.payment_rounded, context.appColors.success);
      case NotificationType.lowStock:
        return (Icons.inventory_2_rounded, context.appColors.danger);
      case NotificationType.itemRestocked:
        return (Icons.add_box_rounded, context.appColors.success);
      case NotificationType.general:
        return (Icons.notifications_rounded, context.appColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _typeStyle(context);
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread
              ? AppColors.primary50.withValues(alpha: 0.35)
              : context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.appColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w500,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ),
                      if (unread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: context.appColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeLabel(notification.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now'.tr();
    if (diff.inMinutes < 60) return 'minutes_ago'.tr(namedArgs: {'count': '${diff.inMinutes}'});
    if (diff.inHours < 24) return 'hours_ago'.tr(namedArgs: {'count': '${diff.inHours}'});
    return DateFormat('d MMM yyyy').format(time);
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.primaryContainer,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 36,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}