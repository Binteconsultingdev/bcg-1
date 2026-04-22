import 'package:bcg/features/Inventory/domain/entities/sucursales_entity.dart';
import 'package:bcg/features/Inventory/domain/repositories/Inventory_repository.dart';

class FetchSucursalesUsecase {
  final InventoryRepository inventoryRepository;

  FetchSucursalesUsecase({required this.inventoryRepository});

  Future<SucursalesEntity> call(String numParte) {
    return inventoryRepository.fetchSucursales(numParte);
  }
}