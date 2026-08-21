/// A patient of the logged-in doctor, returned by getDoctorPatients
/// (or derived from the doctor's appointments when that endpoint is
/// unavailable).
class DoctorPatientModel {
  const DoctorPatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.phone,
    required this.email,
    this.lastAppointmentId,
    this.lastVisit,
    this.appointmentsCount = 0,
  });

  /// The patient's user id (used for getMedicalRecord/{id} and chat).
  final int id;
  final String firstName;
  final String lastName;
  final String gender;
  final String phone;
  final String email;

  /// Most recent appointment id, used to attach record updates when the
  /// doctor edits a record outside an appointment context.
  final int? lastAppointmentId;
  final DateTime? lastVisit;
  final int appointmentsCount;

  String get fullName => '$firstName $lastName'.trim();

  factory DoctorPatientModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return DoctorPatientModel(
      id: (json['user_id'] as num?)?.toInt() ??
          (json['patient_id'] as num?)?.toInt() ??
          (user['id'] as num?)?.toInt() ??
          0,
      firstName: user['first_name'] as String? ?? json['first_name'] as String? ?? '',
      lastName: user['last_name'] as String? ?? json['last_name'] as String? ?? '',
      gender: user['gender'] as String? ?? json['gender'] as String? ?? '',
      phone: user['phone'] as String? ?? json['phone'] as String? ?? '',
      email: user['email'] as String? ?? json['email'] as String? ?? '',
      lastAppointmentId: (json['last_appointment_id'] as num?)?.toInt(),
      lastVisit: DateTime.tryParse(json['last_visit'] as String? ?? ''),
      appointmentsCount: (json['appointments_count'] as num?)?.toInt() ?? 0,
    );
  }
}