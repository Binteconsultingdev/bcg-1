import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/settings/routes_names.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';
import 'package:bcg/features/sales/presentation/controller/sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0;
  late final SalesController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<SalesController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    onTap: () {
      FocusScope.of(context).unfocus(); 
    },
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

Widget _toggleChip({
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? ThemeColor.primaryColor : Colors.transparent,
        borderRadius: ThemeColor.circularBorderRadius,
        border: Border.all(
          color: selected ? ThemeColor.primaryColor : ThemeColor.dividerColor,
        ),
      ),
      child: Text(
        label,
        style: ThemeColor.bodySmall.copyWith(
          color: selected
              ? ThemeColor.textLightColor
              : ThemeColor.textSecondaryColor,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ),
  );
}

Widget _searchField({
  required TextEditingController controller,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  required ValueChanged<String> onChanged,
  required ValueChanged<String> onSubmitted,
}) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: ThemeColor.backgroundColor,
      borderRadius: ThemeColor.mediumBorderRadius,
      border: Border.all(color: ThemeColor.dividerColor),
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.search,
      style: ThemeColor.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: ThemeColor.bodyMedium.copyWith(
          color: ThemeColor.textSecondaryColor,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    ),
  );
}

  Widget _buildTabs() {
    const labels = ['Todas', 'Pagos Pendientes'];
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.only(
        left: ThemeColor.paddingMedium,
        right: ThemeColor.paddingMedium,
        bottom: ThemeColor.paddingSmall,
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = _selectedTab == i;
          return Padding(
            padding: const EdgeInsets.only(right: ThemeColor.paddingSmall),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
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
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
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

final items = _ctrl.filteredByTab(_selectedTab);

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
      onPressed: () {        Get.toNamed(RoutesNames.createSalesPage);
},
      backgroundColor: ThemeColor.accentColor,
      elevation: ThemeColor.elevationMedium,
      child: const Icon(Icons.add, color: ThemeColor.textDarkColor, size: 28),
    );
  }
}

class _VentaTile extends StatelessWidget {
  final PointSaleEntity item;
  const _VentaTile({required this.item});

  Color get _badgeColor => item.status?.toLowerCase() == 'pendiente'
      ? ThemeColor.errorColor
      : ThemeColor.successColor;

  String get _badgeLabel =>
      item.status?.toLowerCase() == 'pendiente' ? 'PENDIENTE' : 'PAGADO';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: ThemeColor.paddingSmall + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.folito ?? '-'} - ${item.client ?? '-'}',
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingSmall + 2,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: _badgeColor,
              borderRadius: ThemeColor.circularBorderRadius,
            ),
            child: Text(
              _badgeLabel,
              style: ThemeColor.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VentaFilterSheet extends StatefulWidget {
  final SalesController controller;
  const _VentaFilterSheet({required this.controller});

  @override
  State<_VentaFilterSheet> createState() => _VentaFilterSheetState();
}

class _VentaFilterSheetState extends State<_VentaFilterSheet> {
  final TextEditingController _desdeCtrl = TextEditingController();
  final TextEditingController _hastaCtrl = TextEditingController();
  String? _cliente;
  String? _metodoPago;
  bool _pagoPorCobrar = true;
  bool _entregaPorEntregar = true;

  int get _activeFilters => [
    if (_desdeCtrl.text.isNotEmpty) true,
    if (_hastaCtrl.text.isNotEmpty) true,
    if (_cliente != null) true,
    if (_metodoPago != null) true,
  ].length;

  final List<String> _clientes = [
    'AUTOTRANSPORTES LA FLECHA',
    'Cliente A',
    'Cliente B',
  ];
  final List<String> _metodos = ['Efectivo', 'Transferencia', 'Tarjeta'];

  void _onClear() {
    setState(() {
      _desdeCtrl.clear();
      _hastaCtrl.clear();
      _cliente = null;
      _metodoPago = null;
      _pagoPorCobrar = true;
      _entregaPorEntregar = true;
    });
    widget.controller.clearFilters();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: ThemeColor.primaryColor,
            onPrimary: Colors.white,
            onSurface: ThemeColor.textPrimaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        ctrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _desdeCtrl.dispose();
    _hastaCtrl.dispose();
    super.dispose();
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
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom, 
      ),
      child: SingleChildScrollView(
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
                    child: Text(
                      'X',
                      style: ThemeColor.subtitleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: ThemeColor.dividerColor),
            const SizedBox(height: ThemeColor.paddingMedium),

            _FilterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'De',
                              style: ThemeColor.bodySmall.copyWith(
                                color: ThemeColor.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _DateField(
                              controller: _desdeCtrl,
                              onTap: () => _pickDate(_desdeCtrl),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: ThemeColor.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hasta',
                              style: ThemeColor.bodySmall.copyWith(
                                color: ThemeColor.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _DateField(
                              controller: _hastaCtrl,
                              onTap: () => _pickDate(_hastaCtrl),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ThemeColor.paddingMedium),
                  Text(
                    'Cliente',
                    style: ThemeColor.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _DropdownField(
                    value: _cliente,
                    items: _clientes,
                    onChanged: (v) => setState(() => _cliente = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ThemeColor.paddingSmall),

            _FilterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Método de Pago',
                    style: ThemeColor.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _DropdownField(
                    value: _metodoPago,
                    items: _metodos,
                    onChanged: (v) => setState(() => _metodoPago = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ThemeColor.paddingSmall),

            _FilterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pago',
                    style: ThemeColor.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: ThemeColor.paddingSmall),
                  _ToggleGroup(
                    options: const ['Pagado', 'Por Cobrar'],
                    selectedIndex: _pagoPorCobrar ? 1 : 0,
                    onChanged: (i) => setState(() => _pagoPorCobrar = i == 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ThemeColor.paddingSmall),

            _FilterCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entrega',
                    style: ThemeColor.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: ThemeColor.paddingSmall),
                  _ToggleGroup(
                    options: const ['Entregadas', 'Por Entregar'],
                    selectedIndex: _entregaPorEntregar ? 1 : 0,
                    onChanged: (i) =>
                        setState(() => _entregaPorEntregar = i == 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: ThemeColor.paddingMedium),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingMedium,
              ),
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
                        vertical: ThemeColor.paddingMedium,
                      ),
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
                        widget.controller.applyFilters(
                          dateFrom: _desdeCtrl.text,
                          dateUntil: _hastaCtrl.text,
                          client: _cliente ?? '',
                          statusPayment: _pagoPorCobrar
                              ? 'pendiente'
                              : 'pagado',
                        );
                        Navigator.of(context).pop();
                      },
                      backgroundColor: ThemeColor.primaryColor,
                      textColor: ThemeColor.textLightColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      padding: const EdgeInsets.symmetric(
                        vertical: ThemeColor.paddingMedium,
                      ),
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
      ),
    );
  }
}

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
                color: selected ? ThemeColor.accentColor : Colors.transparent,
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
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
  final TextEditingController controller;
  final VoidCallback onTap;
  const _DateField({required this.controller, required this.onTap});

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
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingSmall,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text,
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.textPrimaryColor,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: ThemeColor.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
