import 'package:medora_git/core/services/meet_link.dart';
import 'package:medora_git/features/patient/data/models/doctor_summary_model.dart';

enum AppointmentStatus { pendingDeposit, confirmed, completed, cancelled, unknown }

/// Appointment row returned by getAppointmentPatient.
///
/// The backend may or may not eager-load the doctor relation; when
/// `doctor` is present it is kept, otherwise screens resolve the doctor
/// name from the discovery list via [doctorId].
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
    this.doctor,
    this.meetLink,
    this.locationAddress,
  });

  final int id;
  final int patientId;
  final int doctorId;
  final int? locationId;
  final String type;
  final DateTime appointmentTime;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DoctorSummaryModel? doctor;
  final String? meetLink;

  /// Reverse-geocoded address of a home visit, eager-loaded by the backend
  /// (getAppointmentPatient loads the location relation).
  final String? locationAddress;

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
      doctor: json['doctor'] is Map<String, dynamic>
          ? _doctorFrom(json['doctor'] as Map<String, dynamic>)
          : null,
      meetLink: MeetLink.fromJson(json),
      locationAddress: _locationFrom(json),
    );
  }

  static String? _locationFrom(Map<String, dynamic> json) {
    final location = json['location'];
    if (location is Map) {
      final address = location['address'];
      return address?.toString().isNotEmpty == true ? address.toString() : null;
    }
    return null;
  }

  /// Accepts both the discovery-list shape ({name, specialty, ...}) and the
  /// backend's eager-loaded doctor relation ({specialization, ...,
  /// user: {first_name, last_name, ...}}).
  static DoctorSummaryModel? _doctorFrom(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final firstName = (json['first_name'] ?? user['first_name']) as String? ??
        '';
    final lastName =
        (json['last_name'] ?? user['last_name']) as String? ?? '';
    return DoctorSummaryModel(
      id: '${json['id'] ?? json['user_id'] ?? 0}',
      name: (json['name'] as String?) ?? '$firstName $lastName'.trim(),
      specialty: (json['specialty'] as String?) ??
          (json['specialization'] as String? ?? ''),
      imageUrl: json['image_url'] as String? ??
          json['profile_photo'] as String?,
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
