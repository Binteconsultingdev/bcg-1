import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/presentation/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductSearchController extends GetxController {
  late final InventoryController _inventoryCtrl = Get.find<InventoryController>();

  final RxList<InventoryEntity> searchResults = <InventoryEntity>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingSearch = false.obs;
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  Future<void> onSearchChanged(String value) async {
    isSearching.value = value.isNotEmpty;

    if (value.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoadingSearch.value = true;
      final results = await _inventoryCtrl.searchProducts(value);
      searchResults.assignAll(results);
    } catch (_) {
      searchResults.clear();
    } finally {
      isLoadingSearch.value = false;
    }
  }

  void clearSearch() {
    searchCtrl.clear();
    isSearching.value = false;
    searchResults.clear();
  }

  void selectProduct(InventoryEntity product, {required Function(InventoryEntity) onSelected}) {
    onSelected(product);
    clearSearch();
  }
}