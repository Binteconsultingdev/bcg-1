import 'package:bcg/features/Inventory/domain/entities/inventory_category_entity.dart';

class InventoryCategoryModel  extends InventoryCategoryEntity {
  InventoryCategoryModel({required super.category});
  

  factory InventoryCategoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryCategoryModel(
      category: json['familia'] ?? json['subfamilia'] ?? '',
    );
  }


}