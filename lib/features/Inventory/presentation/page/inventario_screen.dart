import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/services/lisencias.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/presentation/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InventoryController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ThemeColor.backgroundColor,
        appBar: _buildAppBar(controller),
        body: Column(
          children: [
            _buildSearchBar(controller, context),
            Expanded(child: _buildBody(controller)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(InventoryController controller) {
    return AppBar(
      backgroundColor: ThemeColor.surfaceColor,
      elevation: 0,
      centerTitle: true,
      title: Text('Inventario', style: ThemeColor.headingSmall),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: ThemeColor.textPrimaryColor),
          onPressed: () {
            AuthService authService = AuthService();
            authService.logoutaler();
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: ThemeColor.dividerColor),
      ),
    );
  }

  Widget _buildSearchBar(InventoryController controller, BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: ThemeColor.backgroundColor,
                borderRadius: ThemeColor.mediumBorderRadius,
                border: Border.all(color: ThemeColor.dividerColor),
              ),
              child: TextField(
                onChanged: controller.onSearchChanged,
                style: ThemeColor.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Buscar productos',
                  hintStyle: ThemeColor.bodyMedium
                      .copyWith(color: ThemeColor.textSecondaryColor),
                  prefixIcon: Icon(Icons.search,
                      color: ThemeColor.textSecondaryColor, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: ThemeColor.paddingSmall),
          Obx(() => GestureDetector(
                onTap: () => _openFilters(context, controller),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ThemeColor.backgroundColor,
                        borderRadius: ThemeColor.mediumBorderRadius,
                        border: Border.all(color: ThemeColor.dividerColor),
                      ),
                      child: const Icon(Icons.tune,
                          color: ThemeColor.textPrimaryColor, size: 20),
                    ),
                    if (controller.activeFiltersCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: ThemeColor.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${controller.activeFiltersCount}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBody(InventoryController controller) {
    return Obx(() {
      if (controller.isLoadingInventario.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty && controller.inventario.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: ThemeColor.errorColor, size: 40),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                style: ThemeColor.bodyMedium
                    .copyWith(color: ThemeColor.textSecondaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: controller.fetchInventario,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      }

      final products = controller.filtered;

      if (products.isEmpty) {
        return Center(
          child: Text(
            'Sin resultados',
            style: ThemeColor.bodyMedium
                .copyWith(color: ThemeColor.textSecondaryColor),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchInventario,
        child: ListView.separated(
          controller: controller.scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeColor.paddingMedium,
            vertical: ThemeColor.paddingSmall,
          ),
          itemCount: products.length + 1,
          separatorBuilder: (_, i) {
            if (i == products.length - 1) return const SizedBox.shrink();
            return Divider(height: 1, color: ThemeColor.dividerColor);
          },
          itemBuilder: (_, i) {
            if (i == products.length) {
              return Obx(() {
                if (controller.isLoadingMore.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!controller.hasMorePages.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No hay más productos',
                        style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondaryColor),
                      ),
                    ),
                  );
                }
                return const SizedBox(height: 24);
              });
            }

            return _ProductTile(product: products[i]);
          },
        ),
      );
    });
  }

  void _openFilters(BuildContext context, InventoryController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(controller: controller),
    );
  }
}

class _LicenseLogo extends StatelessWidget {
  final double size;
  const _LicenseLogo({this.size = 52});

  @override
  Widget build(BuildContext context) {
    final licenseService = Get.find<LicenseService>();
    final logoUrl = licenseService.getLicenseSync()?.urllogo ?? '';

    if (logoUrl.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: ThemeColor.smallBorderRadius,
      child: Image.network(
        logoUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final InventoryEntity product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final hasImage = (product.imageUrl?.isNotEmpty ?? false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeColor.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ThemeColor.backgroundColor,
              borderRadius: ThemeColor.smallBorderRadius,
              border: Border.all(color: ThemeColor.dividerColor),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: ThemeColor.smallBorderRadius,
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _LicenseLogo(),
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: ThemeColor.accentColor,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const _LicenseLogo(),
          ),
          const SizedBox(width: ThemeColor.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.description ?? 'Sin descripción',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.infoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.partNumber ?? 'Sin número de parte',
                  style: ThemeColor.bodyMedium
                      .copyWith(color: ThemeColor.textSecondaryColor),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                  style: ThemeColor.bodyMedium
                      .copyWith(color: ThemeColor.textPrimaryColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: ThemeColor.successColor,
              borderRadius: ThemeColor.smallBorderRadius,
            ),
            child: Text(
              '${product.availableQuantity} uds',
              style: ThemeColor.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final InventoryController controller;
  const _FilterBottomSheet({required this.controller});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _familia;
  String? _subfamilia;

  @override
  void initState() {
    super.initState();
    _familia = widget.controller.selectedFamilia.value;
    _subfamilia = widget.controller.selectedSubfamilia.value;
  }

  int get _activeFilters =>
      [_familia, _subfamilia].where((v) => v != null).length;

  void _onClear() => setState(() {
        _familia = null;
        _subfamilia = null;
      });

  Future<void> _onApply() async {
    await widget.controller.applyFilters(
      familia: _familia,
      subfamilia: _subfamilia,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final familiaItems =
        widget.controller.familias.map((e) => e.category).toList();
    final subfamiliaItems =
        widget.controller.subfamilias.map((e) => e.category).toList();

    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ThemeColor.largeRadius)),
      ),
      padding:
          EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom, 
  ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: ThemeColor.paddingSmall),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ThemeColor.dividerColor,
              borderRadius: ThemeColor.circularBorderRadius,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingMedium,
              vertical: ThemeColor.paddingSmall,
            ),
            child: Row(
              children: [
                const Spacer(),
                Text('Filtros', style: ThemeColor.headingSmall),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text('X',
                      style: ThemeColor.subtitleLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ThemeColor.dividerColor),
          const SizedBox(height: ThemeColor.paddingMedium),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingMedium),
            child: Container(
              padding: const EdgeInsets.all(ThemeColor.paddingMedium),
              decoration: BoxDecoration(
                color: ThemeColor.surfaceColor,
                borderRadius: ThemeColor.mediumBorderRadius,
                boxShadow: [ThemeColor.cardShadow],
              ),
              child: Column(
                children: [
                  _buildDropdown(
                    label: 'Familia',
                    value: _familia,
                    items: familiaItems,
                    onChanged: (v) => setState(() => _familia = v),
                  ),
                  const SizedBox(height: ThemeColor.paddingMedium),
                  _buildDropdown(
                    label: 'Subfamilia',
                    value: _subfamilia,
                    items: subfamiliaItems,
                    onChanged: (v) => setState(() => _subfamilia = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: ThemeColor.paddingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: ThemeColor.widgetButton(
                    text: 'Limpiar ($_activeFilters)',
                    onPressed: _onClear,
                    backgroundColor: ThemeColor.surfaceColor,
                    textColor: ThemeColor.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(
                        vertical: ThemeColor.paddingMedium),
                    borderRadius: ThemeColor.smallRadius,
                    borderColor: ThemeColor.dividerColor,
                    borderWidth: 1.5,
                    showShadow: false,
                  ),
                ),
                const SizedBox(width: ThemeColor.paddingSmall),
                Expanded(
                  flex: 2,
                  child: ThemeColor.widgetButton(
                    text: 'Ver resultados',
                    onPressed: _onApply,
                    backgroundColor: ThemeColor.primaryColor,
                    textColor: ThemeColor.textLightColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(
                        vertical: ThemeColor.paddingMedium),
                    borderRadius: ThemeColor.smallRadius,
                    customShadow: ThemeColor.darkShadow,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ThemeColor.paddingLarge),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: ThemeColor.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: ThemeColor.textPrimaryColor)),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: ThemeColor.surfaceColor,
            borderRadius: ThemeColor.smallBorderRadius,
            border: Border.all(color: ThemeColor.dividerColor),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingSmall),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: ThemeColor.textSecondaryColor, size: 20),
              style: ThemeColor.bodyMedium
                  .copyWith(color: ThemeColor.textPrimaryColor),
              dropdownColor: ThemeColor.surfaceColor,
              borderRadius: ThemeColor.smallBorderRadius,
              hint: const SizedBox.shrink(),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}