import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/quotes/presentation/controller/create_quote_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateQuotePage extends StatelessWidget {
  const CreateQuotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateQuoteController ctrl = Get.find<CreateQuoteController>();

    return Scaffold(
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
                  _ValidUntilSection(ctrl: ctrl),
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
    );
  }

  static Widget _sectionGap() =>
      Container(height: 8, color: ThemeColor.backgroundColor);
}

// ── AppBar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final CreateQuoteController ctrl;
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
        child: const Icon(Icons.arrow_back_ios_new,
            color: ThemeColor.textPrimaryColor, size: 20),
      ),
      title: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Crear Cotización', style: ThemeColor.headingSmall),
              if (ctrl.folio.value.isNotEmpty)
                Text(
                  'Folio: ${ctrl.folio.value}',
                  style: ThemeColor.caption.copyWith(
                      color: ThemeColor.textSecondaryColor),
                ),
            ],
          )),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: ThemeColor.dividerColor),
      ),
    );
  }
}

// ── Top Section ──────────────────────────────────────────────────────────────

class _TopSection extends StatelessWidget {
  final CreateQuoteController ctrl;
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
          _RowField(label: 'Cliente', child: _ClientSelector(ctrl: ctrl)),
          Divider(height: 1, color: ThemeColor.dividerColor),
          _RowField(label: 'Precio', child: _PriceSelector(ctrl: ctrl)),
          Divider(height: 1, color: ThemeColor.dividerColor),
          _RowField(label: 'Producto', child: ProductSearchField(ctrl: ctrl)),
          Obx(() {
            if (!ctrl.isSearching.value) return const SizedBox.shrink();
            final results = ctrl.searchResults;
            if (results.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Sin resultados', style: ThemeColor.bodySmall),
              );
            }
            return Container(
              constraints: const BoxConstraints(maxHeight: 220),
              margin: const EdgeInsets.only(top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: ThemeColor.surfaceColor,
                borderRadius: ThemeColor.smallBorderRadius,
                border: Border.all(color: ThemeColor.dividerColor),
                boxShadow: [ThemeColor.lightShadow],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: results.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: ThemeColor.dividerColor),
                itemBuilder: (_, i) {
                  final p = results[i];
                  return ListTile(
                    dense: true,
                    leading:
                        _ProductThumbnail(imageUrl: p.imageUrl, size: 36),
                    title: Text(p.description ?? '',
                        style: ThemeColor.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${p.partNumber ?? ''} · \$${(p.price ?? 0).toStringAsFixed(2)}',
                      style: ThemeColor.caption,
                    ),
                    trailing: const Icon(Icons.add_circle_outline,
                        color: ThemeColor.accentColor, size: 20),
                    onTap: () => ctrl.addProduct(p),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Row Field ─────────────────────────────────────────────────────────────────

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
            child: Text(label,
                style: ThemeColor.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ThemeColor.textPrimaryColor)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── Client Selector ───────────────────────────────────────────────────────────

class _ClientSelector extends StatelessWidget {
  final CreateQuoteController ctrl;
  const _ClientSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final hasText = ctrl.clienteName.value.trim().isNotEmpty;
            return TextField(
              controller: ctrl.clienteController,
              style: ThemeColor.bodyMedium
                  .copyWith(color: ThemeColor.textPrimaryColor),
              textCapitalization: TextCapitalization.words,
              onChanged: ctrl.onClienteChanged,
              decoration: InputDecoration(
                hintText: 'Nombre del cliente',
                hintStyle: ThemeColor.bodyMedium
                    .copyWith(color: ThemeColor.textSecondaryColor),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: ThemeColor.backgroundColor,
                suffixIcon: hasText
                    ? GestureDetector(
                        onTap: () {
                          ctrl.clienteController.clear();
                          ctrl.onClienteChanged('');
                        },
                        child: const Icon(Icons.close,
                            size: 16, color: ThemeColor.textSecondaryColor),
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: ThemeColor.extraLargeBorderRadius,
                  borderSide: BorderSide(
                    color: hasText
                        ? ThemeColor.accentColor.withOpacity(0.5)
                        : ThemeColor.dividerColor,
                    width: hasText ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: ThemeColor.extraLargeBorderRadius,
                  borderSide: const BorderSide(
                      color: ThemeColor.accentColor, width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: ThemeColor.extraLargeBorderRadius,
                  borderSide: BorderSide.none,
                ),
              ),
            );
          }),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => ctrl.openClientSearch(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor,
              borderRadius: ThemeColor.smallBorderRadius,
            ),
            child: const Icon(Icons.person_search_outlined,
                color: ThemeColor.textLightColor, size: 18),
          ),
        ),
      ],
    );
  }
}

// ── Price Selector ────────────────────────────────────────────────────────────

class _PriceSelector extends StatelessWidget {
  final CreateQuoteController ctrl;
  const _PriceSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
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
                  child: Text(ctrl.selectedPriceType.value,
                      style: ThemeColor.bodyMedium
                          .copyWith(color: ThemeColor.textSecondaryColor)),
                ),
                const Icon(Icons.chevron_right,
                    color: ThemeColor.textSecondaryColor, size: 18),
              ],
            ),
          ),
        ));
  }
}

class _PriceBottomSheet extends StatelessWidget {
  final CreateQuoteController ctrl;
  const _PriceBottomSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeColor.paddingMedium),
      decoration: const BoxDecoration(
        color: ThemeColor.surfaceColor,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(ThemeColor.largeRadius)),
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
            (opt) => Obx(() => ListTile(
                  title: Text(opt, style: ThemeColor.bodyLarge),
                  trailing: ctrl.selectedPriceType.value == opt
                      ? const Icon(Icons.check, color: ThemeColor.accentColor)
                      : null,
                  onTap: () {
                    ctrl.selectedPriceType.value = opt;
                    Get.back();
                  },
                )),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Product Search ────────────────────────────────────────────────────────────

class ProductSearchField extends StatelessWidget {
  final CreateQuoteController ctrl;
  const ProductSearchField({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: ThemeColor.extraLargeBorderRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: ThemeColor.textSecondaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: ctrl.productSearchCtrl,
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Buscar producto',
                hintStyle: ThemeColor.bodyMedium
                    .copyWith(color: ThemeColor.textSecondaryColor),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: ctrl.onProductSearchChanged,
            ),
          ),
          Obx(() => ctrl.isSearching.value
              ? GestureDetector(
                  onTap: () {
                    ctrl.productSearchCtrl.clear();
                    ctrl.onProductSearchChanged('');
                  },
                  child: const Icon(Icons.close,
                      color: ThemeColor.textSecondaryColor, size: 16),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

// ── Product List ──────────────────────────────────────────────────────────────

class _ProductList extends StatelessWidget {
  final CreateQuoteController ctrl;
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
                      endIndent: 16),
              ],
            );
          }).toList(),
        ),
      );
    });
  }
}

class _ProductItem extends StatelessWidget {
  final CreateQuoteController ctrl;
  final QuoteItem item;
  const _ProductItem({required this.ctrl, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingMedium,
          vertical: ThemeColor.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductThumbnail(imageUrl: item.product.imageUrl, size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.description ?? '',
                    style: ThemeColor.subtitleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('\$${item.unitPrice.toStringAsFixed(2)}',
                    style: ThemeColor.bodyMedium
                        .copyWith(color: ThemeColor.textSecondaryColor)),
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
                  child: Icon(Icons.delete_outline,
                      color: ThemeColor.errorColor, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              Obx(() => Text('\$${item.total.toStringAsFixed(2)}',
                  style: ThemeColor.subtitleMedium
                      .copyWith(fontWeight: FontWeight.w700))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quantity Controls ─────────────────────────────────────────────────────────

class _QuantityControls extends StatefulWidget {
  final CreateQuoteController ctrl;
  final QuoteItem item;
  const _QuantityControls({required this.ctrl, required this.item});

  @override
  State<_QuantityControls> createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<_QuantityControls> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl =
        TextEditingController(text: widget.item.quantity.value.toString());
    ever(widget.item.quantity, (val) {
      final newText = val.toString();
      if (_textCtrl.text != newText) {
        _textCtrl.text = newText;
        _textCtrl.selection =
            TextSelection.fromPosition(TextPosition(offset: newText.length));
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _update(double newVal) {
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
              child: const Icon(Icons.remove,
                  size: 14, color: ThemeColor.textPrimaryColor),
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
                      color: ThemeColor.accentColor, width: 1.5),
                ),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v);
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

// ── Totals ────────────────────────────────────────────────────────────────────

class _TotalsSection extends StatelessWidget {
  final CreateQuoteController ctrl;
  const _TotalsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingMedium,
          vertical: ThemeColor.paddingMedium),
      child: Obx(() => Column(
            children: [
              _TotalRow(
                  label: 'Subtotal',
                  value: '\$${ctrl.subtotal.toStringAsFixed(2)}'),
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
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    ctrl.globalDiscount.value > 0
                        ? '-\$${ctrl.globalDiscount.value.toStringAsFixed(2)}'
                        : '\$0.00',
                    style: ThemeColor.bodyMedium
                        .copyWith(color: ThemeColor.errorColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _TotalRow(
                  label: 'I.V.A',
                  value: '\$${ctrl.ivaAmount.toStringAsFixed(2)}'),
              Divider(height: 20, color: ThemeColor.dividerColor),
              _TotalRow(
                label: 'Total a pagar',
                value: '\$${ctrl.totalToPay.toStringAsFixed(2)}',
                bold: true,
              ),
            ],
          )),
    );
  }

  void _showDiscountDialog(BuildContext context) {
    final RxString mode = ctrl.globalDiscountType.value.obs;

    Get.dialog(
      Obx(() => AlertDialog(
            backgroundColor: ThemeColor.surfaceColor,
            title: Text('Descuento global', style: ThemeColor.headingSmall),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toggle monto / porcentaje
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

                // Monto fijo
                if (mode.value == 'monto')
                  TextField(
                    controller: ctrl.globalDiscountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                            color: ThemeColor.accentColor, width: 1.5),
                      ),
                    ),
                  ),

                // Porcentaje — chips
                if (mode.value == 'porcentaje')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selecciona el porcentaje',
                          style: ThemeColor.bodySmall.copyWith(
                              color: ThemeColor.textSecondaryColor)),
                      const SizedBox(height: 10),
                      Obx(() => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [5, 10, 15, 20, 25, 30].map((pct) {
                              final selected =
                                  ctrl.globalDiscountPercent.value ==
                                      pct.toDouble();
                              return GestureDetector(
                                onTap: () =>
                                    ctrl.globalDiscountPercent.value =
                                        pct.toDouble(),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? ThemeColor.primaryColor
                                        : ThemeColor.backgroundColor,
                                    borderRadius:
                                        ThemeColor.circularBorderRadius,
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
                          )),
                      const SizedBox(height: 10),
                      Obx(() => ctrl.globalDiscountPercent.value > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
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
                                    style: ThemeColor.bodySmall
                                        .copyWith(color: ThemeColor.errorColor),
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
                          : const SizedBox.shrink()),
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
                child: const Text('Cancelar',
                    style:
                        TextStyle(color: ThemeColor.textSecondaryColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.primaryColor),
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
          )),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _TotalRow(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? ThemeColor.subtitleLarge.copyWith(fontWeight: FontWeight.w700)
        : ThemeColor.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

// ── Valid Until ───────────────────────────────────────────────────────────────

class _ValidUntilSection extends StatelessWidget {
  final CreateQuoteController ctrl;
  const _ValidUntilSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingMedium,
          vertical: ThemeColor.paddingMedium),
      child: Row(
        children: [
          Text('Válida hasta',
              style: ThemeColor.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ThemeColor.textPrimaryColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => GestureDetector(
                  onTap: () => ctrl.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: ThemeColor.backgroundColor,
                      borderRadius: ThemeColor.smallBorderRadius,
                      border: Border.all(color: ThemeColor.dividerColor),
                    ),
                    child: Text(_fmt(ctrl.validUntil.value),
                        style: ThemeColor.bodyMedium
                            .copyWith(color: ThemeColor.textSecondaryColor)),
                  ),
                )),
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

// ── Comments ──────────────────────────────────────────────────────────────────

class _CommentsSection extends StatelessWidget {
  final CreateQuoteController ctrl;
  const _CommentsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
          horizontal: ThemeColor.paddingMedium,
          vertical: ThemeColor.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Comentarios',
              style: ThemeColor.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ThemeColor.textPrimaryColor)),
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
                    color: ThemeColor.accentColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Button ─────────────────────────────────────────────────────────────

class _BottomButton extends StatelessWidget {
  final CreateQuoteController ctrl;
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
        if (ctrl.createdQuoteId.value != null) {
          return Row(
            children: [
              Expanded(
                child: ThemeColor.widgetButton(
                  text: 'Cerrar',
                  backgroundColor: ThemeColor.backgroundColor,
                  textColor: ThemeColor.textPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: ThemeColor.mediumRadius,
                  isLoading: false,
                  onPressed: () => Get.back(result: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ThemeColor.widgetButton(
                  text: 'Ver PDF',
                  backgroundColor: ThemeColor.accentColor,
                  textColor: ThemeColor.textLightColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: ThemeColor.mediumRadius,
                  isLoading: ctrl.isLoadingPdf.value,
                  onPressed: () => ctrl.generateAndOpenPdf(context),
                ),
              ),
            ],
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ThemeColor.widgetButton(
            text: 'Crear Cotización',
            backgroundColor: ThemeColor.primaryColor,
            textColor: ThemeColor.textLightColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            borderRadius: ThemeColor.mediumRadius,
            isLoading: ctrl.isCreating.value,
            onPressed: ctrl.createQuote,
          ),
        );
      }),
    );
  }
}

// ── Product Thumbnail ─────────────────────────────────────────────────────────

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
          : Icon(Icons.image_outlined,
              color: ThemeColor.textTertiaryColor, size: size * 0.48),
    );
  }
}