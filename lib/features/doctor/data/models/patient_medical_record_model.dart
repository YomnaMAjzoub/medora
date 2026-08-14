import 'package:medora_git/features/patient/data/models/medical_record_model.dart';

/// Response of getMedicalRecord/{id}: a `patient_details` map plus the
/// `medical_records` list at the same level.
class PatientMedicalRecordModel {
  const PatientMedicalRecordModel({
    required this.id,
    required this.userId,
    required this.bloodType,
    required this.previousIllnesses,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birth,
    required this.email,
    required this.records,
  });

  final int id;
  final int userId;
  final String? bloodType;
  final String? previousIllnesses;
  final String firstName;
  final String lastName;
  final String gender;
  final String? birth;
  final String email;
  final List<MedicalRecordModel> records;

  String get fullName => '$firstName $lastName'.trim();

  factory PatientMedicalRecordModel.fromJson(Map<String, dynamic> json) {
    final details =
        json['patient_details'] as Map<String, dynamic>? ?? const {};
    final user = details['user'] as Map<String, dynamic>? ?? const {};
    return PatientMedicalRecordModel(
      id: (details['id'] as num?)?.toInt() ?? 0,
      userId: (details['user_id'] as num?)?.toInt() ?? 0,
      bloodType: details['blood_type']?.toString(),
      previousIllnesses: details['previous_illnesses']?.toString(),
      firstName: user['first_name'] as String? ?? '',
      lastName: user['last_name'] as String? ?? '',
      gender: user['gender'] as String? ?? '',
      birth: user['birth']?.toString(),
      email: user['email'] as String? ?? '',
      records: (json['medical_records'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MedicalRecordModel.fromJson)
          .toList(),
    );
  }
}