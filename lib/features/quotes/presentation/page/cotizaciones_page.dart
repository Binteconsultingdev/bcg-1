import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/settings/routes_names.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/presentation/controller/quotes_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CotizacionesPage extends StatefulWidget {
  const CotizacionesPage({super.key});

  @override
  State<CotizacionesPage> createState() => _CotizacionesPageState();
}

class _CotizacionesPageState extends State<CotizacionesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0;
  late final QuotesController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<QuotesController>();
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
      builder: (_) => _CotizacionFilterSheet(controller: _ctrl),
    );
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
            _buildTabs(),
            Expanded(child: _buildList()),
          ],
        ),
        floatingActionButton: _buildFab(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.surfaceColor,
      elevation: 0,
      centerTitle: true,
      title: Text('Cotizaciones', style: ThemeColor.headingSmall),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: ThemeColor.textPrimaryColor, size: 22),
          onPressed: () {  AuthService authService = AuthService();
            authService.logoutaler();},
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
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: ThemeColor.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Buscar cotizaciones',
                  hintStyle: ThemeColor.bodyMedium
                      .copyWith(color: ThemeColor.textSecondaryColor),
                  prefixIcon: Icon(Icons.search,
                      color: ThemeColor.textSecondaryColor, size: 20),
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
              child: const Icon(Icons.tune,
                  color: ThemeColor.textPrimaryColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    const labels = ['Todas', 'Vencidas', 'Vendidas'];
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
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.normal,
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

    if (_ctrl.errorMessage.isNotEmpty && _ctrl.quotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _ctrl.errorMessage.value,
              style: ThemeColor.bodyMedium.copyWith(color: ThemeColor.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _ctrl.fetchQuotes,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final items = _ctrl.filteredByTab(_selectedTab, _searchQuery);

    if (items.isEmpty) {
      return Center(
        child: Text(
          'Sin cotizaciones',
          style: ThemeColor.bodyMedium.copyWith(color: ThemeColor.textSecondaryColor),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _ctrl.fetchQuotes,
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
                    child: CircularProgressIndicator(color: ThemeColor.primaryColor),
                  ),
                );
              }
              if (!_ctrl.hasMorePages.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No hay más cotizaciones',
                      style: ThemeColor.bodyMedium
                          .copyWith(color: ThemeColor.textSecondaryColor),
                    ),
                  ),
                );
              }
              return const SizedBox(height: 24);
            });
          }
          return _CotizacionTile(item: items[i]);
        },
      ),
    );
  });
}
  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        Get.toNamed(RoutesNames.createQuotePage);
      },
      backgroundColor: ThemeColor.accentColor,
      elevation: ThemeColor.elevationMedium,
      child: const Icon(Icons.add, color: ThemeColor.textDarkColor, size: 28),
    );
  }
}

class _CotizacionTile extends StatelessWidget {
  final GetQuoteEntity item;
  const _CotizacionTile({required this.item});

  Color get _statusColor {
    switch (item.status?.toLowerCase()) {
      case 'vencida':
        return ThemeColor.errorColor;
      case 'vendida':
        return ThemeColor.successColor;
      default:
        return ThemeColor.infoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: ThemeColor.paddingSmall + 2),
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
                    color: ThemeColor.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
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
              color: _statusColor,
              borderRadius: ThemeColor.smallBorderRadius,
            ),
            child: Text(
              item.status ?? 'Abierta',
              style: ThemeColor.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _CotizacionFilterSheet extends StatefulWidget {
  final QuotesController controller;
  const _CotizacionFilterSheet({required this.controller});

  @override
  State<_CotizacionFilterSheet> createState() =>
      _CotizacionFilterSheetState();
}

class _CotizacionFilterSheetState extends State<_CotizacionFilterSheet> {
  final TextEditingController _desdeController = TextEditingController();
  final TextEditingController _hastaController = TextEditingController();
  String? _cliente;
  int _activeFilters = 0;

  final List<String> _clientes = [
    'AUTOTRANSPORTES LA FLECHA',
    'Cliente A',
    'Cliente B',
  ];

  void _recalc() {
    _activeFilters = [
      if (_desdeController.text.isNotEmpty) true,
      if (_hastaController.text.isNotEmpty) true,
      if (_cliente != null) true,
    ].length;
  }

  void _onClear() {
    setState(() {
      _desdeController.clear();
      _hastaController.clear();
      _cliente = null;
      _activeFilters = 0;
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
        _recalc();
      });
    }
  }

  @override
  void dispose() {
    _desdeController.dispose();
    _hastaController.dispose();
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
      padding:EdgeInsets.only(
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
                  child: Text(
                    'X',
                    style: ThemeColor.subtitleLarge
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: ThemeColor.dividerColor),
          const SizedBox(height: ThemeColor.paddingMedium),

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
                              controller: _desdeController,
                              onTap: () => _pickDate(_desdeController),
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
                              controller: _hastaController,
                              onTap: () => _pickDate(_hastaController),
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
                        value: _cliente,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: ThemeColor.textSecondaryColor, size: 20),
                        style: ThemeColor.bodyMedium
                            .copyWith(color: ThemeColor.textPrimaryColor),
                        dropdownColor: ThemeColor.surfaceColor,
                        borderRadius: ThemeColor.smallBorderRadius,
                        hint: const SizedBox.shrink(),
                        items: _clientes
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _cliente = v;
                          _recalc();
                        }),
                      ),
                    ),
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
                    onPressed: () {
                      widget.controller.applyFilters(
                        client: _cliente ?? '',
                        dateFrom: _desdeController.text,
                        dateUntil: _hastaController.text,
                      );
                      Navigator.of(context).pop();
                    },
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
                controller.text.isEmpty ? '' : controller.text,
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.textPrimaryColor,
                ),
              ),
            ),
            Icon(Icons.calendar_today_outlined,
                size: 14, color: ThemeColor.textSecondaryColor),
          ],
        ),
      ),
    );
  }
}