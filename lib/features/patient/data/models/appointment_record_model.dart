import 'package:medora_git/core/services/meet_link.dart';

enum AppointmentStatus { pendingDeposit, confirmed, completed, cancelled, unknown }

/// Appointment row returned by getAppointmentPatient.
///
/// Note: the backend does not eager-load the doctor relation here
/// (`doctor` is always null in the response), so no doctor info is kept.
class AppointmentRecordModel {
  const AppointmentRecordModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.locationId,
    required this.type,
    required this.appointmentTime,
    required this.status,
    required this.createdAt,
    this.meetLink,
  });

  final int id;
  final int patientId;
  final int doctorId;
  final int? locationId;
  final String type;
  final DateTime appointmentTime;
  final AppointmentStatus status;
  final DateTime createdAt;
  final String? meetLink;

  /// Online consultations have no backend meeting link, so a deterministic
  /// link is derived from the appointment (stable across devices/roles).
  String get resolvedMeetLink =>
      meetLink ??
      MeetLink.forAppointment(appointmentId: id, seed: doctorId);

  bool get isOnline => type == 'online';

  factory AppointmentRecordModel.fromJson(Map<String, dynamic> json) {
    return AppointmentRecordModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      patientId: (json['patient_id'] as num?)?.toInt() ?? 0,
      doctorId: (json['doctor_id'] as num?)?.toInt() ?? 0,
      locationId: (json['location_id'] as num?)?.toInt(),
      type: json['type'] as String? ?? '',
      appointmentTime:
          DateTime.tryParse(json['appointment_time'] as String? ?? '') ??
              DateTime.now(),
      status: _statusFrom(json['status'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      meetLink: MeetLink.fromJson(json),
    );
  }

  static AppointmentStatus _statusFrom(String raw) {
    switch (raw) {
      case 'pending_deposit':
        return AppointmentStatus.pendingDeposit;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.unknown;
    }
  }
}
