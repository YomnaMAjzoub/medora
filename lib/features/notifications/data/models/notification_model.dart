import 'dart:convert';

/// Matches Laravel `notifications.type` values used by the Flutter app.
enum NotificationType {
  appointmentBooked,
  appointmentReminder,
  appointmentCancelled,
  consultationStarted,
  depositPaid,
  paymentCompleted,
  lowStock,
  itemRestocked,
  general,
}

/// In-app row from `GET /notifications` (Laravel bare JSON array).
class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.data = const {},
    this.rawType = '',
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic> data;

  /// Laravel `type`: appointment_reminder, appointment_cancelled,
  /// payment_completed, low_stock, item_restocked, ...
  final String rawType;

  int? get appointmentId => _intValue('appointment_id');
  int? get itemId => _intValue('item_id');

  int? _intValue(String key) {
    final raw = data[key];
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  AppNotificationModel copyWith({bool? isRead}) {
    return AppNotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      data: data,
      rawType: rawType,
    );
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    Map<String, dynamic> data = {};
    if (rawData is Map<String, dynamic>) {
      data = rawData;
    } else if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        data = {};
      }
    }
    final rawType = json['type'] as String? ?? '';
    return AppNotificationModel(
      id: json['id'].toString(),
      type: _typeFrom(rawType),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
              DateTime.now(),
      isRead: json['read_at'] != null,
      data: data,
      rawType: rawType,
    );
  }

  static NotificationType _typeFrom(String raw) {
    switch (raw) {
      case 'appointment_booked':
      case 'booking':
      case 'booked':
        return NotificationType.appointmentBooked;
      case 'appointment_reminder':
      case 'reminder':
        return NotificationType.appointmentReminder;
      case 'appointment_cancelled':
      case 'cancellation':
      case 'cancelled':
        return NotificationType.appointmentCancelled;
      case 'consultation_started':
      case 'consultation':
        return NotificationType.consultationStarted;
      case 'deposit_paid':
        return NotificationType.depositPaid;
      case 'payment_completed':
        return NotificationType.paymentCompleted;
      case 'payment':
        // Laravel test type "payment" maps to full-payment doctor flow.
        return NotificationType.paymentCompleted;
      case 'low_stock':
        return NotificationType.lowStock;
      case 'item_restocked':
      case 'restock':
        return NotificationType.itemRestocked;
      default:
        return NotificationType.general;
    }
  }
}
