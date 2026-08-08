class UserModel {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.role,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.birth,
    this.phone,
    this.emailVerifiedAt,
    this.fcmToken,
    this.patient,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String role;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? birth;
  final String? phone;
  final DateTime? emailVerifiedAt;
  final String? fcmToken;
  final PatientProfileModel? patient;

  /// Backend returns is_verified inconsistently (bool on register/verify,
  /// int on login), so parse all common representations.
  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == '1' || normalized == 'true';
    }
    return false;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      gender: json['gender'] as String,
      role: json['role'] as String,
      isVerified: _asBool(json['is_verified']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      birth: json['birth'] as String?,
      phone: json['phone'] as String?,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      fcmToken: json['fcm_token'] as String?,
      patient: json['patient'] is Map<String, dynamic>
          ? PatientProfileModel.fromJson(
              json['patient'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class PatientProfileModel {
  const PatientProfileModel({
    required this.id,
    required this.userId,
    required this.bloodType,
    required this.previousIllnesses,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final String? bloodType;
  final String? previousIllnesses;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      bloodType: json['blood_type'] as String?,
      previousIllnesses: json['previous_illnesses'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
