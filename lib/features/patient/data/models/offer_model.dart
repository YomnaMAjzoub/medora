
class OfferModel {
  const OfferModel({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
    );
  }
}
