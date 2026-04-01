import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/features/Inventory/data/datasources/inventory_datasources_imp.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_category_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/domain/repositories/Inventory_repository.dart';

class InventoryRepositoryImp implements InventoryRepository {
  final InventoryDatasourcesImp inventoryDatasourcesImp;
  InventoryRepositoryImp({required this.inventoryDatasourcesImp});
  AuthService authService = AuthService();
  @override
  Future<List<InventoryCategoryEntity>> fetchFamilias() async {
    final token = await authService.getToken() ?? (throw Exception( 'No hay sesión activa. El usuario debe iniciar sesión.'));
    return await inventoryDatasourcesImp.fetchFamilias(token);
  }

  @override
  Future<List<InventoryEntity>> fetchInventario( String familia,
    String subfamilia,int page,int pageSize) async {
    final token = await authService.getToken() ?? (throw Exception( 'No hay sesión activa. El usuario debe iniciar sesión.'));
    return await inventoryDatasourcesImp.fetchInventario(token,familia, subfamilia,page,pageSize);
  }

  @override
  Future<List<InventoryCategoryEntity>> fetchSubfamilias() async {
     final token = await authService.getToken() ?? (throw Exception( 'No hay sesión activa. El usuario debe iniciar sesión.'));
    return await inventoryDatasourcesImp.fetchSubfamilias(token);
  }

  
}