import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';

class InventoryModel extends InventoryEntity {
  InventoryModel({required super.id,super.unit, required super.partNumber, required super.description,  super.family,  super.subfamily,  super.availableQuantity,  super.price,  super.imageUrl});
  
  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      unit: json['unidad'],
      partNumber: json['numParte'],
      description: json['descripcion'],
      family: json['familia'],
      subfamily: json['subfamilia'],
      availableQuantity: json['disponible'],
      price: json['precio'],
      imageUrl: json['imagenUrl'],
    );
  }
}