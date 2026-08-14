/// Medical record row returned by getMedicaleRecord.
///
/// All clinical fields (diagnosis, prescription, ...) are nullable because
/// the backend seeds the record row before a doctor fills it in.
class MedicalRecordModel {
  const MedicalRecordModel({
    required this.diagnosis,
    required this.prescription,
    required this.tests,
    required this.images,
    required this.notes,
    required this.appointmentTime,
    required this.type,
    required this.doctorName,
    required this.doctorSpecialization,
  });

  final String? diagnosis;
  final String? prescription;
  final String? tests;
  final String? images;
  final String? notes;
  final DateTime appointmentTime;
  final String type;
  final String doctorName;
  final String? doctorSpecialization;

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      diagnosis: json['diagnosis']?.toString(),
      prescription: json['prescription']?.toString(),
      tests: json['tests']?.toString(),
      images: json['images']?.toString(),
      notes: json['notes']?.toString(),
      appointmentTime:
          DateTime.tryParse(json['appointment_time'] as String? ?? '') ??
              DateTime.now(),
      type: json['type'] as String? ?? '',
      doctorName: json['doctor_name'] as String? ?? '',
      doctorSpecialization: json['doctor_specialization']?.toString(),
    );
  }
}
