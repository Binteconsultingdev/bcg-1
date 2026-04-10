import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
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
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ThemeColor.backgroundColor,
          borderRadius: ThemeColor.circularBorderRadius,
          border: Border.all(color: ThemeColor.dividerColor),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => _ctrl.fetchClients(client: v),
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

class _ClienteTile extends StatelessWidget {
  final ClientEntity cliente;
  const _ClienteTile({required this.cliente});

  @override
  Widget build(BuildContext context) {
    final tieneAdeudo = (cliente.owes ?? 0) > 0;

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
        ],
      ),
    );
  }
}

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
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
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
                          isRequired: true,
                          onSubmitted: (_) => _ctrl.nombreFocus.requestFocus(),
                        ),
                        const SizedBox(height: ThemeColor.paddingMedium),

                        ThemeColor.createLabeledTextField(
                          label: 'Nombre del Cliente o Representante',
                          controller: _ctrl.nombreCtrl,
                          focusNode: _ctrl.nombreFocus,
                          borderRadius: ThemeColor.smallBorderRadius,
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
