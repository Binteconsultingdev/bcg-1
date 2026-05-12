import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/post_validate_cart_entity.dart';
import 'package:bcg/features/Inventory/domain/usecase/validate_cart_usecase.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
import 'package:bcg/features/client/presentation/controller/client_search_controller.dart';
import 'package:bcg/features/client/presentation/page/client_search_sheet.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/usecase/create_quotes_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_folio_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/generate_pdf_usecase.dart';
import 'package:bcg/features/quotes/presentation/controller/quotes_controller.dart';
import 'package:bcg/features/quotes/presentation/widget/create_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomQuoteItem {
  final String descripcion;
  final double costo;
  final RxDouble cantidad;
  final RxDouble discount;

  CustomQuoteItem({
    required this.descripcion,
    required this.costo,
    double initialQty = 1.0,
  })  : cantidad = initialQty.obs,
        discount = 0.0.obs;

  double get unitPrice => costo;
  double get subtotal => unitPrice * cantidad.value;
  double get discountAmount => subtotal * (discount.value / 100);
  double get total => subtotal - discountAmount;
}

class QuoteItem {
  final InventoryEntity? product;
  final CustomQuoteItem? customProduct;
  final RxDouble quantity;
  final RxDouble discount;

  QuoteItem({required InventoryEntity inventoryProduct, double initialQty = 1.0})
      : product = inventoryProduct,
        customProduct = null,
        quantity = initialQty.obs,
        discount = 0.0.obs;

  QuoteItem.custom({required CustomQuoteItem custom, double initialQty = 1.0})
      : product = null,
        customProduct = custom,
        quantity = initialQty.obs,
        discount = 0.0.obs;

  bool get isCustom => customProduct != null;

  String get description =>
      isCustom ? customProduct!.descripcion : product!.description ?? '';

  String? get imageUrl => isCustom ? null : product!.imageUrl;

  // 👇 precio validado por backend (solo para productos de inventario)
  final RxnDouble validatedPrice = RxnDouble();

  double get unitPrice {
    if (isCustom) return customProduct!.costo;
    return validatedPrice.value ?? (product!.price ?? 0).toDouble();
  }

  int get availableQty =>
      isCustom ? 999 : (product!.availableQuantity ?? 0).toInt();

  double get subtotal => unitPrice * quantity.value;
  double get discountAmount => subtotal * (discount.value / 100);
  double get total => subtotal - discountAmount;
  RxDouble get totalRx => total.obs;
}

class CreateQuoteController extends GetxController {
  final CreateQuotesUsecase createQuotesUsecase;
  final FetchFolioUsecase fetchFolioUsecase;
  final GeneratePdfUsecase generatePdfUsecase;
  final ValidateCartUsecase validateCartUsecase;

  CreateQuoteController({
    required this.createQuotesUsecase,
    required this.fetchFolioUsecase,
    required this.generatePdfUsecase,
    required this.validateCartUsecase,
  });

  late final QuotesController _quotesCtrl = Get.find<QuotesController>();
  late final ClientController _clientCtrl = Get.find<ClientController>();
  late final PdfController _pdfCtrl = Get.find<PdfController>();

  bool get hasOutOfStockItems =>
      items.any((i) => !i.isCustom && (i.product!.availableQuantity ?? 0) <= 0);

  final folio = ''.obs;
  final RxBool isLoadingFolio = false.obs;
  bool get isLoadingPdf => _pdfCtrl.isLoadingPdf.value;

  final clienteName = ''.obs;
  final clienteController = TextEditingController();
  final selectedClientId = Rxn<String>();
  final selectedClientName = Rxn<String>();

  final selectedPriceType = 'REGULAR'.obs;
  final List<String> priceOptions = [
    'REGULAR',
    'MEDIO M',
    'PAQUETE',
    'MAYOREO',
    'ESPECIAL',
  ];

  final validUntil = DateTime.now().add(const Duration(days: 15)).obs;

  final items = <QuoteItem>[].obs;
  final productSearchQuery = ''.obs;
  final isSearching = false.obs;
  final RxList<InventoryEntity> searchResults = <InventoryEntity>[].obs;
  final RxBool isLoadingSearch = false.obs;

  final globalDiscount = 0.0.obs;
  final globalDiscountType = 'monto'.obs;
  final globalDiscountPercent = 0.0.obs;
  final referencia = ''.obs;

  final isCreating = false.obs;
  final isValidatingCart = false.obs; // 👈 nuevo
  final errorMessage = ''.obs;

  // Totales globales validados por backend 👇
  final validatedPriceWithoutVAT = Rxn<double>();
  final validatedPriceWithVAT = Rxn<double>();

  final commentsCtrl = TextEditingController();
  final productSearchCtrl = TextEditingController();
  final globalDiscountCtrl = TextEditingController();

  final createdQuoteId = Rxn<int>();

  double get subtotal => items.fold(0, (s, i) => s + i.total);

  final includeIva = true.obs;

  double get ivaAmount =>
      includeIva.value ? (subtotal - globalDiscount.value) * 0.16 : 0.0;
  double get totalToPay => subtotal - globalDiscount.value + ivaAmount;

  @override
  void onInit() {
    super.onInit();
    _loadFolio();

    // Re-valida al cambiar tipo de precio
    ever(selectedPriceType, (_) => validateCart());
  }

  @override
  void onReady() {
    super.onReady();
    resetState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clientSearch = Get.find<ClientSearchController>();
      clientSearch.onFreeText = onFreeTextClient;
      clientSearch.showResults.value = false;
      clientSearch.manuallyClosed = true;
    });
  }

  // ─── Validación de carrito ────────────────────────────────────────────────

  Future<void> validateCart() async {
    // Solo items de inventario con id válido
    final inventoryItems = items
        .where((i) => !i.isCustom && i.product?.id != null)
        .toList();

    if (inventoryItems.isEmpty) {
      validatedPriceWithoutVAT.value = null;
      validatedPriceWithVAT.value = null;
      return;
    }

    try {
      isValidatingCart.value = true;

      final response = await validateCartUsecase.call(
        PostValidateCartEntity(
          pricetype: selectedPriceType.value, // cataPrecio → pricetype
          items: inventoryItems
              .map(
                (i) => PostItemValidateCartEntity(
                  productid: i.product!.id!,
                  quantity: i.quantity.value.toInt(),
                ),
              )
              .toList(),
        ),
      );

      // Actualiza el precio validado en cada item
      for (final responseItem in response.items) {
        final match = items.firstWhereOrNull(
          (i) => !i.isCustom && i.product?.id == responseItem.productid,
        );
        if (match != null) {
          match.validatedPrice.value = responseItem.newPrice;
        }
      }

      validatedPriceWithoutVAT.value = response.priceWithoutVAT;
      validatedPriceWithVAT.value = response.priceWithVAT;
    } catch (e) {
      debugPrint('validateCart error: $e');
    } finally {
      isValidatingCart.value = false;
    }
  }

  // ─── Clientes ─────────────────────────────────────────────────────────────

  void onClientSelected(ClientEntity client) {
    final name = client.displayName ?? '';
    clienteController.text = name;
    clienteName.value = name;
    selectedClientId.value = client.id.toString();
    selectedClientName.value = client.displayName;
    Get.find<ClientSearchController>().searchCtrl.text = name;
  }

  void onFreeTextClient(String value) {
    clienteName.value = value;
    selectedClientId.value = null;
    selectedClientName.value = null;
  }

  void onClienteChanged(String value) => clienteName.value = value;

  void openClientSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClientSearchSheet(
        clientCtrl: _clientCtrl,
        onSelected: (client) {
          clienteController.text = client.displayName ?? '';
          clienteName.value = client.displayName ?? '';
          selectedClientId.value = client.id.toString();
          selectedClientName.value = client.displayName;
        },
      ),
    );
  }

  void selectClient(String id, String name) {
    selectedClientId.value = id;
    selectedClientName.value = name;
  }

  // ─── Folio ────────────────────────────────────────────────────────────────

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

  // ─── Productos ────────────────────────────────────────────────────────────

  void onProductSearchChanged(String value) {
    productSearchQuery.value = value;
    isSearching.value = value.isNotEmpty;
    if (value.trim().isEmpty) searchResults.clear();
  }

  void addProduct(InventoryEntity product) {
    if ((product.price ?? 0) <= 0) {
      showErrorSnackbar('Este producto no tiene precio asignado');
      return;
    }
    final existing = items.firstWhereOrNull(
      (i) => !i.isCustom && i.product!.id == product.id,
    );
    if (existing != null) {
      existing.quantity.value++;
    } else {
      items.add(QuoteItem(inventoryProduct: product));
    }
    productSearchCtrl.clear();
    productSearchQuery.value = '';
    isSearching.value = false;
    searchResults.clear();
    validateCart(); // 👈 valida al agregar
  }

  void addCustomProduct({
    required String descripcion,
    required double costo,
    required double cantidad,
  }) {
    if (descripcion.trim().isEmpty) {
      showErrorSnackbar('Ingresa una descripción');
      return;
    }
    if (costo <= 0) {
      showErrorSnackbar('El costo debe ser mayor a 0');
      return;
    }
    if (cantidad <= 0) {
      showErrorSnackbar('La cantidad debe ser mayor a 0');
      return;
    }
    final custom = CustomQuoteItem(
      descripcion: descripcion.trim(),
      costo: costo,
      initialQty: cantidad,
    );
    items.add(QuoteItem.custom(custom: custom));
    // 👇 custom no se valida, pero actualizamos totales globales si hay
    // items de inventario en el carrito
    validateCart();
  }

  void showAddCustomProductDialog(BuildContext context) {
    final descCtrl = TextEditingController();
    final costoCtrl = TextEditingController();
    final cantCtrl = TextEditingController(text: '1');

    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColor.surfaceColor,
        title: Text('Producto personalizado', style: ThemeColor.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej. Servicio de instalación',
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
            const SizedBox(height: 12),
            TextField(
              controller: costoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Costo unitario',
                prefixText: '\$ ',
                hintText: '0.00',
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
            const SizedBox(height: 12),
            TextField(
              controller: cantCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                hintText: '1',
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
              addCustomProduct(
                descripcion: descCtrl.text,
                costo: double.tryParse(costoCtrl.text) ?? 0,
                cantidad: double.tryParse(cantCtrl.text) ?? 1,
              );
              Get.back();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void removeItem(QuoteItem item) {
    items.remove(item);
    validateCart(); // 👈 valida al quitar
  }

  void duplicateItem(QuoteItem item) {
    if (item.isCustom) {
      final copy = CustomQuoteItem(
        descripcion: item.customProduct!.descripcion,
        costo: item.customProduct!.costo,
        initialQty: item.quantity.value,
      );
      items.add(QuoteItem.custom(custom: copy));
    } else {
      items.add(QuoteItem(
        inventoryProduct: item.product!,
        initialQty: item.quantity.value,
      ));
    }
    validateCart(); // 👈 valida al duplicar
  }

  // ─── Descuento global ─────────────────────────────────────────────────────

  void applyGlobalDiscount(double value, {bool isPercent = false}) {
    if (isPercent) {
      globalDiscountType.value = 'porcentaje';
      globalDiscountPercent.value = value;
      globalDiscount.value = subtotal * (value / 100);
    } else {
      globalDiscountType.value = 'monto';
      globalDiscountPercent.value = 0;
      globalDiscount.value = value;
    }
    globalDiscountCtrl.text =
        globalDiscount.value > 0 ? globalDiscount.value.toStringAsFixed(2) : '';
  }

  // ─── Fecha ────────────────────────────────────────────────────────────────

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

  // ─── Crear cotización ─────────────────────────────────────────────────────

  Future<void> createQuote() async {
    if (clienteName.value.trim().isEmpty) {
      showErrorSnackbar('Selecciona un cliente para continuar');
      return;
    }
    if (items.isEmpty) {
      showErrorSnackbar('Agrega al menos un producto');
      return;
    }

    try {
      isCreating.value = true;
      errorMessage.value = '';

      // Valida una vez más antes de crear para tener precios frescos
      await validateCart();

      final entity = QuoteEntity(
        folio: folio.value,
        cliente: clienteName.value.trim(),
        total: totalToPay,
        cataPrecio: selectedPriceType.value,
        descuento: globalDiscount.value.toStringAsFixed(2),
        iva: includeIva.value ? 'SI' : 'NO',
        diasEnt: validUntil.value.difference(DateTime.now()).inDays,
        comentarios: commentsCtrl.text.trim(),
        referencia: referencia.value,
        productos: items.asMap().entries.map((entry) {
          final i = entry.value;
          return ProductoEntity(
            codigo: i.isCustom ? 'CUSTOM' : (i.product!.partNumber ?? ''),
            descripcion: i.description,
            disponible: i.availableQty,
            unidad: 'PZA',
            precio: i.unitPrice, // ya es el precio validado si es inventario
            cantidad: i.quantity.value,
            importe: i.total,
            iva: (i.total * 0.16).toStringAsFixed(2),
            claveSat: '',
            url: i.imageUrl ?? '',
            descuento: i.discountAmount,
            prioridad: entry.key + 1,
          );
        }).toList(),
      );

      final response = await createQuotesUsecase.call(entity);
      createdQuoteId.value = response.id;
      await _quotesCtrl.fetchQuotes();
      await generateAndOpenPdf();
    } catch (e) {
      errorMessage.value = 'Error al crear cotización: $e';
      showErrorSnackbar('Error al crear cotización');
    } finally {
      isCreating.value = false;
    }
  }

  // ─── PDF ──────────────────────────────────────────────────────────────────

  Future<void> generateAndOpenPdf() async {
    final id = createdQuoteId.value;
    if (id == null) return;

    try {
      _pdfCtrl.reset();
      _pdfCtrl.isLoadingPdf.value = true;
      final result = await generatePdfUsecase.call(id);

      if (result.generated && result.urlpdf.isNotEmpty) {
        _pdfCtrl.folio = folio.value;
        _pdfCtrl.setPdfUrl(result.urlpdf);
        _pdfCtrl.isLoadingPdf.value = false;
        _pdfCtrl.showOptionsSheet(Get.context!);
      }
    } catch (e) {
      showErrorSnackbar('Error al generar PDF');
    } finally {
      _pdfCtrl.isLoadingPdf.value = false;
    }
  }
void editCustomProduct({
  required QuoteItem item,
  required String descripcion,
  required double costo,
  required double cantidad,
}) {
  if (descripcion.trim().isEmpty) {
    showErrorSnackbar('Ingresa una descripción');
    return;
  }
  if (costo <= 0) {
    showErrorSnackbar('El costo debe ser mayor a 0');
    return;
  }
  if (cantidad <= 0) {
    showErrorSnackbar('La cantidad debe ser mayor a 0');
    return;
  }
  // Muta directamente los Rx del customProduct
  item.customProduct!.cantidad.value = cantidad;
  item.quantity.value = cantidad;
  // descripcion y costo son final, recrea el item en su posición
  final index = items.indexOf(item);
  if (index == -1) return;
  final updated = QuoteItem.custom(
    custom: CustomQuoteItem(
      descripcion: descripcion.trim(),
      costo: costo,
      initialQty: cantidad,
    ),
  );
  items[index] = updated;
  items.refresh();
}

void showEditCustomProductDialog(BuildContext context, QuoteItem item) {
  final descCtrl =
      TextEditingController(text: item.customProduct!.descripcion);
  final costoCtrl = TextEditingController(
      text: item.customProduct!.costo.toStringAsFixed(2));
  final cantCtrl = TextEditingController(
      text: item.quantity.value % 1 == 0
          ? item.quantity.value.toInt().toString()
          : item.quantity.value.toString());

  Get.dialog(
    AlertDialog(
      backgroundColor: ThemeColor.surfaceColor,
      title: Text('Editar producto', style: ThemeColor.headingSmall),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: descCtrl,
            textCapitalization: TextCapitalization.sentences,
            style: ThemeColor.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Descripción',
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
          const SizedBox(height: 12),
          TextField(
            controller: costoCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: ThemeColor.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Costo unitario',
              prefixText: '\$ ',
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
          const SizedBox(height: 12),
          TextField(
            controller: cantCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: ThemeColor.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Cantidad',
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
            editCustomProduct(
              item: item,
              descripcion: descCtrl.text,
              costo: double.tryParse(costoCtrl.text) ?? 0,
              cantidad: double.tryParse(cantCtrl.text) ?? 1,
            );
            Get.back();
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
  // ─── Reset ────────────────────────────────────────────────────────────────

  void resetState() {
    items.clear();
    clienteName.value = '';
    clienteController.clear();
    selectedClientId.value = null;
    selectedClientName.value = null;
    commentsCtrl.clear();
    productSearchCtrl.clear();
    globalDiscountCtrl.clear();
    globalDiscount.value = 0.0;
    globalDiscountPercent.value = 0.0;
    globalDiscountType.value = 'monto';
    selectedPriceType.value = 'REGULAR';
    validUntil.value = DateTime.now().add(const Duration(days: 15));
    createdQuoteId.value = null;
    errorMessage.value = '';
    productSearchQuery.value = '';
    isSearching.value = false;
    searchResults.clear();
    validatedPriceWithoutVAT.value = null;
    validatedPriceWithVAT.value = null;
    includeIva.value = true;

    final clientSearch = Get.find<ClientSearchController>();
    clientSearch.clearSearch();
    _pdfCtrl.reset();
  }

  @override
  void onClose() {
    clienteController.dispose();
    commentsCtrl.dispose();
    productSearchCtrl.dispose();
    globalDiscountCtrl.dispose();
    super.onClose();
  }
}