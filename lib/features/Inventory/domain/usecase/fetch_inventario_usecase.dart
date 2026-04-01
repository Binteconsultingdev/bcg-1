import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/domain/repositories/Inventory_repository.dart';

class FetchInventarioUsecase {
  final InventoryRepository inventoryRepository;
  FetchInventarioUsecase({required this.inventoryRepository});
  Future<List<InventoryEntity>> call(String familia, String subfamilia,int page,int pageSize) async {
    return await inventoryRepository.fetchInventario( familia,  subfamilia,page,pageSize);
  }
}