import 'package:medora_git/core/services/meet_link.dart';
import 'package:medora_git/features/patient/data/models/appointment_record_model.dart';

/// Appointment row returned by appointmentForDoctor, with the patient
/// relation eager-loaded.
class DoctorAppointmentModel {
  const DoctorAppointmentModel({
    required this.id,
    required this.patientId,
    required this.type,
    required this.appointmentTime,
    required this.status,
    required this.patient,
    this.locationId,
    this.locationAddress,
    this.meetLink,
  });

  final int id;
  final int patientId;
  final String type;
  final DateTime appointmentTime;
  final AppointmentStatus status;
  final DoctorAppointmentPatientModel patient;
  final int? locationId;

  /// Home-visit address when the backend includes the `location` relation.
  final String? locationAddress;
  final String? meetLink;

  /// Online consultations have no backend meeting link, so a deterministic
  /// link is derived from the appointment (stable across devices/roles).
  String get resolvedMeetLink =>
      meetLink ??
      MeetLink.forAppointment(appointmentId: id, seed: patientId);

  bool get isOnline => type == 'online';

  factory DoctorAppointmentModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    String? locationAddress;
    if (location is Map<String, dynamic>) {
      locationAddress = location['address']?.toString();
    } else if (location != null && location.toString().isNotEmpty) {
      locationAddress = location.toString();
    }
    return DoctorAppointmentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      patientId: (json['patient_id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      appointmentTime:
          DateTime.tryParse(json['appointment_time'] as String? ?? '') ??
              DateTime.now(),
      status: _statusFrom(json['status'] as String? ?? ''),
      patient: DoctorAppointmentPatientModel.fromJson(
        json['patient'] as Map<String, dynamic>? ?? const {},
      ),
      locationId: (json['location_id'] as num?)?.toInt(),
      locationAddress: locationAddress,
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

class DoctorAppointmentPatientModel {
  const DoctorAppointmentPatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.phone,
    required this.email,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String gender;
  final String phone;
  final String email;

  String get fullName => '$firstName $lastName'.trim();

  factory DoctorAppointmentPatientModel.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentPatientModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}