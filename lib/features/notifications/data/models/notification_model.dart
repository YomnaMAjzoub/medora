/// The kind of event a notification represents.
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

/// A notification item shown in the in-app notifications list.
///
/// Both the patient and the doctor side use this model. The backend
/// `GET /notifications` returns a bare JSON array with fields:
/// id, user_id, title, body, type, data, read_at, created_at, updated_at.
class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.data = const {},
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic> data;

  /// Extra payload keys used for navigation (appointment_id, item_id, ...).
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
    );
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : (rawData is Map ? Map<String, dynamic>.from(rawData) : <String, dynamic>{});
    return AppNotificationModel(
      id: json['id'].toString(),
      type: _typeFrom(json['type'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
              DateTime.now(),
      isRead: json['read_at'] != null,
      data: data,
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
      case 'payment':
        return NotificationType.depositPaid;
      case 'payment_completed':
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