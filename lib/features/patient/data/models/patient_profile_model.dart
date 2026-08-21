/// The logged-in patient's full profile returned by GET /getMyProfile
/// (`{"data": {user fields..., patient: {...}}}`). Personal info comes from
/// the users row; blood type and previous illnesses from the patients row.
class PatientProfileModel {
  const PatientProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.gender,
    required this.email,
    this.birth,
    this.bloodType,
    this.previousIllnesses,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String gender;
  final String email;
  final String? birth;
  final String? bloodType;
  final String? previousIllnesses;

  String get fullName => '$firstName $lastName'.trim();

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'];
    final patientMap = patient is Map<String, dynamic> ? patient : null;
    return PatientProfileModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      birth: json['birth']?.toString(),
      bloodType: patientMap?['blood_type']?.toString(),
      previousIllnesses: patientMap?['previous_illnesses']?.toString(),
    );
  }
}