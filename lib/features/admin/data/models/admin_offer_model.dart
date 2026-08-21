/// An offer/promotion created through POST /addOffer.
///
/// The backend responds `{"message": {...offer...}}` with HTTP 200:
/// id, admin_id, title, description, discount_percentage ("15.00"),
/// valid_from, valid_until, is_active, timestamps.
class AdminOfferModel {
  const AdminOfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
  });

  final int id;
  final String title;
  final String description;

  /// Discount as a percentage value (e.g. 15 for "15.00" — the backend
  /// column is discount_percentage).
  final double discountPercentage;
  final String validFrom;
  final String validUntil;
  final bool isActive;

  factory AdminOfferModel.fromJson(Map<String, dynamic> json) {
    return AdminOfferModel(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      discountPercentage:
          double.tryParse('${json['discount_percentage'] ?? 0}') ?? 0,
      validFrom: json['valid_from']?.toString() ?? '',
      validUntil: json['valid_until']?.toString() ?? '',
      isActive: json['is_active'].toString() == 'true' ||
          json['is_active'].toString() == '1',
    );
  }
}
