/// An inventory item returned by GET /getItems.
class ItemModel {
  const ItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.minQuantity,
    required this.category,
  });

  final int id;
  final String name;
  final int quantity;
  final int minQuantity;
  final String category;

  bool get isLowStock => quantity <= minQuantity;

  bool get isOutOfStock => quantity <= 0;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      minQuantity: int.tryParse(json['min_quantity'].toString()) ?? 0,
      category: json['category'] as String? ?? '',
    );
  }
}