import 'package:bcg/features/Inventory/domain/entities/inventory_category_entity.dart';
import 'package:bcg/features/Inventory/domain/repositories/Inventory_repository.dart';

class FetchSubfamiliasUsecase {
  final InventoryRepository inventoryRepository;

  FetchSubfamiliasUsecase({required this.inventoryRepository});
  Future<List<InventoryCategoryEntity>> call(String familia) async {
    return await inventoryRepository.fetchSubfamilias(familia);
  }
}