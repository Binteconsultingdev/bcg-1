import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/controller/product_search_controller.dart';
import 'package:bcg/common/widgets/product_search_field.dart';
import 'package:bcg/common/widgets/product_search_results.dart';
import 'package:bcg/features/client/presentation/page/client_search_field.dart';
import 'package:bcg/features/quotes/presentation/controller/put_quotes_controller.dart';
import 'package:bcg/features/sales/presentation/page/quote_product_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EditQuotePage extends StatelessWidget {
  const EditQuotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final PutQuotesController ctrl = Get.find<PutQuotesController>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: ThemeColor.backgroundColor,
        appBar: _AppBar(ctrl: ctrl),
        body: Obx(() {
          if (ctrl.isLoadingQuote.value) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeColor.primaryColor),
            );
          }
          return Column(
            children: [
              if (!ctrl.isEditable)
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cotización ${ctrl.quoteStatus.value} · Solo las cotizaciones GENERADA pueden editarse.',
                          style: ThemeColor.bodySmall.copyWith(
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      _TopSection(ctrl: ctrl),
                      _sectionGap(),
                      _ProductList(ctrl: ctrl),
                      _TotalsSection(ctrl: ctrl),
                      _sectionGap(),
                    //  _ValidUntilSection(ctrl: ctrl),
                      _sectionGap(),
                      _CommentsSection(ctrl: ctrl),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _BottomButton(ctrl: ctrl),
            ],
          );
        }),
      ),
    );
  }

  static Widget _sectionGap() =>
      Container(height: 8, color: ThemeColor.backgroundColor);
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final PutQuotesController ctrl;
  const _AppBar({required this.ctrl});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeColor.surfaceColor,
      foregroundColor: ThemeColor.textPrimaryColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: ThemeColor.textPrimaryColor,
          size: 20,
        ),
      ),
      title: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Editar Cotización', style: ThemeColor.headingSmall),
            if (ctrl.folio.value.isNotEmpty)
              Text(
                'Folio: ${ctrl.folio.value}',
                style: ThemeColor.caption.copyWith(
                  color: ThemeColor.textSecondaryColor,
                ),
              ),
          ],
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: ThemeColor.dividerColor),
      ),
    );
  }
}

class _TopSection extends StatelessWidget {
  final PutQuotesController ctrl;
  const _TopSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall,
      ),
      child: Column(
        children: [
          _RowField(
            label: 'Cliente',
            child: ClientSearchField(onSelected: ctrl.onClientSelected),
          ),
          ClientSearchResults(onSelected: ctrl.onClientSelected),
          Divider(height: 1, color: ThemeColor.dividerColor),
          _RowField(
            label: 'Precio',
            child: _PriceSelector(ctrl: ctrl),
          ),
          Divider(height: 1, color: ThemeColor.dividerColor),
          _RowField(
            label: 'Producto',
            child: ProductSearchField(onSelected: ctrl.addProduct),
          ),
          ProductSearchResults(onSelected: ctrl.addProduct),
          const SizedBox(height: 4),
          /* GestureDetector(
            onTap: () => ctrl.showAddCustomProductDialog(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    size: 18,
                    color: ThemeColor.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Agregar producto personalizado',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),*/
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _ShippingOptionCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Paquete y Embalaje',
                        isSelected: ctrl.selectedShippingOptions.contains(
                          'paquete',
                        ),
                        onTap: () => ctrl.toggleShippingOption('paquete'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => _ShippingOptionCard(
                        icon: Icons.local_shipping_outlined,
                        label: 'Envío de Productos',
                        isSelected: ctrl.selectedShippingOptions.contains(
                          'envio',
                        ),
                        onTap: () {
                          ctrl.toggleShippingOption('envio');
                        },
                      ),
                    ),
                  ),
                ],
              ),

              Obx(() {
                if (!ctrl.selectedShippingOptions.contains('paquete')) {
                  return const SizedBox.shrink();
                }
                return AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.primaryColor.withOpacity(0.06),
                      borderRadius: ThemeColor.smallBorderRadius,
                      border: Border.all(
                        color: ThemeColor.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Porcentaje de embalaje',
                          style: ThemeColor.bodySmall.copyWith(
                            color: ThemeColor.textSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Row(
                            children: [1.5, 2.0, 3.0].map((pct) {
                              final isSelected =
                                  ctrl.selectedPackagePercent.value == pct;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () =>
                                      ctrl.selectedPackagePercent.value = pct,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? ThemeColor.primaryColor
                                          : ThemeColor.surfaceColor,
                                      borderRadius:
                                          ThemeColor.circularBorderRadius,
                                      border: Border.all(
                                        color: isSelected
                                            ? ThemeColor.primaryColor
                                            : ThemeColor.dividerColor,
                                      ),
                                    ),
                                    child: Text(
                                      '$pct%',
                                      style: ThemeColor.bodyMedium.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : ThemeColor.textPrimaryColor,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
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

class _ShippingOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShippingOptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColor.primaryColor.withOpacity(0.08)
              : ThemeColor.surfaceColor,
          borderRadius: ThemeColor.smallBorderRadius,
          border: Border.all(
            color: isSelected
                ? ThemeColor.primaryColor
                : ThemeColor.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? ThemeColor.primaryColor
                  : ThemeColor.textSecondaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: ThemeColor.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? ThemeColor.primaryColor
                    : ThemeColor.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowField extends StatelessWidget {
  final String label;
  final Widget child;
  const _RowField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: ThemeColor.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: ThemeColor.textPrimaryColor,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _PriceSelector extends StatelessWidget {
  final PutQuotesController ctrl;
  const _PriceSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => Get.bottomSheet(
          _PriceBottomSheet(ctrl: ctrl),
          isScrollControlled: true,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: ThemeColor.backgroundColor,
            borderRadius: ThemeColor.extraLargeBorderRadius,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  ctrl.selectedPriceType.value,
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: ThemeColor.textSecondaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceBottomSheet extends StatelessWidget {
  final PutQuotesController ctrl;
  const _PriceBottomSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeColor.paddingMedium),
      decoration: const BoxDecoration(
        color: ThemeColor.surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeColor.largeRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: ThemeColor.paddingMedium),
            child: Text('Tipo de precio', style: ThemeColor.headingSmall),
          ),
          ...ctrl.priceOptions.map(
            (opt) => Obx(
              () => ListTile(
                title: Text(opt, style: ThemeColor.bodyLarge),
                trailing: ctrl.selectedPriceType.value == opt
                    ? const Icon(Icons.check, color: ThemeColor.accentColor)
                    : null,
                onTap: () {
                  ctrl.selectedPriceType.value = opt;
                  Get.back();
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final PutQuotesController ctrl;
  const _ProductList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final visibleItems = ctrl.items
          .where(
            (i) => i.codigo.value != 'ARTEMP01' && i.codigo.value != 'ARTENV01',
          )
          .toList();

      if (visibleItems.isEmpty) return const SizedBox.shrink();

      return Container(
        color: ThemeColor.surfaceColor,
        child: Column(
          children: visibleItems.asMap().entries.map((entry) {
            final isLast = entry.key == visibleItems.length - 1;
            final item = entry.value;
            return Column(
              children: [
                QuoteProductItem(
                  imageUrl: item.localImagePath.value ?? item.url,
                  description: item.descripcion.value,
                  unitPrice: item.precio.value,
                  total: item.totalRx,
                  quantity: item.quantity,
                  availableQuantity: item.disponible,
                  discount: item.descuento,
                  onDiscountTap: () =>
                      ctrl.showItemDiscountDialog(context, item),
                  onRemove: () => ctrl.removeItem(item),
                  onQuantityChanged: (v) {
                    item.quantity.value = v;
                    ctrl.validateCart();
                  },
                  onEdit: item.isCustom
                      ? () => ctrl.showEditCustomProductDialog(context, item)
                      : null,
                  onEditPriceTap: () => ctrl.showEditPriceDialog(context, item),
                ),

                if (!isLast)
                  Divider(
                    height: 1,
                    color: ThemeColor.dividerColor,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }).toList(),
        ),
      );
    });
  }
}

class _TotalsSection extends StatelessWidget {
  final PutQuotesController ctrl;
  const _TotalsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Obx(
        () => Column(
          children: [
            _TotalRow(
              label: 'Subtotal',
              value: '\$${ctrl.subtotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _showDiscountDialog(context),
                  child: Text(
                    ctrl.globalDiscount.value > 0
                        ? ctrl.globalDiscountType.value == 'porcentaje'
                              ? 'Descuento ${ctrl.globalDiscountPercent.value.toInt()}% aplicado'
                              : 'Descuento aplicado'
                        : 'Agregar un Descuento',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  ctrl.globalDiscount.value > 0
                      ? '-\$${ctrl.globalDiscount.value.toStringAsFixed(2)}'
                      : '\$0.00',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.errorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('I.V.A (16%)', style: ThemeColor.bodyMedium),
                Row(
                  children: [
                    Text(
                      '\$${ctrl.ivaAmount.toStringAsFixed(2)}',
                      style: ThemeColor.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: ctrl.includeIva.value,
                      onChanged: (v) => ctrl.includeIva.value = v,
                      activeColor: ThemeColor.primaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),

            Divider(height: 20, color: ThemeColor.dividerColor),

            if (ctrl.isValidatingCart.value)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ThemeColor.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Validando precios...',
                      style: ThemeColor.bodySmall.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            if (ctrl.isValidatingCart.value)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ThemeColor.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Validando precios...',
                      style: ThemeColor.bodySmall.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

            if (ctrl.selectedShippingOptions.contains('envio'))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _showEnvioDialog(context),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            size: 15,
                            color: ThemeColor.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Costo de envío',
                            style: ThemeColor.bodyMedium.copyWith(
                              color: ThemeColor.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.edit_outlined,
                            size: 13,
                            color: ThemeColor.primaryColor,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      ctrl.envio.value != null
                          ? '\$${ctrl.envio.value!.toStringAsFixed(2)}'
                          : '\$0.00',
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            if (ctrl.selectedShippingOptions.contains('paquete') &&
                ctrl.selectedPackagePercent.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 15,
                          color: ThemeColor.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Embalaje ${ctrl.selectedPackagePercent.value!.toString().replaceAll('.0', '')}%',
                          style: ThemeColor.bodyMedium.copyWith(
                            color: ThemeColor.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${ctrl.embalajeAmount.toStringAsFixed(2)}',
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            _TotalRow(
              label: 'Total a pagar',
              value: '\$${ctrl.totalToPay.toStringAsFixed(2)}',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showEnvioDialog(BuildContext context) {
    final envioCtrl = TextEditingController(
      text: ctrl.envio.value != null && ctrl.envio.value! > 0
          ? ctrl.envio.value!.toStringAsFixed(2)
          : '',
    );
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColor.surfaceColor,
        title: Text('Costo de envío', style: ThemeColor.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: envioCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[-]')),
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '\$ ',
                labelText: 'Monto de envío',
                border: OutlineInputBorder(
                  borderRadius: ThemeColor.smallBorderRadius,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: ThemeColor.smallBorderRadius,
                  borderSide: const BorderSide(
                    color: ThemeColor.accentColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [50, 100, 150, 200, 300, 500].map((monto) {
                return GestureDetector(
                  onTap: () {
                    envioCtrl.text = monto.toString();
                    envioCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: envioCtrl.text.length),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.backgroundColor,
                      borderRadius: ThemeColor.circularBorderRadius,
                      border: Border.all(color: ThemeColor.dividerColor),
                    ),
                    child: Text(
                      '\$$monto',
                      style: ThemeColor.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: ThemeColor.textSecondaryColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColor.primaryColor,
            ),
            onPressed: () {
              final valor = double.tryParse(envioCtrl.text) ?? 0.0;
              ctrl.envio.value = valor < 0 ? 0.0 : valor;
              Get.back();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog(BuildContext context) {
    final RxString mode = ctrl.globalDiscountType.value.obs;

    Get.dialog(
      Obx(
        () => AlertDialog(
          backgroundColor: ThemeColor.surfaceColor,
          title: Text('Descuento global', style: ThemeColor.headingSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ThemeColor.backgroundColor,
                  borderRadius: ThemeColor.smallBorderRadius,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => mode.value = 'monto',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: mode.value == 'monto'
                                ? ThemeColor.primaryColor
                                : Colors.transparent,
                            borderRadius: ThemeColor.smallBorderRadius,
                          ),
                          child: Text(
                            'Monto fijo',
                            textAlign: TextAlign.center,
                            style: ThemeColor.bodySmall.copyWith(
                              color: mode.value == 'monto'
                                  ? Colors.white
                                  : ThemeColor.textSecondaryColor,
                              fontWeight: mode.value == 'monto'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => mode.value = 'porcentaje',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: mode.value == 'porcentaje'
                                ? ThemeColor.primaryColor
                                : Colors.transparent,
                            borderRadius: ThemeColor.smallBorderRadius,
                          ),
                          child: Text(
                            'Porcentaje',
                            textAlign: TextAlign.center,
                            style: ThemeColor.bodySmall.copyWith(
                              color: mode.value == 'porcentaje'
                                  ? Colors.white
                                  : ThemeColor.textSecondaryColor,
                              fontWeight: mode.value == 'porcentaje'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ThemeColor.paddingMedium),
              if (mode.value == 'monto')
                TextField(
                  controller: ctrl.globalDiscountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[-]')),
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  style: ThemeColor.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(
                      borderRadius: ThemeColor.mediumBorderRadius,
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: ThemeColor.mediumBorderRadius,
                      borderSide: const BorderSide(
                        color: ThemeColor.accentColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              if (mode.value == 'porcentaje')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecciona el porcentaje',
                      style: ThemeColor.bodySmall.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [0, 5, 10, 15, 20, 25, 30].map((pct) {
                          final selected =
                              ctrl.globalDiscountPercent.value ==
                              pct.toDouble();
                          return GestureDetector(
                            onTap: () => ctrl.globalDiscountPercent.value = pct
                                .toDouble(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? ThemeColor.primaryColor
                                    : ThemeColor.backgroundColor,
                                borderRadius: ThemeColor.circularBorderRadius,
                                border: Border.all(
                                  color: selected
                                      ? ThemeColor.primaryColor
                                      : ThemeColor.dividerColor,
                                ),
                              ),
                              child: Text(
                                pct == 0 ? 'Sin desc.' : '$pct%',
                                style: ThemeColor.bodyMedium.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : ThemeColor.textPrimaryColor,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => ctrl.globalDiscountPercent.value > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeColor.errorColor.withOpacity(0.08),
                                borderRadius: ThemeColor.smallBorderRadius,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Descuento ${ctrl.globalDiscountPercent.value.toInt()}%',
                                    style: ThemeColor.bodySmall.copyWith(
                                      color: ThemeColor.errorColor,
                                    ),
                                  ),
                                  Text(
                                    '-\$${(ctrl.subtotal * (ctrl.globalDiscountPercent.value / 100)).toStringAsFixed(2)}',
                                    style: ThemeColor.bodySmall.copyWith(
                                      color: ThemeColor.errorColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ctrl.globalDiscountPercent.value = 0;
                Get.back();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: ThemeColor.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.primaryColor,
              ),
              onPressed: () {
                if (mode.value == 'monto') {
                  ctrl.applyGlobalDiscount(
                    double.tryParse(ctrl.globalDiscountCtrl.text) ?? 0,
                  );
                } else {
                  ctrl.applyGlobalDiscount(
                    ctrl.globalDiscountPercent.value,
                    isPercent: true,
                  );
                }
                Get.back();
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? ThemeColor.subtitleLarge.copyWith(fontWeight: FontWeight.w700)
        : ThemeColor.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}

class _ValidUntilSection extends StatelessWidget {
  final PutQuotesController ctrl;
  const _ValidUntilSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Row(
        children: [
          Text(
            'Válida hasta',
            style: ThemeColor.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeColor.textPrimaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: () => ctrl.pickDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColor.backgroundColor,
                    borderRadius: ThemeColor.smallBorderRadius,
                    border: Border.all(color: ThemeColor.dividerColor),
                  ),
                  child: Text(
                    _fmt(ctrl.validUntil.value),
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.textSecondaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

class _CommentsSection extends StatelessWidget {
  final PutQuotesController ctrl;
  const _CommentsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comentarios',
            style: ThemeColor.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeColor.textPrimaryColor,
            ),
          ),
          const SizedBox(height: ThemeColor.paddingSmall),
          TextField(
            controller: ctrl.commentsCtrl,
            maxLines: 4,
            maxLength: 500,
            style: ThemeColor.bodyMedium,
            decoration: InputDecoration(
              filled: true,
              fillColor: ThemeColor.surfaceColor,
              contentPadding: const EdgeInsets.all(ThemeColor.paddingMedium),
              border: OutlineInputBorder(
                borderRadius: ThemeColor.smallBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ThemeColor.smallBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ThemeColor.smallBorderRadius,
                borderSide: const BorderSide(
                  color: ThemeColor.accentColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final PutQuotesController ctrl;
  const _BottomButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      color: ThemeColor.surfaceColor,
      padding: EdgeInsets.fromLTRB(
        ThemeColor.paddingMedium,
        ThemeColor.paddingSmall,
        ThemeColor.paddingMedium,
        ThemeColor.paddingLarge + bottomPadding,
      ),
      child: Obx(() {
        if (ctrl.isEditable) {
          return SizedBox(
            width: double.infinity,
            child: ThemeColor.widgetButton(
              text: 'Guardar y ver PDF',
              backgroundColor: ThemeColor.primaryColor,
              textColor: ThemeColor.textLightColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: ThemeColor.mediumRadius,
              isLoading: ctrl.isSaving.value || ctrl.isLoadingPdf,
              onPressed: () => ctrl.saveQuote(context),
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ThemeColor.widgetButton(
            text: 'Ver PDF',
            backgroundColor: ThemeColor.accentColor,
            textColor: ThemeColor.textLightColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            borderRadius: ThemeColor.mediumRadius,
            isLoading: ctrl.isLoadingPdf,
            onPressed: () => ctrl.generateAndOpenPdf(context),
          ),
        );
      }),
    );
  }
}
