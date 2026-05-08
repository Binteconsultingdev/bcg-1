import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
import 'package:bcg/features/client/presentation/page/upper_case_text_formatter.dart';
import 'package:bcg/features/quotes/presentation/widget/create_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final ClientController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ClientController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNuevoCliente() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (_) => _NuevoClienteSheet(controller: _ctrl),
    );
  }

  void _openFiltros() {
    _ctrl.initFilterSheet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClienteFilterSheet(controller: _ctrl),
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
              const SizedBox(height: ThemeColor.paddingSmall),
              _buildAgregarBtn(),
              const SizedBox(height: ThemeColor.paddingSmall),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.surfaceColor,
      elevation: 0,
      centerTitle: true,
      title: Text('Clientes', style: ThemeColor.headingSmall),
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
                borderRadius: ThemeColor.circularBorderRadius,
                border: Border.all(color: ThemeColor.dividerColor),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => _ctrl.fetchClients(
                  client: v,
                  porCobrar: _ctrl.porCobrarFilter.value,
                ),
                style: ThemeColor.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Buscar cliente',
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: ThemeColor.paddingSmall),
          // Botón filtros con indicador
          Obx(() {
            final hasFilter = _ctrl.porCobrarFilter.value != null;
            return GestureDetector(
              onTap: _openFiltros,
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
                  if (hasFilter)
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

  Widget _buildAgregarBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeColor.paddingMedium),
      child: ThemeColor.widgetButton(
        text: 'Agregar Cliente',
        onPressed: _openNuevoCliente,
        backgroundColor: ThemeColor.primaryColor,
        textColor: ThemeColor.textLightColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        padding: const EdgeInsets.symmetric(
          vertical: ThemeColor.paddingSmall + 4,
        ),
        borderRadius: ThemeColor.smallRadius,
        customShadow: ThemeColor.darkShadow,
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

      if (_ctrl.errorMessage.isNotEmpty && _ctrl.clients.isEmpty) {
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
                onPressed: _ctrl.fetchClients,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      }

      if (_ctrl.clients.isEmpty) {
        return Center(
          child: Text(
            'Sin clientes',
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textSecondaryColor,
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _ctrl.fetchClients,
        child: ListView.separated(
          controller: _ctrl.scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeColor.paddingMedium,
            vertical: ThemeColor.paddingSmall,
          ),
          itemCount: _ctrl.clients.length + 1,
          separatorBuilder: (_, i) {
            if (i == _ctrl.clients.length - 1) return const SizedBox.shrink();
            return Divider(height: 1, color: ThemeColor.dividerColor);
          },
          itemBuilder: (_, i) {
            if (i == _ctrl.clients.length) {
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
                        'No hay más clientes',
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

            return _ClienteTile(cliente: _ctrl.clients[i]);
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
// Filter Sheet
// ─────────────────────────────────────────────
class _ClienteFilterSheet extends StatelessWidget {
  final ClientController controller;
  const _ClienteFilterSheet({required this.controller});

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
        bottom: MediaQuery.of(context).padding.bottom + ThemeColor.paddingLarge,
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

          // Filtro adeudo
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingMedium,
            ),
            padding: const EdgeInsets.all(ThemeColor.paddingMedium),
            decoration: BoxDecoration(
              color: ThemeColor.surfaceColor,
              borderRadius: ThemeColor.mediumBorderRadius,
              boxShadow: [ThemeColor.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adeudo',
                  style: ThemeColor.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: ThemeColor.paddingSmall),
                Obx(() => _ToggleGroup(
                      options: const ['Todos', 'Con adeudo',  ],
                      // null=0, true=1, false=2
                      selectedIndex: controller.filterPorCobrar.value == null
                          ? 0
                          : controller.filterPorCobrar.value == true
                              ? 1
                              : 2,
                      onChanged: (i) {
                        if (i == 0) controller.filterPorCobrar.value = null;
                        if (i == 1) controller.filterPorCobrar.value = true;
                        if (i == 2) controller.filterPorCobrar.value = false;
                      },
                    )),
              ],
            ),
          ),

          const SizedBox(height: ThemeColor.paddingMedium),

          // Botones
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingMedium,
            ),
            child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: ThemeColor.widgetButton(
                        text: 'Limpiar (${controller.activeFilters})',
                        onPressed: () {
                          controller.onFilterClear();
                          Navigator.of(context).pop();
                        },
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
                          controller.applyFilterSheet();
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
                )),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Toggle group (reutilizable)
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// Tile
// ─────────────────────────────────────────────
class _ClienteTile extends StatelessWidget {
  final ClientEntity cliente;
  const _ClienteTile({required this.cliente});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ClientController>();
    final tieneAdeudo = (cliente.owes ?? 0) > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: ThemeColor.paddingSmall + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.cleanName,
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.infoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tieneAdeudo) ...[
                  const SizedBox(height: 4),
                  Text(
                    '\$${cliente.owes!.toStringAsFixed(2)}',
                    style: ThemeColor.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (tieneAdeudo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeColor.paddingSmall + 2,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColor.errorColor.withOpacity(0.85),
                    borderRadius: ThemeColor.circularBorderRadius,
                  ),
                  child: Text(
                    '\$${cliente.owes!.toStringAsFixed(2)} adeudo',
                    style: ThemeColor.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (tieneAdeudo) const SizedBox(height: 6),
              Obx(() {
                final isLoading =
                    ctrl.loadingPdfClientId.value == cliente.id;
                return GestureDetector(
                  onTap: () => _showDateRangeSheet(context, ctrl),
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

  void _showDateRangeSheet(BuildContext context, ClientController ctrl) {
    final dateFrom = ''.obs;
    final dateUntil = ''.obs;

    Future<void> pickDate(RxString target) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
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
        target.value =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(ThemeColor.largeRadius),
          ),
        ),
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).padding.bottom + ThemeColor.paddingLarge,
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
                  Text('Estado de Cuenta', style: ThemeColor.headingSmall),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Desde',
                            style: ThemeColor.bodySmall.copyWith(
                              color: ThemeColor.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => _DatePickerField(
                                value: dateFrom.value,
                                onTap: () => pickDate(dateFrom),
                              )),
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
                          Obx(() => _DatePickerField(
                                value: dateUntil.value,
                                onTap: () => pickDate(dateUntil),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: ThemeColor.paddingMedium),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingMedium,
              ),
              child: Obx(() {
                final canGenerate =
                    dateFrom.value.isNotEmpty && dateUntil.value.isNotEmpty;
                return AnimatedOpacity(
                  opacity: canGenerate ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 250),
                  child: ThemeColor.widgetButton(
                    text: 'Generar PDF',
                    onPressed: canGenerate
                        ? () {
                            Navigator.of(context).pop();
                            ctrl.openAccountStatementPdf(
                              context,
                              cliente.id,
                              cliente.cleanName,
                              dateFrom.value,
                              dateUntil.value,
                            );
                          }
                        : null,
                    backgroundColor: ThemeColor.primaryColor,
                    textColor: ThemeColor.textLightColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeColor.paddingSmall + 4,
                    ),
                    borderRadius: ThemeColor.smallRadius,
                    customShadow: ThemeColor.darkShadow,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget campo fecha
// ─────────────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  const _DatePickerField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
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
                value.isEmpty ? 'DD/MM/AAAA' : value,
                style: ThemeColor.bodySmall.copyWith(
                  color: value.isEmpty
                      ? ThemeColor.textSecondaryColor
                      : ThemeColor.textPrimaryColor,
                ),
              ),
            ),
            const Icon(
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

// ─────────────────────────────────────────────
// Sheet nuevo cliente
// ─────────────────────────────────────────────
class _NuevoClienteSheet extends StatefulWidget {
  final ClientController controller;
  const _NuevoClienteSheet({required this.controller});

  @override
  State<_NuevoClienteSheet> createState() => _NuevoClienteSheetState();
}

class _NuevoClienteSheetState extends State<_NuevoClienteSheet> {
  ClientController get _ctrl => widget.controller;

  void _onFieldChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _ctrl.resetForm();
    _ctrl.empresaCtrl.addListener(_onFieldChanged);
    _ctrl.nombreCtrl.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _ctrl.empresaCtrl.removeListener(_onFieldChanged);
    _ctrl.nombreCtrl.removeListener(_onFieldChanged);
    super.dispose();
  }

  Future<void> _onGuardar() async {
    FocusScope.of(context).unfocus();
    await _ctrl.createClient();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColor.backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(ThemeColor.largeRadius),
            ),
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
                    Text('Nuevo Cliente', style: ThemeColor.headingSmall),
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
              Flexible(
                child: SingleChildScrollView(
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
                        Text(
                          'Información del Cliente',
                          style: ThemeColor.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: ThemeColor.paddingMedium),
                        ThemeColor.createLabeledTextField(
                          label: 'Empresa',
                          controller: _ctrl.empresaCtrl,
                          focusNode: _ctrl.empresaFocus,
                          borderRadius: ThemeColor.smallBorderRadius,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [UpperCaseTextFormatter()],
                          isRequired: true,
                          onSubmitted: (_) => _ctrl.nombreFocus.requestFocus(),
                        ),
                        const SizedBox(height: ThemeColor.paddingMedium),
                        ThemeColor.createLabeledTextField(
                          label: 'Nombre del Cliente o Representante',
                          controller: _ctrl.nombreCtrl,
                          focusNode: _ctrl.nombreFocus,
                          borderRadius: ThemeColor.smallBorderRadius,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [UpperCaseTextFormatter()],
                          isRequired: true,
                          onSubmitted: (_) =>
                              _ctrl.telefonoFocus.requestFocus(),
                        ),
                        const SizedBox(height: ThemeColor.paddingMedium),
                        ThemeColor.createLabeledTextField(
                          label: 'Teléfono',
                          controller: _ctrl.telefonoCtrl,
                          focusNode: _ctrl.telefonoFocus,
                          keyboardType: TextInputType.phone,
                          borderRadius: ThemeColor.smallBorderRadius,
                          onSubmitted: (_) => _ctrl.emailFocus.requestFocus(),
                        ),
                        const SizedBox(height: ThemeColor.paddingMedium),
                        ThemeColor.createLabeledTextField(
                          label: 'Email',
                          controller: _ctrl.emailCtrl,
                          focusNode: _ctrl.emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          borderRadius: ThemeColor.smallBorderRadius,
                          onSubmitted: (_) => _onGuardar(),
                        ),
                        Obx(() {
                          if (_ctrl.createError.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: ThemeColor.paddingSmall,
                            ),
                            child: Text(
                              _ctrl.createError.value,
                              style: ThemeColor.bodySmall.copyWith(
                                color: ThemeColor.errorColor,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: ThemeColor.paddingMedium),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeColor.paddingMedium,
                ),
                child: Obx(
                  () => AnimatedOpacity(
                    opacity: _ctrl.isFormValid ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 250),
                    child: ThemeColor.widgetButton(
                      text: 'Guardar Cliente',
                      isLoading: _ctrl.isCreating.value,
                      onPressed: _ctrl.isFormValid ? _onGuardar : null,
                      backgroundColor: ThemeColor.primaryColor,
                      textColor: ThemeColor.textLightColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      padding: const EdgeInsets.symmetric(
                        vertical: ThemeColor.paddingSmall + 4,
                      ),
                      borderRadius: ThemeColor.smallRadius,
                      customShadow: ThemeColor.darkShadow,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: ThemeColor.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }
}