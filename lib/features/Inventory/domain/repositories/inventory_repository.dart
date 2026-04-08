import 'package:bcg/features/Inventory/domain/entities/inventory_category_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';

abstract class InventoryRepository {
  Future<List<InventoryCategoryEntity>> fetchSubfamilias();
  Future<List<InventoryCategoryEntity>> fetchFamilias();
  Future<List<InventoryEntity>> fetchInventario(String description,String numparte,String familia, String subfamilia,int page,int pageSize);

}