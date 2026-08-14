import 'package:medora_git/features/patient/data/models/offer_model.dart';

/// Offer row returned by getActiveOffers, mapped to the home-slider
/// [OfferModel] via [toOfferModel].
class ActiveOfferModel {
  const ActiveOfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.validFrom,
    required this.validUntil,
  });

  final int id;
  final String title;
  final String description;
  final double? discountPercentage;
  final DateTime? validFrom;
  final DateTime? validUntil;

  factory ActiveOfferModel.fromJson(Map<String, dynamic> json) {
    return ActiveOfferModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountPercentage:
          double.tryParse((json['discount_percentage'] ?? '').toString()),
      validFrom: DateTime.tryParse(json['valid_from'] as String? ?? ''),
      validUntil: DateTime.tryParse(json['valid_until'] as String? ?? ''),
    );
  }

  OfferModel toOfferModel() {
    final discount = discountPercentage;
    final subtitle = description.isNotEmpty
        ? description
        : (discount != null ? '${discount.toStringAsFixed(0)}% off' : '');
    return OfferModel(id: id.toString(), title: title, subtitle: subtitle);
  }
}