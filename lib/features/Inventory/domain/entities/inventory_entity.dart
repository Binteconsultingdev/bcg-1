class InventoryEntity {
  final int id;
  final String? partNumber;
  final String? description;
  final String? family;
  final String? subfamily;
  final num? availableQuantity;
  final num? price;
  final String? imageUrl;

  InventoryEntity({
    required this.id,
     this.partNumber,
     this.description,
     this.family,
     this.subfamily,
     this.availableQuantity,
     this.price,
     this.imageUrl,
  });
}