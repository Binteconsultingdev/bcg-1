import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/controller/product_search_controller.dart';
import 'package:bcg/common/widgets/product_thumbnail.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Campo de búsqueda ─────────────────────────────────────────────────────────
class ProductSearchField extends StatelessWidget {
  final Function(InventoryEntity) onSelected;
  const ProductSearchField({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProductSearchController>();

    return Obx(() => ThemeColor.searchTextField(
      controller: ctrl.searchCtrl,
      hintText: 'Buscar por descripción o núm. parte',
      prefixIcon: Icons.search,
      isLoading: ctrl.isLoadingSearch.value,
      hasText: ctrl.isSearching.value,
      onChanged: ctrl.onSearchChanged,
      onClear: ctrl.clearSearch,
    ));
  }
}

// ── Resultados ────────────────────────────────────────────────────────────────
