import 'package:medora_git/features/patient/data/models/appointment_model.dart';

class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experienceYears,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerSession,
    required this.supportedVisitTypes,
    this.isTopRated = false,
    this.highlightNote,
    this.userId,
  });

  final String id;

  /// The doctor's user id. The backend's addBooking endpoint validates
  /// doctor_id against the users table, not the doctors table, so bookings
  /// must send this value.
  final int? userId;
  final String name;
  final String specialty;
  final int experienceYears;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final double pricePerSession;
  final List<VisitType> supportedVisitTypes;
  final bool isTopRated;
  final String? highlightNote;

  bool supports(VisitType type) => supportedVisitTypes.contains(type);

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      experienceYears: json['experience_years'] as int,
      imageUrl: json['image_url'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviews_count'] as int,
      pricePerSession: (json['price_per_session'] as num).toDouble(),
      supportedVisitTypes: (json['visit_types'] as List)
          .map((v) => VisitType.values.firstWhere((t) => t.name == v))
          .toList(),
      isTopRated: json['is_top_rated'] as bool? ?? false,
      highlightNote: json['highlight_note'] as String?,
    );
  }
}
