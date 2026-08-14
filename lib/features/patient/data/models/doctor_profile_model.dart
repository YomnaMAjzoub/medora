import 'package:medora_git/core/storage/appconfig.dart';
import 'package:medora_git/features/patient/data/models/appointment_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';

class DoctorScheduleModel {
  const DoctorScheduleModel({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  final int id;
  final String day;
  final String startTime;
  final String endTime;
  final double price;

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleModel(
      id: (json['id'] as num).toInt(),
      day: json['day'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
    );
  }
}

/// Doctor row returned by the patient-facing doctor endpoints
/// (getAllDoctorsForPatient / filterDoctor). Mapped to the UI-facing
/// [DoctorModel] via [toDoctorModel].
class DoctorProfileModel {
  const DoctorProfileModel({
    required this.id,
    required this.userId,
    this.adminId,
    required this.profilePhoto,
    required this.specialization,
    required this.isAvailable,
    required this.homeVisit,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.schedules,
  });

  final int id;
  final int userId;
  final int? adminId;
  final String profilePhoto;
  final String specialization;
  final bool isAvailable;
  final bool homeVisit;
  final String firstName;
  final String lastName;
  final String gender;
  final List<DoctorScheduleModel> schedules;

  double get pricePerSession =>
      schedules.isEmpty ? 0 : schedules.first.price;

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return DoctorProfileModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      adminId: json['admin_id'] as int?,
      profilePhoto: _resolveImageUrl(json['profile_photo'] as String? ?? ''),
      specialization: json['specialization'] as String? ?? '',
      isAvailable: _asBool(json['is_available']),
      homeVisit: _asBool(json['home_visit']),
      firstName: user['first_name'] as String? ?? '',
      lastName: user['last_name'] as String? ?? '',
      gender: user['gender'] as String? ?? '',
      schedules: (json['schedules'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DoctorScheduleModel.fromJson)
          .toList(),
    );
  }

  DoctorModel toDoctorModel() {
    return DoctorModel(
      id: id.toString(),
      name: '$firstName $lastName'.trim(),
      specialty: specialization,
      experienceYears: 0,
      imageUrl: profilePhoto,
      rating: 0,
      reviewsCount: 0,
      pricePerSession: pricePerSession,
      supportedVisitTypes: [
        VisitType.clinic,
        VisitType.online,
        if (homeVisit) VisitType.home,
      ],
      userId: userId,
    );
  }

  /// Accepts both int (1/0) and string ("1"/"0"/"true"/"false") flag
  /// values, which the backend mixes across endpoints.
  static bool _asBool(dynamic value) {
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.toLowerCase();
      return v == '1' || v == 'true';
    }
    return false;
  }

  /// Normalizes the photo to an absolute URL pointing at the configured
  /// host: filterDoctor returns a relative path (without the storage
  /// prefix) while getAllDoctorsForPatient returns a full URL on 127.0.0.1.
  static String _resolveImageUrl(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) {
      return '${AppConfig.storageBaseUrl}/storage/$raw';
    }
    if (uri.host == '127.0.0.1' || uri.host == 'localhost') {
      final base = Uri.parse(AppConfig.storageBaseUrl);
      return uri
          .replace(scheme: base.scheme, host: base.host, port: base.port)
          .toString();
    }
    return raw;
  }
}
