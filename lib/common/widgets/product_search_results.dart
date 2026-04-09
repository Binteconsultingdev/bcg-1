import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/controller/product_search_controller.dart';
import 'package:bcg/common/widgets/product_thumbnail.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Campo de búsqueda ─────────────────────────────────────────────────────────

// ── Resultados ────────────────────────────────────────────────────────────────

class ProductSearchResults extends StatelessWidget {
  final Function(InventoryEntity) onSelected;
  const ProductSearchResults({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProductSearchController>();

    return Obx(() {
      if (!ctrl.isSearching.value) return const SizedBox.shrink();
      if (ctrl.isLoadingSearch.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final results = ctrl.searchResults;
      if (results.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Sin resultados', style: ThemeColor.bodySmall),
        );
      }
      return Container(
        constraints: const BoxConstraints(maxHeight: 220),
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: ThemeColor.surfaceColor,
          borderRadius: ThemeColor.smallBorderRadius,
          border: Border.all(color: ThemeColor.dividerColor),
          boxShadow: [ThemeColor.lightShadow],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: results.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: ThemeColor.dividerColor),
          itemBuilder: (_, i) {
            final p = results[i];
            return ListTile(
              dense: true,
              leading: ProductThumbnail(imageUrl: p.imageUrl, size: 36),
              title: Text(p.description ?? '',
                  style: ThemeColor.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${p.partNumber ?? ''} · \$${(p.price ?? 0).toStringAsFixed(2)}',
                style: ThemeColor.caption,
              ),
              trailing: const Icon(Icons.add_circle_outline,
                  color: ThemeColor.accentColor, size: 20),
              onTap: () => ctrl.selectProduct(p, onSelected: onSelected),
            );
          },
        ),
      );
    });
  }
}