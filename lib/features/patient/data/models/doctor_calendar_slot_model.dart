import 'package:intl/intl.dart';

class CalendarSlotModel {
  const CalendarSlotModel({
    required this.time,
    required this.fullDate,
    required this.isBooked,
    required this.status,
    required this.isClinicHour,
    required this.displayType,
  });

  final String time;
  final DateTime fullDate;
  final bool isBooked;
  final String status;
  final bool isClinicHour;
  final String displayType;

  /// A slot is bookable only when it is a clinic hour, not booked
  /// and marked available (this excludes "clinic_offline" slots).
  bool get isBookable => isClinicHour && !isBooked && status == 'available';

  factory CalendarSlotModel.fromJson(Map<String, dynamic> json) {
    return CalendarSlotModel(
      time: json['time'] as String,
      fullDate: DateTime.parse(json['full_date'] as String),
      isBooked: json['is_booked'] as bool,
      status: json['status'] as String,
      isClinicHour: json['is_clinic_hour'] as bool,
      displayType: json['display_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'full_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(fullDate),
      'is_booked': isBooked,
      'status': status,
      'is_clinic_hour': isClinicHour,
      'display_type': displayType,
    };
  }
}

class DoctorCalendarResponseModel {
  const DoctorCalendarResponseModel({required this.slots});

  final List<CalendarSlotModel> slots;

  factory DoctorCalendarResponseModel.fromJson(Map<String, dynamic> json) {
    return DoctorCalendarResponseModel(slots: _parseSlots(json));
  }

  /// Parsing layer kept isolated on purpose: if the API turns out to nest
  /// days (e.g. {"days": [{"slots": [...]}]}), only this helper changes;
  /// the Service and Controller stay untouched.
  static List<CalendarSlotModel> _parseSlots(Map<String, dynamic> json) {
    final raw = json['slots'];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(CalendarSlotModel.fromJson)
          .toList();
    }
    return const [];
  }
}
