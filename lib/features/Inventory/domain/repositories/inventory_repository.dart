import 'package:bcg/features/Inventory/domain/entities/inventory_category_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/sucursales_entity.dart';

abstract class InventoryRepository {
  Future<List<InventoryCategoryEntity>> fetchSubfamilias(String familia);
  Future<List<InventoryCategoryEntity>> fetchFamilias();
  Future<SucursalesEntity> fetchSucursales(String numParte);
  Future<List<InventoryEntity>> fetchInventario(String description,String numparte,String familia, String subfamilia,int page,int pageSize);

}