
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/Inventory/presentation/controller/inventory_controller.dart';
import 'package:bcg/features/quotes/domain/usecase/create_quotes_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_folio_usecase.dart';
import 'package:bcg/features/quotes/presentation/controller/quotes_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Inventory/domain/entities/inventory_entity.dart';
import '../../domain/entities/quote_entity.dart';

class QuoteItem {
  final InventoryEntity product;
  final RxInt quantity;
  final RxDouble discount; // descuento individual (%)

  QuoteItem({required this.product, int initialQty = 1})
      : quantity = initialQty.obs,
        discount = 0.0.obs;

  double get unitPrice => (product.price ?? 0).toDouble();
  double get subtotal => unitPrice * quantity.value;
  double get discountAmount => subtotal * (discount.value / 100);
  double get total => subtotal - discountAmount;
}



class CreateQuoteController extends GetxController {
  // ── Dependencias ──────────────────────────────────────────────────────
  
  final CreateQuotesUsecase createQuotesUsecase;
  final FetchFolioUsecase fetchFolioUsecase;
  CreateQuoteController({required this.createQuotesUsecase,required this.fetchFolioUsecase});
  late final InventoryController _inventoryCtrl;
   late final QuotesController _quotesCtrl;
  // ── Estado del formulario ─────────────────────────────────────────────
  final folio = ''.obs;
  final selectedClientId = Rxn<String>();
  final selectedClientName = Rxn<String>();

final clienteName = ''.obs;
final clienteController = TextEditingController();
  final selectedPriceType = 'Regular'.obs;
  final validUntil = DateTime.now().add(const Duration(days: 15)).obs;
  final items = <QuoteItem>[].obs;
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
    _inventoryCtrl = Get.find<InventoryController>();
    _loadFolio();
  }

  Future<void> _loadFolio() async {
    try {
      isLoadingFolio.value = true;
      final folioEntity = await fetchFolioUsecase.call();
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
      items.add(QuoteItem(product: product));
    }
    productSearchCtrl.clear();
    productSearchQuery.value = '';
    isSearching.value = false;
  }

  void removeItem(QuoteItem item) => items.remove(item);

  void duplicateItem(QuoteItem item) {
    items.add(QuoteItem(
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

      await createQuotesUsecase.call(entity);
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