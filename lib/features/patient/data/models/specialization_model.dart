class SpecializationModel {
  const SpecializationModel({required this.name});

  final String name;

  factory SpecializationModel.fromJson(Map<String, dynamic> json) {
    return SpecializationModel(name: json['specialization'] as String? ?? '');
  }
}