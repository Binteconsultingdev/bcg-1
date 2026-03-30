import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/Inventory/presentation/controller/inventory_controller.dart';
import 'package:bcg/features/quotes/presentation/controller/quotes_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Inventory/domain/entities/inventory_entity.dart';
import '../../domain/entities/quote_entity.dart';

// ─── Modelo interno para item en la cotización ────────────────────────────

class _QuoteItem {
  final InventoryEntity product;
  final RxInt quantity;
  final RxDouble discount; // descuento individual (%)

  _QuoteItem({required this.product, int initialQty = 1})
      : quantity = initialQty.obs,
        discount = 0.0.obs;

  double get unitPrice => (product.price ?? 0).toDouble();
  double get subtotal => unitPrice * quantity.value;
  double get discountAmount => subtotal * (discount.value / 100);
  double get total => subtotal - discountAmount;
}

// ─── Controller local de la pantalla ─────────────────────────────────────
// Toda la lógica de UI y de creación vive aquí y delega en QuotesController
// e InventoryController que ya existen en el árbol de GetX.

class _CreateQuotePageController extends GetxController {
  // ── Dependencias ──────────────────────────────────────────────────────
  late final QuotesController _quotesCtrl;
  late final InventoryController _inventoryCtrl;

  // ── Estado del formulario ─────────────────────────────────────────────
  final folio = ''.obs;
  final selectedClientId = Rxn<String>();
  final selectedClientName = Rxn<String>();

final clienteName = ''.obs;
final clienteController = TextEditingController();
  final selectedPriceType = 'Regular'.obs;
  final validUntil = DateTime.now().add(const Duration(days: 15)).obs;
  final items = <_QuoteItem>[].obs;
  final globalDiscount = 0.0.obs;
  final referencia = ''.obs;

  final isCreating = false.obs;
  final isLoadingFolio = false.obs;
  final errorMessage = ''.obs;

  // Búsqueda de producto
  final productSearchQuery = ''.obs;
  final isSearching = false.obs;

  // Controllers de texto
  final commentsCtrl = TextEditingController();
  final productSearchCtrl = TextEditingController();
  final globalDiscountCtrl = TextEditingController();
void onClienteChanged(String value) => clienteName.value = value;

  // ── Opciones ──────────────────────────────────────────────────────────
  final List<String> priceOptions = ['Regular', 'Mayoreo', 'Especial'];

  // ── Computed ──────────────────────────────────────────────────────────
  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get ivaAmount => (subtotal - globalDiscount.value) * 0.16;
  double get totalToPay => subtotal - globalDiscount.value + ivaAmount;

  List<InventoryEntity> get searchResults {
    final q = productSearchQuery.value.toLowerCase();
    if (q.isEmpty) return [];
    return _inventoryCtrl.inventario
        .where((p) =>
            (p.description?.toLowerCase().contains(q) ?? false) ||
            (p.partNumber?.toLowerCase().contains(q) ?? false))
        .take(20)
        .toList();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _quotesCtrl = Get.find<QuotesController>();
    _inventoryCtrl = Get.find<InventoryController>();
    _loadFolio();
  }

  Future<void> _loadFolio() async {
    try {
      isLoadingFolio.value = true;
      final folioEntity = await _quotesCtrl.fetchFolioUsecase.call();
      folio.value = folioEntity.folio;
    } catch (e) {
      errorMessage.value = 'No se pudo obtener el folio';
    } finally {
      isLoadingFolio.value = false;
    }
  }

  // ── Búsqueda de producto ──────────────────────────────────────────────
  void onProductSearchChanged(String value) {
    productSearchQuery.value = value;
    isSearching.value = value.isNotEmpty;
  }

  void addProduct(InventoryEntity product) {
    final existing = items.firstWhereOrNull(
      (i) => i.product.id == product.id,
    );
    if (existing != null) {
      existing.quantity.value++;
    } else {
      items.add(_QuoteItem(product: product));
    }
    productSearchCtrl.clear();
    productSearchQuery.value = '';
    isSearching.value = false;
  }

  void removeItem(_QuoteItem item) => items.remove(item);

  void duplicateItem(_QuoteItem item) {
    items.add(_QuoteItem(
      product: item.product,
      initialQty: item.quantity.value,
    ));
  }

  // ── Selección de cliente ──────────────────────────────────────────────
  void selectClient(String id, String name) {
    selectedClientId.value = id;
    selectedClientName.value = name;
  }

  // ── Descuento global ──────────────────────────────────────────────────
  void applyGlobalDiscount(double value) {
    globalDiscount.value = value;
    globalDiscountCtrl.text = value > 0 ? value.toStringAsFixed(2) : '';
  }

  // ── Fecha válida ──────────────────────────────────────────────────────
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: validUntil.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: ThemeColor.primaryColor,
            secondary: ThemeColor.accentColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) validUntil.value = picked;
  }

  // ── Crear cotización ──────────────────────────────────────────────────
  Future<void> createQuote() async {
    if (clienteName.value.trim().isEmpty)
 {
      _showWarning('Selecciona un cliente para continuar');
      return;
    }
    if (items.isEmpty) {
      _showWarning('Agrega al menos un producto');
      return;
    }

    try {
      isCreating.value = true;
      errorMessage.value = '';

      final entity = QuoteEntity(
        folio: folio.value,
cliente: clienteName.value.trim(),
        total: totalToPay,
        cataPrecio: selectedPriceType.value,
        descuento: globalDiscount.value.toStringAsFixed(2),
        iva: ivaAmount.toStringAsFixed(2),
        diasEnt: validUntil.value.difference(DateTime.now()).inDays,
        comentarios: commentsCtrl.text.trim(),
        referencia: referencia.value,
        productos: items.asMap().entries.map((entry) {
          final i = entry.value;
          return ProductoEntity(
            codigo: i.product.partNumber ?? '',
            descripcion: i.product.description ?? '',
            disponible: i.product.availableQuantity ?? 0,
            unidad: 'PZA',
            precio: i.unitPrice,
            cantidad: i.quantity.value,
            importe: i.total,
            iva: (i.total * 0.16).toStringAsFixed(2),
            claveSat: '',
            url: i.product.imageUrl ?? '',
            descuento: i.discountAmount,
            prioridad: entry.key + 1,
          );
        }).toList(),
      );

      await _quotesCtrl.createQuotesUsecase.call(entity);
      await _quotesCtrl.fetchQuotes();

      Get.back(result: true);
    } catch (e) {
      errorMessage.value = 'Error al crear cotización: $e';
      _showWarning('Error al crear cotización');
    } finally {
      isCreating.value = false;
    }
  }

  void _showWarning(String msg) {
    Get.snackbar(
      'Atención',
      msg,
      backgroundColor: ThemeColor.warningColor,
      colorText: ThemeColor.textDarkColor,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(ThemeColor.paddingMedium),
    );
  }

  @override
  void onClose() {
    commentsCtrl.dispose();
    productSearchCtrl.dispose();
    globalDiscountCtrl.dispose();
    super.onClose();
  }
}

// ─── Page ──────────────────────────────────────────────────────────────────

class CreateQuotePage extends StatelessWidget {
  const CreateQuotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(_CreateQuotePageController());

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

// ─── AppBar ────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final _CreateQuotePageController ctrl;
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
      title: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Crear Cotización', style: ThemeColor.headingSmall),
              if (ctrl.folio.value.isNotEmpty)
                Text(
                  'Folio: ${ctrl.folio.value}',
                  style: ThemeColor.caption.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
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

// ─── Sección superior: cliente / precio / producto ─────────────────────────

class _TopSection extends StatelessWidget {
  final _CreateQuotePageController ctrl;
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
          _RowField(
            label: 'Producto',
            child: _ProductSearchField(ctrl: ctrl),
          ),
          // Resultados inline
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
                    leading: _ProductThumbnail(
                        imageUrl: p.imageUrl, size: 36),
                    title: Text(
                      p.description ?? '',
                      style: ThemeColor.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${p.partNumber ?? ''} · \$${(p.price ?? 0).toStringAsFixed(2)}',
                      style: ThemeColor.caption,
                    ),
                    trailing: const Icon(
                      Icons.add_circle_outline,
                      color: ThemeColor.accentColor,
                      size: 20,
                    ),
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

// ─── Row field helper ──────────────────────────────────────────────────────

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

// ─── Cliente selector ──────────────────────────────────────────────────────
class _ClientSelector extends StatelessWidget {
  final _CreateQuotePageController ctrl;
  const _ClientSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Input de texto libre ──────────────────────────────────────
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: ThemeColor.backgroundColor,
                suffixIcon: hasText
                    ? GestureDetector(
                        onTap: () {
                          ctrl.clienteController.clear();
                          ctrl.onClienteChanged('');
                        },
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: ThemeColor.textSecondaryColor,
                        ),
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
                    color: ThemeColor.accentColor,
                    width: 1.5,
                  ),
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
        // ── Botón buscar cliente (listo para el futuro endpoint) ──────
        GestureDetector(
          onTap: () {
            // TODO: cuando tengas el endpoint descomenta esto:
            // Get.to(() => ClientSelectorPage())?.then((name) {
            //   if (name != null) {
            //     ctrl.clienteName.value = name;
            //     ctrl.clienteController.text = name;
            //   }
            // });
            Get.snackbar(
              'Próximamente',
              'El buscador de clientes estará disponible pronto',
              backgroundColor: ThemeColor.primaryColor,
              colorText: ThemeColor.textLightColor,
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(ThemeColor.paddingMedium),
            );
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ThemeColor.primaryColor,
              borderRadius: ThemeColor.smallBorderRadius,
            ),
            child: const Icon(
              Icons.person_search_outlined,
              color: ThemeColor.textLightColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Precio selector ──────────────────────────────────────────────────────

class _PriceSelector extends StatelessWidget {
  final _CreateQuotePageController ctrl;
  const _PriceSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () => Get.bottomSheet(
            _PriceBottomSheet(ctrl: ctrl),
            isScrollControlled: true,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
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
        ));
  }
}

class _PriceBottomSheet extends StatelessWidget {
  final _CreateQuotePageController ctrl;
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
            padding:
                const EdgeInsets.only(bottom: ThemeColor.paddingMedium),
            child: Text('Tipo de precio', style: ThemeColor.headingSmall),
          ),
          ...ctrl.priceOptions.map(
            (opt) => Obx(() => ListTile(
                  title: Text(opt, style: ThemeColor.bodyLarge),
                  trailing: ctrl.selectedPriceType.value == opt
                      ? const Icon(Icons.check,
                          color: ThemeColor.accentColor)
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

// ─── Búsqueda de producto ─────────────────────────────────────────────────

class _ProductSearchField extends StatelessWidget {
  final _CreateQuotePageController ctrl;
  const _ProductSearchField({required this.ctrl});

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
          const Icon(Icons.search,
              color: ThemeColor.textSecondaryColor, size: 18),
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

// ─── Lista de productos ───────────────────────────────────────────────────

class _ProductList extends StatelessWidget {
  final _CreateQuotePageController ctrl;
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
  final _CreateQuotePageController ctrl;
  final _QuoteItem item;
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
                _QuantityInput(item: item),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Get.bottomSheet(
                  _ItemOptionsSheet(ctrl: ctrl, item: item),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz,
                    color: ThemeColor.textSecondaryColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Obx(() => Text(
                    '\$${item.total.toStringAsFixed(2)}',
                    style: ThemeColor.subtitleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quantity input con StatefulWidget para evitar rebuild del cursor ──────

class _QuantityInput extends StatefulWidget {
  final _QuoteItem item;
  const _QuantityInput({required this.item});

  @override
  State<_QuantityInput> createState() => _QuantityInputState();
}

class _QuantityInputState extends State<_QuantityInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.item.quantity.value.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 34,
      child: TextField(
        controller: _ctrl,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: ThemeColor.bodyMedium,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
          final parsed = int.tryParse(v);
          if (parsed != null && parsed > 0) {
            widget.item.quantity.value = parsed;
          }
        },
      ),
    );
  }
}

// ─── Item options bottom sheet ─────────────────────────────────────────────

class _ItemOptionsSheet extends StatelessWidget {
  final _CreateQuotePageController ctrl;
  final _QuoteItem item;
  const _ItemOptionsSheet({required this.ctrl, required this.item});

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
        children: [
          ListTile(
            leading: const Icon(Icons.copy_outlined,
                color: ThemeColor.primaryColor),
            title: Text('Duplicar', style: ThemeColor.bodyLarge),
            onTap: () {
              ctrl.duplicateItem(item);
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline,
                color: ThemeColor.errorColor),
            title: Text(
              'Eliminar',
              style: ThemeColor.bodyLarge
                  .copyWith(color: ThemeColor.errorColor),
            ),
            onTap: () {
              ctrl.removeItem(item);
              Get.back();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Sección de totales ───────────────────────────────────────────────────

class _TotalsSection extends StatelessWidget {
  final _CreateQuotePageController ctrl;
  const _TotalsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Obx(() => Column(
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
                          ? 'Descuento aplicado'
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
                    style: ThemeColor.bodyMedium
                        .copyWith(color: ThemeColor.errorColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _TotalRow(
                label: 'I.V.A',
                value: '\$${ctrl.ivaAmount.toStringAsFixed(2)}',
              ),
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
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColor.surfaceColor,
        title: Text('Descuento global', style: ThemeColor.headingSmall),
        content: TextField(
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
              ctrl.applyGlobalDiscount(
                double.tryParse(ctrl.globalDiscountCtrl.text) ?? 0,
              );
              Get.back();
            },
            child: const Text('Aplicar'),
          ),
        ],
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

// ─── Válida hasta ─────────────────────────────────────────────────────────

class _ValidUntilSection extends StatelessWidget {
  final _CreateQuotePageController ctrl;
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
                    child: Text(
                      _fmt(ctrl.validUntil.value),
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                    ),
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

// ─── Comentarios ──────────────────────────────────────────────────────────

class _CommentsSection extends StatelessWidget {
  final _CreateQuotePageController ctrl;
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
                    color: ThemeColor.accentColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Botón inferior ───────────────────────────────────────────────────────

class _BottomButton extends StatelessWidget {
  final _CreateQuotePageController ctrl;
  const _BottomButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.fromLTRB(
        ThemeColor.paddingMedium,
        ThemeColor.paddingSmall,
        ThemeColor.paddingMedium,
        ThemeColor.paddingLarge,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Obx(() => ThemeColor.widgetButton(
              text: 'Crear Cotización',
              backgroundColor: ThemeColor.primaryColor,
              textColor: ThemeColor.textLightColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: ThemeColor.mediumRadius,
              isLoading: ctrl.isCreating.value,
              onPressed: ctrl.createQuote,
            )),
      ),
    );
  }
}

// ─── Thumbnail helper ─────────────────────────────────────────────────────

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