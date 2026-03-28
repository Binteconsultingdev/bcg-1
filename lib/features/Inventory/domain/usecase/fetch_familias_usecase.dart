import 'package:bcg/features/Inventory/domain/entities/inventory_category_entity.dart';
import 'package:bcg/features/Inventory/domain/repositories/Inventory_repository.dart';

class FetchFamiliasUsecase {
  final InventoryRepository inventoryRepository;
  FetchFamiliasUsecase({required this.inventoryRepository});
  Future<List<InventoryCategoryEntity>> call() async {
    return await inventoryRepository.fetchFamilias();
  }
}