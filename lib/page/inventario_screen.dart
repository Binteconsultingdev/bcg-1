import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// import 'package:tu_app/core/theme/theme_color.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modelo simple de producto
// ─────────────────────────────────────────────────────────────────────────────
class ProductItem {
  final String name;
  final double price;
  final int units;
  final String? imageUrl;

  const ProductItem({
    required this.name,
    required this.price,
    required this.units,
    this.imageUrl,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla de Inventario
// ─────────────────────────────────────────────────────────────────────────────
class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Datos de ejemplo
  final List<ProductItem> _allProducts = List.generate(
    10,
    (_) => const ProductItem(
      name: 'Aceite de motor',
      price: 350.00,
      units: 395,
    ),
  );

  List<ProductItem> get _filtered => _allProducts
      .where((p) =>
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterBottomSheet(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ThemeColor.backgroundColor,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.surfaceColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Inventario',
        style: ThemeColor.headingSmall,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: ThemeColor.textPrimaryColor),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: ThemeColor.dividerColor,
        ),
      ),
    );
  }

  // ── Barra de búsqueda + botón filtros ───────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall,
      ),
      child: Row(
        children: [
          // Campo de búsqueda
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: ThemeColor.backgroundColor,
                borderRadius: ThemeColor.mediumBorderRadius,
                border: Border.all(color: ThemeColor.dividerColor),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: ThemeColor.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Buscar productos',
                  hintStyle: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: ThemeColor.textSecondaryColor,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: ThemeColor.paddingSmall),

          // Botón filtros
          GestureDetector(
            onTap: _openFilters,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ThemeColor.backgroundColor,
                borderRadius: ThemeColor.mediumBorderRadius,
                border: Border.all(color: ThemeColor.dividerColor),
              ),
              child: const Icon(
                Icons.tune,
                color: ThemeColor.textPrimaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Lista de productos ──────────────────────────────────────────────────
  Widget _buildProductList() {
    final products = _filtered;
    if (products.isEmpty) {
      return Center(
        child: Text(
          'Sin resultados',
          style: ThemeColor.bodyMedium.copyWith(
            color: ThemeColor.textSecondaryColor,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall,
      ),
      itemCount: products.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: ThemeColor.dividerColor,
      ),
      itemBuilder: (_, i) => _ProductTile(product: products[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile individual de producto
// ─────────────────────────────────────────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  final ProductItem product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeColor.paddingSmall),
      child: Row(
        children: [
          // Imagen / placeholder
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ThemeColor.backgroundColor,
              borderRadius: ThemeColor.smallBorderRadius,
              border: Border.all(color: ThemeColor.dividerColor),
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: ThemeColor.smallBorderRadius,
                    child: Image.network(product.imageUrl!,
                        fit: BoxFit.cover),
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFBDBDBD),
                    size: 28,
                  ),
          ),
          const SizedBox(width: ThemeColor.paddingMedium),

          // Nombre y precio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.infoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Badge de unidades
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
              '${product.units} unidades',
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

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet de Filtros
// ─────────────────────────────────────────────────────────────────────────────
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? _sucursal;
  String? _familia;
  String? _subfamilia;
  int _activeFilters = 0;

  // Opciones de ejemplo — reemplaza con tus datos reales
  final List<String> _sucursales = ['Sucursal A', 'Sucursal B', 'Sucursal C'];
  final List<String> _familias = ['Lubricantes', 'Filtros', 'Refacciones'];
  final List<String> _subfamilias = ['Aceites', 'Grasas', 'Aditivos'];

  void _recalcFilters() {
    _activeFilters = [_sucursal, _familia, _subfamilia]
        .where((v) => v != null)
        .length;
  }

  void _onClear() {
    setState(() {
      _sucursal = null;
      _familia = null;
      _subfamilia = null;
      _activeFilters = 0;
    });
  }

  void _onApply() {
    // TODO: pasar filtros al controlador
    Navigator.of(context).pop({
      'sucursal': _sucursal,
      'familia': _familia,
      'subfamilia': _subfamilia,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeColor.largeRadius),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: ThemeColor.paddingSmall),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ThemeColor.dividerColor,
              borderRadius: ThemeColor.circularBorderRadius,
            ),
          ),

          // Cabecera
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
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      'X',
                      style: ThemeColor.subtitleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: ThemeColor.dividerColor),
          const SizedBox(height: ThemeColor.paddingMedium),

          // Contenido de filtros
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingMedium,
            ),
            child: Container(
              padding: const EdgeInsets.all(ThemeColor.paddingMedium),
              decoration: BoxDecoration(
                color: ThemeColor.surfaceColor,
                borderRadius: ThemeColor.mediumBorderRadius,
                boxShadow: [ThemeColor.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown(
                    label: 'Sucursal',
                    value: _sucursal,
                    items: _sucursales,
                    onChanged: (v) =>
                        setState(() { _sucursal = v; _recalcFilters(); }),
                  ),
                  const SizedBox(height: ThemeColor.paddingMedium),
                  _buildDropdown(
                    label: 'Familia',
                    value: _familia,
                    items: _familias,
                    onChanged: (v) =>
                        setState(() { _familia = v; _recalcFilters(); }),
                  ),
                  const SizedBox(height: ThemeColor.paddingMedium),
                  _buildDropdown(
                    label: 'Subfamilia',
                    value: _subfamilia,
                    items: _subfamilias,
                    onChanged: (v) =>
                        setState(() { _subfamilia = v; _recalcFilters(); }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: ThemeColor.paddingLarge),

          // Botones
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingMedium,
            ),
            child: Row(
              children: [
                // Limpiar
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

                // Ver resultados
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

  // ── Dropdown genérico ───────────────────────────────────────────────────
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeColor.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: ThemeColor.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: ThemeColor.surfaceColor,
            borderRadius: ThemeColor.smallBorderRadius,
            border: Border.all(color: ThemeColor.dividerColor),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeColor.paddingSmall,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: ThemeColor.textSecondaryColor,
                size: 20,
              ),
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textPrimaryColor,
              ),
              dropdownColor: ThemeColor.surfaceColor,
              borderRadius: ThemeColor.smallBorderRadius,
              hint: const SizedBox.shrink(),
              items: items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}