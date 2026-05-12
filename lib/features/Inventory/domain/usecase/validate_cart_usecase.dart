import 'package:bcg/features/Inventory/domain/entities/post_validate_cart_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/response_validate_cart_entity.dart';
import 'package:bcg/features/Inventory/domain/repositories/inventory_repository.dart';

class ValidateCartUsecase {
  final InventoryRepository inventoryRepository;

  ValidateCartUsecase({required this.inventoryRepository});

  Future<ResponseValidateCartEntity> call(PostValidateCartEntity entity) async {
    return await inventoryRepository.validateCart(entity);
  }
}
