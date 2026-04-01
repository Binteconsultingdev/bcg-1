import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// import 'package:tu_app/core/theme/theme_color.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modelo
// ─────────────────────────────────────────────────────────────────────────────
class ClienteItem {
  final String nombre;
  final String fecha;
  final double totalVentas;
  final double adeudo;

  const ClienteItem({
    required this.nombre,
    required this.fecha,
    required this.totalVentas,
    this.adeudo = 0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla Clientes
// ─────────────────────────────────────────────────────────────────────────────
class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<ClienteItem> _clientes = const [
    ClienteItem(
      nombre: '(48) AUTOTRANSPORTES LA FLECHA',
      fecha: '03/03/2026',
      totalVentas: 350.00,
      adeudo: 566.00,
    ),
  ];

  List<ClienteItem> get _filtered => _clientes
      .where((c) =>
          c.nombre.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  void _openNuevoCliente() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NuevoClienteSheet(
        onGuardar: (data) {
          // TODO: agregar cliente a la lista / controlador GetX
          Navigator.of(context).pop();
        },
      ),
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
            const SizedBox(height: ThemeColor.paddingSmall),
            _buildAgregarBtn(),
            const SizedBox(height: ThemeColor.paddingSmall),
            Expanded(child: _buildList()),
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
      title: Text('Clientes', style: ThemeColor.headingSmall),
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

  // ── Barra búsqueda ──────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: ThemeColor.circularBorderRadius,
          border: Border.all(color: ThemeColor.dividerColor),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: ThemeColor.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Buscar cliente',
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
    );
  }

  // ── Botón Agregar Cliente ───────────────────────────────────────────────
  Widget _buildAgregarBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingMedium),
      child: ThemeColor.widgetButton(
        text: 'Agregar Cliente',
        onPressed: _openNuevoCliente,
        backgroundColor: ThemeColor.primaryColor,
        textColor: ThemeColor.textLightColor,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        padding: const EdgeInsets.symmetric(
            vertical: ThemeColor.paddingSmall + 4),
        borderRadius: ThemeColor.smallRadius,
        customShadow: ThemeColor.darkShadow,
      ),
    );
  }

  // ── Lista de clientes ───────────────────────────────────────────────────
  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Text('Sin clientes',
            style: ThemeColor.bodyMedium
                .copyWith(color: ThemeColor.textSecondaryColor)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: ThemeColor.dividerColor),
      itemBuilder: (_, i) => _ClienteTile(cliente: items[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile de cliente
// ─────────────────────────────────────────────────────────────────────────────
class _ClienteTile extends StatelessWidget {
  final ClienteItem cliente;
  const _ClienteTile({required this.cliente});

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
                // Nombre en azul
                Text(
                  cliente.nombre,
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.infoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(cliente.fecha,
                    style: ThemeColor.caption
                        .copyWith(color: ThemeColor.textSecondaryColor)),
                const SizedBox(height: 4),
                Text(
                  '\$${cliente.totalVentas.toStringAsFixed(2)}',
                  style: ThemeColor.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Badge adeudo (solo si tiene adeudo)
          if (cliente.adeudo > 0)
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
                '\$${cliente.adeudo.toStringAsFixed(2)} adeudo',
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

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet Nuevo Cliente
// ─────────────────────────────────────────────────────────────────────────────
class _NuevoClienteSheet extends StatefulWidget {
  final void Function(Map<String, String> data) onGuardar;
  const _NuevoClienteSheet({required this.onGuardar});

  @override
  State<_NuevoClienteSheet> createState() => _NuevoClienteSheetState();
}

class _NuevoClienteSheetState extends State<_NuevoClienteSheet> {
  final _empresaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _empresaFocus = FocusNode();
  final _nombreFocus = FocusNode();
  final _telefonoFocus = FocusNode();
  final _emailFocus = FocusNode();

  bool _isLoading = false;

  bool get _isValid =>
      _empresaCtrl.text.trim().isNotEmpty &&
      _nombreCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _empresaCtrl.dispose();
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _empresaFocus.dispose();
    _nombreFocus.dispose();
    _telefonoFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _onGuardar() async {
    if (!_isValid) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
    widget.onGuardar({
      'empresa': _empresaCtrl.text.trim(),
      'nombre': _nombreCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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
            // Handle
            Container(
              margin: const EdgeInsets.only(top: ThemeColor.paddingSmall),
              width: 40, height: 4,
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
                  Text('Nuevo Cliente', style: ThemeColor.headingSmall),
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

            // Formulario
            Flexible(
              child: SingleChildScrollView(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Información del Cliente',
                          style: ThemeColor.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: ThemeColor.paddingMedium),

                      ThemeColor.createLabeledTextField(
                        label: 'Empresa',
                        controller: _empresaCtrl,
                        focusNode: _empresaFocus,
                        borderRadius: ThemeColor.smallBorderRadius,
                        isRequired: true,
                        onSubmitted: (_) =>
                            _nombreFocus.requestFocus(),
                      ),
                      const SizedBox(height: ThemeColor.paddingMedium),

                      ThemeColor.createLabeledTextField(
                        label: 'Nombre del Cliente o Respresentante',
                        controller: _nombreCtrl,
                        focusNode: _nombreFocus,
                        borderRadius: ThemeColor.smallBorderRadius,
                        isRequired: true,
                        onSubmitted: (_) =>
                            _telefonoFocus.requestFocus(),
                      ),
                      const SizedBox(height: ThemeColor.paddingMedium),

                      ThemeColor.createLabeledTextField(
                        label: 'Teléfono',
                        controller: _telefonoCtrl,
                        focusNode: _telefonoFocus,
                        keyboardType: TextInputType.phone,
                        borderRadius: ThemeColor.smallBorderRadius,
                        onSubmitted: (_) =>
                            _emailFocus.requestFocus(),
                      ),
                      const SizedBox(height: ThemeColor.paddingMedium),

                      ThemeColor.createLabeledTextField(
                        label: 'Email',
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        borderRadius: ThemeColor.smallBorderRadius,
                        onSubmitted: (_) => _onGuardar(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: ThemeColor.paddingMedium),

            // Botón guardar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: ThemeColor.paddingMedium),
              child: AnimatedOpacity(
                opacity: _isValid ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 250),
                child: ThemeColor.widgetButton(
                  text: 'Guardar Cliente',
                  isLoading: _isLoading,
                  onPressed: _isValid ? _onGuardar : null,
                  backgroundColor: ThemeColor.primaryColor,
                  textColor: ThemeColor.textLightColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  padding: const EdgeInsets.symmetric(
                      vertical: ThemeColor.paddingSmall + 4),
                  borderRadius: ThemeColor.smallRadius,
                  customShadow: ThemeColor.darkShadow,
                ),
              ),
            ),
            const SizedBox(height: ThemeColor.paddingLarge),
          ],
        ),
      ),
    );
  }
}