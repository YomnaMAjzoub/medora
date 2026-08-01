
class DoctorSummaryModel {
  const DoctorSummaryModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String specialty;
  final String? imageUrl;

  factory DoctorSummaryModel.fromJson(Map<String, dynamic> json) {
    return DoctorSummaryModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
}
