import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/settings/routes_names.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_search_controller.dart';
import 'package:bcg/features/client/presentation/page/client_search_field.dart';
import 'package:bcg/features/quotes/presentation/widget/create_pdf_controller.dart';
import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';
import 'package:bcg/features/sales/presentation/controller/sales_controller.dart';
import 'package:bcg/features/sales/presentation/page/CreateSalesPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  int _selectedTab = 0;
  late final SalesController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<SalesController>();
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VentaFilterSheet(controller: _ctrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: ThemeColor.backgroundColor,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildSearchBar(),
              _buildTabs(),
              Expanded(child: _buildList()),
            ],
          ),
          floatingActionButton: _buildFab(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.surfaceColor,
      elevation: 0,
      centerTitle: true,
      title: Text('Ventas', style: ThemeColor.headingSmall),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.settings_outlined,
            color: ThemeColor.textPrimaryColor,
            size: 22,
          ),
          onPressed: () {
            AuthService authService = AuthService();
            authService.logoutaler();
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: ThemeColor.dividerColor),
      ),
    );
  }

  Widget _buildSearchBar() {
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
                controller: _ctrl.searchController,
                onChanged: (v) => _ctrl.searchInput.value = v,
                onSubmitted: (_) => _ctrl.searchSales(),
                textInputAction: TextInputAction.search,
                style: ThemeColor.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Buscar por folio, ID o cliente...',
                  hintStyle: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: ThemeColor.paddingSmall),
          GestureDetector(
            onTap: _ctrl.searchSales,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor,
                borderRadius: ThemeColor.mediumBorderRadius,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: ThemeColor.paddingSmall),
          Obx(() {
            final hasFilters =
                _ctrl.dateFromFilter.value.isNotEmpty ||
                _ctrl.dateUntilFilter.value.isNotEmpty ||
                _ctrl.clientFilter.value.isNotEmpty ||
                _ctrl.statusPaymentFilter.value.isNotEmpty;
            return GestureDetector(
              onTap: _openFilters,
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
                    child: const Icon(
                      Icons.tune,
                      color: ThemeColor.textPrimaryColor,
                      size: 20,
                    ),
                  ),
                  if (hasFilters)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: ThemeColor.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '!',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    const labels = ['Todas', 'Por Cobrar', 'Pagado'];
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.only(
        left: ThemeColor.paddingMedium,
        right: ThemeColor.paddingMedium,
        bottom: ThemeColor.paddingSmall,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(labels.length, (i) {
            final selected = _selectedTab == i;
            return Padding(
              padding: const EdgeInsets.only(right: ThemeColor.paddingSmall),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = i);
                  _ctrl.onTabChanged(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeColor.paddingMedium,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? ThemeColor.primaryColor
                        : Colors.transparent,
                    borderRadius: ThemeColor.mediumBorderRadius,
                    border: Border.all(
                      color: selected
                          ? ThemeColor.primaryColor
                          : ThemeColor.dividerColor,
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: ThemeColor.bodySmall.copyWith(
                      color: selected
                          ? ThemeColor.textLightColor
                          : ThemeColor.textSecondaryColor,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: ThemeColor.primaryColor),
        );
      }

      if (_ctrl.errorMessage.isNotEmpty && _ctrl.sales.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _ctrl.errorMessage.value,
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _ctrl.fetchSales,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      }

      final items = _ctrl.sales;

      if (items.isEmpty) {
        return Center(
          child: Text(
            'Sin ventas',
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textSecondaryColor,
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _ctrl.fetchSales,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: ThemeColor.paddingMedium,
            vertical: ThemeColor.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: ThemeColor.surfaceColor,
            borderRadius: ThemeColor.mediumBorderRadius,
            border: Border.all(color: ThemeColor.surfaceColor, width: 1.5),
            boxShadow: [ThemeColor.cardShadow],
          ),
          child: ListView.separated(
            controller: _ctrl.scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingMedium,
              vertical: ThemeColor.paddingSmall,
            ),
            itemCount: items.length + 1,
            separatorBuilder: (_, i) {
              if (i == items.length - 1) return const SizedBox.shrink();
              return Divider(height: 1, color: ThemeColor.dividerColor);
            },
            itemBuilder: (_, i) {
              if (i == items.length) {
                return Obx(() {
                  if (_ctrl.isLoadingMore.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ThemeColor.primaryColor,
                        ),
                      ),
                    );
                  }
                  if (!_ctrl.hasMorePages.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No hay más ventas',
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox(height: 24);
                });
              }
              return _VentaTile(item: items[i]);
            },
          ),
        ),
      );
    });
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => Get.toNamed(RoutesNames.createSalesPage),
      backgroundColor: ThemeColor.accentColor,
      elevation: ThemeColor.elevationMedium,
      child: const Icon(Icons.add, color: ThemeColor.textDarkColor, size: 28),
    );
  }
}

// ─────────────────────────────────────────────
// Tile
// ─────────────────────────────────────────────
class _VentaTile extends StatelessWidget {
  final PointSaleEntity item;
  const _VentaTile({required this.item});

  Color get _badgeColor {
    switch (item.status?.toLowerCase()) {
      case 'pagado':
        return ThemeColor.successColor;
      case 'por cobrar':
        return ThemeColor.warningColor;
      default:
        return ThemeColor.infoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SalesController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeColor.paddingSmall + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.client ?? '-',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.infoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.date ?? '-',
                  style: ThemeColor.caption.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.total?.toStringAsFixed(2) ?? '0.00'}',
                  style: ThemeColor.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Badge de status
          Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    // Badge de status
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingSmall + 2,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: ThemeColor.circularBorderRadius,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 100),
        child: Text(
          item.status?.toUpperCase() ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ThemeColor.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),
    const SizedBox(height: 6),
    // Botón PDF
    Obx(() {
      final isLoading = Get.find<PdfController>().isLoadingPdf.value;
      return GestureDetector(
        onTap: () => ctrl.openSalePdf(context, item.id, item.folito ?? '${item.id}'),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: ThemeColor.errorColor.withOpacity(0.1),
            borderRadius: ThemeColor.smallBorderRadius,
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(6),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ThemeColor.errorColor,
                  ),
                )
              : const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: ThemeColor.errorColor,
                  size: 18,
                ),
        ),
      );
    }),
  ],
),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────
// Filter Sheet
// ─────────────────────────────────────────────
class _VentaFilterSheet extends StatelessWidget {
  final SalesController controller;
  const _VentaFilterSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    controller.initFilterSheet();

    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeColor.largeRadius),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
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
            // Header
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
                    onTap: () {
                      Get.find<ClientSearchController>().clearSearch();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'X',
                      style: ThemeColor.subtitleLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: ThemeColor.dividerColor),
            const SizedBox(height: ThemeColor.paddingMedium),

            // Fechas
            _FilterCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('De', style: ThemeColor.bodySmall.copyWith(color: ThemeColor.textSecondaryColor)),
                        const SizedBox(height: 4),
                        Obx(() => _DateField(
                          value: controller.filterDateFrom.value,
                          onTap: () => controller.pickFilterDate(context, controller.filterDateFrom),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(width: ThemeColor.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hasta', style: ThemeColor.bodySmall.copyWith(color: ThemeColor.textSecondaryColor)),
                        const SizedBox(height: 4),
                        Obx(() => _DateField(
                          value: controller.filterDateUntil.value,
                          onTap: () => controller.pickFilterDate(context, controller.filterDateUntil),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ThemeColor.paddingSmall),

            // Cliente
            _FilterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente', style: ThemeColor.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  ClientSearchField(onSelected: controller.onFilterClientSelected),
                  ClientSearchResults(onSelected: controller.onFilterClientSelected),
                ],
              ),
            ),

            const SizedBox(height: ThemeColor.paddingSmall),

            // Estado de pago
            _FilterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado de Pago', style: ThemeColor.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(height: ThemeColor.paddingSmall),
                  Obx(() => _ToggleGroup(
                    options: const ['Todas', 'Pagado', 'Por Cobrar'],
                    selectedIndex: controller.filterPagoIndex.value == null ? 0 : controller.filterPagoIndex.value! + 1,
                    onChanged: (i) => controller.filterPagoIndex.value = i == 0 ? null : i - 1,
                  )),
                ],
              ),
            ),

            const SizedBox(height: ThemeColor.paddingMedium),

            // Botones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeColor.paddingMedium),
              child: Obx(() => Row(
                children: [
                  Expanded(
                    child: ThemeColor.widgetButton(
                      text: 'Limpiar (${controller.activeFilters})',
                      onPressed: controller.onFilterClear,
                      backgroundColor: ThemeColor.surfaceColor,
                      textColor: ThemeColor.textPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      padding: const EdgeInsets.symmetric(vertical: ThemeColor.paddingMedium),
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
                      onPressed: () {
                        controller.applyFilterSheet();
                        Navigator.of(context).pop();
                      },
                      backgroundColor: ThemeColor.primaryColor,
                      textColor: ThemeColor.textLightColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      padding: const EdgeInsets.symmetric(vertical: ThemeColor.paddingMedium),
                      borderRadius: ThemeColor.smallRadius,
                      customShadow: ThemeColor.darkShadow,
                    ),
                  ),
                ],
              )),
            ),
            const SizedBox(height: ThemeColor.paddingLarge),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────

class _FilterCard extends StatelessWidget {
  final Widget child;
  const _FilterCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeColor.paddingMedium),
      padding: const EdgeInsets.all(ThemeColor.paddingMedium),
      decoration: BoxDecoration(
        color: ThemeColor.surfaceColor,
        borderRadius: ThemeColor.mediumBorderRadius,
        boxShadow: [ThemeColor.cardShadow],
      ),
      child: child,
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: ThemeColor.surfaceColor,
        borderRadius: ThemeColor.smallBorderRadius,
        border: Border.all(color: ThemeColor.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: ThemeColor.paddingSmall),
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
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ToggleGroup extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _ToggleGroup({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (i) {
        final selected = selectedIndex == i;
        return Padding(
          padding: EdgeInsets.only(
            right: i < options.length - 1 ? ThemeColor.paddingSmall : 0,
          ),
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingMedium,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color:
                    selected ? ThemeColor.accentColor : Colors.transparent,
                borderRadius: ThemeColor.circularBorderRadius,
                border: Border.all(
                  color: selected
                      ? ThemeColor.accentColor
                      : ThemeColor.dividerColor,
                ),
              ),
              child: Text(
                options[i],
                style: ThemeColor.bodySmall.copyWith(
                  color: selected
                      ? ThemeColor.textDarkColor
                      : ThemeColor.textSecondaryColor,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DateField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  const _DateField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ThemeColor.surfaceColor,
          borderRadius: ThemeColor.smallBorderRadius,
          border: Border.all(color: ThemeColor.dividerColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: ThemeColor.paddingSmall),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: ThemeColor.bodySmall.copyWith(color: ThemeColor.textPrimaryColor),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 14, color: ThemeColor.textSecondaryColor),
          ],
        ),
      ),
    );
  }
}