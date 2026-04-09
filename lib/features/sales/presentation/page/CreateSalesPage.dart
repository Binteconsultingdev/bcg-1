import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/product_search_field.dart';
import 'package:bcg/common/widgets/product_search_results.dart';
import 'package:bcg/features/client/presentation/page/client_search_field.dart';
import 'package:bcg/features/sales/presentation/controller/create_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CreateSalesPage extends StatelessWidget {
  const CreateSalesPage({super.key});
@override
Widget build(BuildContext context) {
  final CreateSalesController ctrl = Get.find<CreateSalesController>();

  return GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus(); // 👈 cierra teclado
    },
    child: Scaffold(
      backgroundColor: ThemeColor.backgroundColor,
      appBar: _AppBar(ctrl: ctrl),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  _TopSection(ctrl: ctrl),
                  _sectionGap(),
                  _ProductList(ctrl: ctrl),
                  _TotalsSection(ctrl: ctrl),
                  _sectionGap(),
                  _DeliverySection(ctrl: ctrl),
                  _sectionGap(),
                  _ExtraFieldsSection(ctrl: ctrl),
                  _sectionGap(),
                  _CommentsSection(ctrl: ctrl),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _BottomButton(ctrl: ctrl),
        ],
      ),
    ),
  );
}
  static Widget _sectionGap() =>
      Container(height: 8, color: ThemeColor.backgroundColor);
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final CreateSalesController ctrl;
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
      title: Text('Crear Venta', style: ThemeColor.headingSmall),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: ThemeColor.dividerColor),
      ),
    );
  }
}

class _QuoteSelector extends StatelessWidget {
  final CreateSalesController ctrl;
  const _QuoteSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => ThemeColor.searchTextField(
                  controller: ctrl.quoteSearchCtrl,
                  hintText: ctrl.selectedFolioQuote.value.isNotEmpty
                      ? 'Folio: ${ctrl.selectedFolioQuote.value}'
                      : 'Buscar por folio',

                  prefixIcon: Icons.receipt_long_outlined,
                  isLoading: ctrl.isSearchingQuoteApi.value,
                  hasText:
                      ctrl.isSearchingQuote.value ||
                      ctrl.selectedFolioQuote.value.isNotEmpty,
                  onChanged: ctrl.onQuoteSearchChanged,
                  onClear: () {
                    ctrl.selectedFolioQuote.value = '';
                    ctrl.quoteSearchCtrl.clear();
                    ctrl.onQuoteSearchChanged('');
                    ctrl.quoteResults.clear();
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopSection extends StatelessWidget {
  final CreateSalesController ctrl;
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
            label: 'Cotiz.',
            child: _QuoteSelector(ctrl: ctrl),
          ),
          Obx(() {
            if (!ctrl.isSearchingQuote.value && ctrl.quoteResults.isEmpty) {
              return const SizedBox.shrink();
            }
            if (ctrl.isSearchingQuoteApi.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: CircularProgressIndicator(
                    color: ThemeColor.primaryColor,
                  ),
                ),
              );
            }
            if (ctrl.quoteResults.isEmpty && ctrl.isSearchingQuote.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Sin cotizaciones', style: ThemeColor.bodySmall),
              );
            }
            return Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: ThemeColor.surfaceColor,
                borderRadius: ThemeColor.smallBorderRadius,
                border: Border.all(color: ThemeColor.dividerColor),
                boxShadow: [ThemeColor.lightShadow],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: ctrl.quoteResults.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: ThemeColor.dividerColor),
                itemBuilder: (_, i) {
                  final q = ctrl.quoteResults[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.receipt_outlined,
                      color: ThemeColor.primaryColor,
                      size: 20,
                    ),
                    title: Text(
                      '${q.folito ?? '-'} · ${q.client ?? '-'}',
                      style: ThemeColor.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '\$${q.total?.toStringAsFixed(2) ?? '0.00'} · ${q.date ?? ''}',
                      style: ThemeColor.caption,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: ThemeColor.textSecondaryColor,
                      size: 14,
                    ),
                    onTap: () => ctrl.loadFromQuote(q),
                  );
                },
              ),
            );
          }),
          Divider(height: 1, color: ThemeColor.dividerColor),
          _RowField(
            label: 'Método',
            child: _MetodoEmbarqueSelector(ctrl: ctrl),
          ),
          Divider(height: 1, color: ThemeColor.dividerColor),
          _RowField(
            label: 'Producto',
            child: ProductSearchField(onSelected: ctrl.addProduct),
          ),
          ProductSearchResults(onSelected: ctrl.addProduct),
        ],
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

class _MetodoEmbarqueSelector extends StatelessWidget {
  final CreateSalesController ctrl;
  const _MetodoEmbarqueSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => Get.bottomSheet(
          _MetodoBottomSheet(ctrl: ctrl),
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
                  ctrl.metodoEmbarque.value,
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

class _MetodoBottomSheet extends StatelessWidget {
  final CreateSalesController ctrl;
  const _MetodoBottomSheet({required this.ctrl});

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
            child: Text('Método de embarque', style: ThemeColor.headingSmall),
          ),
          ...ctrl.metodosEmbarque.map(
            (opt) => Obx(
              () => ListTile(
                title: Text(opt, style: ThemeColor.bodyLarge),
                trailing: ctrl.metodoEmbarque.value == opt
                    ? const Icon(Icons.check, color: ThemeColor.accentColor)
                    : null,
                onTap: () {
                  ctrl.metodoEmbarque.value = opt;
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
  final CreateSalesController ctrl;
  const _ProductList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.items.isEmpty) return const SizedBox.shrink();
      return Container(
        color: ThemeColor.surfaceColor,
        child: Column(
          children: ctrl.items.asMap().entries.map((entry) {
            final isLast = entry.key == ctrl.items.length - 1;
            return Column(
              children: [
                _ProductItem(ctrl: ctrl, item: entry.value),
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

class _ProductItem extends StatelessWidget {
  final CreateSalesController ctrl;
  final SaleItem item;
  const _ProductItem({required this.ctrl, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductThumbnail(imageUrl: item.product.imageUrl, size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.description ?? '',
                  style: ThemeColor.subtitleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)}',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                _QuantityControls(ctrl: ctrl, item: item),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => ctrl.removeItem(item),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    color: ThemeColor.errorColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Obx(
                () => Text(
                  '\$${item.total.toStringAsFixed(2)}',
                  style: ThemeColor.subtitleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityControls extends StatefulWidget {
  final CreateSalesController ctrl;
  final SaleItem item;
  const _QuantityControls({required this.ctrl, required this.item});

  @override
  State<_QuantityControls> createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<_QuantityControls> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(
      text: widget.item.quantity.value.toString(),
    );
    ever(widget.item.quantity, (val) {
      final newText = val.toString();
      if (_textCtrl.text != newText) {
        _textCtrl.text = newText;
        _textCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _update(int newVal) {
    if (newVal < 1) return;
    widget.item.quantity.value = newVal;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qty = widget.item.quantity.value;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _update(qty - 1),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ThemeColor.backgroundColor,
                borderRadius: ThemeColor.smallBorderRadius,
                border: Border.all(color: ThemeColor.dividerColor),
              ),
              child: const Icon(
                Icons.remove,
                size: 14,
                color: ThemeColor.textPrimaryColor,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            height: 28,
            child: TextField(
              controller: _textCtrl,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                filled: true,
                fillColor: ThemeColor.backgroundColor,
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
              onChanged: (v) {
                final parsed = int.tryParse(v);
                if (parsed != null && parsed > 0) {
                  widget.item.quantity.value = parsed;
                }
              },
            ),
          ),
          GestureDetector(
            onTap: () => _update(qty + 1),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor,
                borderRadius: ThemeColor.smallBorderRadius,
              ),
              child: const Icon(Icons.add, size: 14, color: Colors.white),
            ),
          ),
        ],
      );
    });
  }
}

class _TotalsSection extends StatelessWidget {
  final CreateSalesController ctrl;
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
                      value: ctrl.incIVA.value,
                      onChanged: (v) => ctrl.incIVA.value = v,
                      activeColor: ThemeColor.primaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
            Divider(height: 20, color: ThemeColor.dividerColor),
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
                        children: [5, 10, 15, 20, 25, 30].map((pct) {
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
                                '$pct%',
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

class _DeliverySection extends StatelessWidget {
  final CreateSalesController ctrl;
  const _DeliverySection({required this.ctrl});

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
            'Fecha entrega',
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

class _ExtraFieldsSection extends StatelessWidget {
  final CreateSalesController ctrl;
  const _ExtraFieldsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Column(
        children: [
          _RowField(
            label: 'Referencia',
            child: _SimpleTextField(
              controller: ctrl.referenciaCtrl,
              hint: 'Referencia',
            ),
          ),
          Divider(height: 1, color: ThemeColor.dividerColor),
          _RowField(
            label: 'T.C.',
            child: _SimpleTextField(
              controller: ctrl.tipoCambioCtrl,
              hint: '1.00',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _SimpleTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: ThemeColor.bodyMedium.copyWith(color: ThemeColor.textPrimaryColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: ThemeColor.bodyMedium.copyWith(
          color: ThemeColor.textSecondaryColor,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        filled: true,
        fillColor: ThemeColor.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: ThemeColor.extraLargeBorderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ThemeColor.extraLargeBorderRadius,
          borderSide: BorderSide(color: ThemeColor.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ThemeColor.extraLargeBorderRadius,
          borderSide: const BorderSide(
            color: ThemeColor.accentColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _CommentsSection extends StatelessWidget {
  final CreateSalesController ctrl;
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
  final CreateSalesController ctrl;
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
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          child: ctrl.isSuccess.value
              ? ThemeColor.widgetButton(
                  text: 'Cerrar',
                  backgroundColor: ThemeColor.backgroundColor,
                  textColor: ThemeColor.textPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: ThemeColor.mediumRadius,
                  onPressed: () => Get.back(result: true),
                )
              : ThemeColor.widgetButton(
                  text: 'Crear Venta',
                  backgroundColor: ThemeColor.primaryColor,
                  textColor: ThemeColor.textLightColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: ThemeColor.mediumRadius,
                  isLoading: ctrl.isCreating.value,
                  onPressed: ctrl.createSale,
                ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;
  const _ProductThumbnail({this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: ThemeColor.smallBorderRadius,
        border: Border.all(color: ThemeColor.dividerColor),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: ThemeColor.smallBorderRadius,
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_outlined,
                  color: ThemeColor.textTertiaryColor,
                  size: size * 0.48,
                ),
              ),
            )
          : Icon(
              Icons.image_outlined,
              color: ThemeColor.textTertiaryColor,
              size: size * 0.48,
            ),
    );
  }
}
