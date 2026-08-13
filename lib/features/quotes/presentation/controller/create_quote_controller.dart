import 'package:bcg/common/services/lisencias.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/common/widgets/qr_scanner_widget.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/post_validate_cart_entity.dart';
import 'package:bcg/features/Inventory/domain/usecase/validate_cart_usecase.dart';
import 'package:bcg/features/Inventory/presentation/controller/inventory_controller.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
import 'package:bcg/features/client/presentation/controller/client_search_controller.dart';
import 'package:bcg/features/client/presentation/page/client_search_sheet.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_from_entity.dart';
import 'package:bcg/features/quotes/domain/usecase/create_quotes_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_folio_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/generate_pdf_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/quote_from_usecase.dart';
import 'package:bcg/features/quotes/presentation/controller/quotes_controller.dart';
import 'package:bcg/features/quotes/presentation/widget/create_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CustomQuoteItem {
  final String descripcion;
  final double costo;
  final RxDouble cantidad;
  final RxDouble discount;

  CustomQuoteItem({
    required this.descripcion,
    required this.costo,
    double initialQty = 1.0,
  }) : cantidad = initialQty.obs,
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
  final RxnString localImagePath = RxnString();
  final RxnDouble manualPriceOverride = RxnDouble();

  QuoteItem({
    required InventoryEntity inventoryProduct,
    double initialQty = 1.0,
  }) : product = inventoryProduct,
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

  String? get imageUrl =>
      localImagePath.value ?? (isCustom ? null : product!.imageUrl);

  final RxnDouble validatedPrice = RxnDouble();

  double get unitPrice {
    if (manualPriceOverride.value != null) return manualPriceOverride.value!;
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
  final QuoteFromUsecase quoteFromUsecase;
  final FetchFolioUsecase fetchFolioUsecase;
  final GeneratePdfUsecase generatePdfUsecase;
  final ValidateCartUsecase validateCartUsecase;

  CreateQuoteController({
    required this.quoteFromUsecase,
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
  final selectedShippingOptions = <String>{}.obs;
  final selectedPackagePercent = Rxn<double>();
  final selectedPriceType = 'REGULAR'.obs;
  final List<String> priceOptions = [
    'REGULAR',
    'MEDIO M',
    'PAQUETE',
    'MAYOREO',
    'ESPECIAL',
  ];

  final validUntil = DateTime.now().add(const Duration(days: 15)).obs;
  final envio = Rxn<double>();
  double get embalajeAmount {
    if (!selectedShippingOptions.contains('paquete')) return 0.0;
    final pct = selectedPackagePercent.value;
    if (pct == null) return 0.0;
    return subtotal * (pct / 100);
  }

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
  final isValidatingCart = false.obs;
  final errorMessage = ''.obs;

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
  double get totalToPay =>
      subtotal -
      globalDiscount.value +
      ivaAmount +
      (envio.value ?? 0.0) +
      embalajeAmount;
  @override
  void onInit() {
    super.onInit();
    _loadFolio(); 
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

  void toggleShippingOption(String option) {
    if (selectedShippingOptions.contains(option)) {
      selectedShippingOptions.remove(option);
      if (option == 'paquete') selectedPackagePercent.value = null;
      if (option == 'envio') envio.value = null;
    } else {
      selectedShippingOptions.add(option);
      if (option == 'envio') envio.value = 0.0;
    }
  }

  void showEditPriceDialog(BuildContext context, QuoteItem item) {
    final priceCtrl = TextEditingController(
      text: item.unitPrice.toStringAsFixed(2),
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColor.surfaceColor,
        title: Text('Cambiar precio', style: ThemeColor.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: ThemeColor.bodySmall.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Nuevo precio unitario',
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
              final nuevoPrecio = double.tryParse(priceCtrl.text);
              if (nuevoPrecio == null || nuevoPrecio <= 0) {
                showErrorSnackbar('Ingresa un precio válido');
                return;
              }
              item.manualPriceOverride.value = nuevoPrecio;
              items.refresh();
              Get.back();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Future<void> validateCart() async {
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
          pricetype: selectedPriceType.value,
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
    validateCart();
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Precio unitario',
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
    validateCart();
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
      items.add(
        QuoteItem(
          inventoryProduct: item.product!,
          initialQty: item.quantity.value,
        ),
      );
    }
    validateCart();
  }

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
    globalDiscountCtrl.text = globalDiscount.value > 0
        ? globalDiscount.value.toStringAsFixed(2)
        : '';
  }

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

      await validateCart();

      final List<ProductoEntity> productos = items.asMap().entries.map((entry) {
        final i = entry.value;
        return ProductoEntity(
          codigo: i.isCustom ? 'CUSTOM' : (i.product!.partNumber ?? ''),
          descripcion: i.description,
          disponible: i.availableQty,
          unidad: i.isCustom ? 'PZA' : (i.product!.unit ?? 'PZA'),
          precio: i.unitPrice,
          cantidad: i.quantity.value,
          importe: i.total,
          iva: (i.total * 0.16).toStringAsFixed(2),
          claveSat: i.isCustom ? '' : (i.product!.claveSat ?? ''),
          url: i.imageUrl ?? '',
          descuento: i.discount.value,
          prioridad: entry.key + 1,
        );
      }).toList();

      if (selectedShippingOptions.contains('paquete') &&
          selectedPackagePercent.value != null &&
          embalajeAmount > 0) {
        productos.add(
          ProductoEntity(
            codigo: 'ARTEMP01',
            descripcion:
                'EMPAQUE Y EMBALAJE (${selectedPackagePercent.value!.toString().replaceAll('.0', '')}%)',
            disponible: 0,
            unidad: 'UNIDAD DE SERVICIO',
            precio: embalajeAmount,
            cantidad: 1,
            importe: embalajeAmount,
            iva: '0.00',
            claveSat: '31181701',
            url: '',
            descuento: 0,
            prioridad: productos.length + 1,
          ),
        );
      }

      if (selectedShippingOptions.contains('envio')) {
        final costoEnvio = envio.value ?? 0.0;
        productos.add(
          ProductoEntity(
            codigo: 'ARTENV01',
            descripcion: costoEnvio > 0
                ? 'COSTO DE ENVÍO'
                : 'COSTO DE ENVIO PENDIENTE',
            disponible: 0,
            unidad: 'UNIDAD DE SERVICIO',
            precio: costoEnvio,
            cantidad: 1,
            importe: costoEnvio,
            iva: '0.00',
            claveSat: '81141606',
            url: '',
            descuento: 0,
            prioridad: productos.length + 1,
          ),
        );
      }

      final Map<String, String> imagenesMap = {};
      for (final item in items) {
        if (!item.isCustom &&
            item.localImagePath.value != null &&
            item.localImagePath.value!.isNotEmpty) {
          final codigo = item.product!.partNumber ?? '';
          if (codigo.isNotEmpty) {
            imagenesMap[codigo] = item.localImagePath.value!;
          }
        }
      }

      final entity = QuoteFromEntity(
        folio: folio.value,
        cliente: clienteName.value.trim(),
        total: totalToPay,
        cataPrecio: selectedPriceType.value,
        descuento: globalDiscountAsPercent.toStringAsFixed(2),
        iva: includeIva.value ? 'SI' : 'NO',
        diasEnt: validUntil.value.difference(DateTime.now()).inDays,
        comentarios: commentsCtrl.text.trim(),
        referencia: referencia.value,
        productos: productos,
        imagenes: imagenesMap.isNotEmpty ? imagenesMap : null,
      );

      final response = await quoteFromUsecase.call(entity);
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

  double get globalDiscountAsPercent {
    if (globalDiscountType.value == 'porcentaje') {
      return globalDiscountPercent.value;
    }
    if (subtotal <= 0) return 0.0;
    return (globalDiscount.value / subtotal) * 100;
  }

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

  void showItemDiscountDialog(BuildContext context, QuoteItem item) {
    final RxDouble tempDiscount = item.discount.value.obs;

    Get.dialog(
      Obx(
        () => AlertDialog(
          backgroundColor: ThemeColor.surfaceColor,
          title: Text('Descuento del producto', style: ThemeColor.headingSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.description,
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.textSecondaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              Text(
                'Selecciona un porcentaje',
                style: ThemeColor.bodySmall.copyWith(
                  color: ThemeColor.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [0, 5, 10, 15, 20, 25, 30].map((pct) {
                  final isSelected = tempDiscount.value == pct.toDouble();
                  return GestureDetector(
                    onTap: () => tempDiscount.value = pct.toDouble(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ThemeColor.primaryColor
                            : ThemeColor.backgroundColor,
                        borderRadius: ThemeColor.circularBorderRadius,
                        border: Border.all(
                          color: isSelected
                              ? ThemeColor.primaryColor
                              : ThemeColor.dividerColor,
                        ),
                      ),
                      child: Text(
                        pct == 0 ? 'Sin desc.' : '$pct%',
                        style: ThemeColor.bodySmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : ThemeColor.textPrimaryColor,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              if (tempDiscount.value > 0)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ThemeColor.errorColor.withOpacity(0.07),
                    borderRadius: ThemeColor.smallBorderRadius,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Descuento ${tempDiscount.value.toInt()}%',
                        style: ThemeColor.bodySmall.copyWith(
                          color: ThemeColor.errorColor,
                        ),
                      ),
                      Text(
                        '-\$${(item.subtotal * (tempDiscount.value / 100)).toStringAsFixed(2)}',
                        style: ThemeColor.bodySmall.copyWith(
                          color: ThemeColor.errorColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                item.discount.value = tempDiscount.value;
                items.refresh();
                Get.back();
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
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
    item.customProduct!.cantidad.value = cantidad;
    item.quantity.value = cantidad;
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
    final descCtrl = TextEditingController(
      text: item.customProduct!.descripcion,
    );
    final costoCtrl = TextEditingController(
      text: item.customProduct!.costo.toStringAsFixed(2),
    );
    final cantCtrl = TextEditingController(
      text: item.quantity.value % 1 == 0
          ? item.quantity.value.toInt().toString()
          : item.quantity.value.toString(),
    );

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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Precio unitario',
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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

  @override
  final Rx<MobileScannerController?> qrScannerController =
      Rx<MobileScannerController?>(null);

  @override
  final RxBool isTorchOn = false.obs;

  @override
  void iniciarEscaneoQR() {
    qrScannerController.value?.dispose();
    qrScannerController.value = null;
    qrScannerController.value = MobileScannerController();
  }

  void _liberarCamara() {
    qrScannerController.value?.dispose();
    qrScannerController.value = null;
  }

  @override
  void detenerEscaneoQR() {
    _liberarCamara();
    if (Get.isBottomSheetOpen ?? false) Get.back();
  }

  void reiniciarEscaneoQR() {
    _liberarCamara();
    qrScannerController.value = MobileScannerController();
  }

  @override
  void toggleTorch() {
    isTorchOn.value = !isTorchOn.value;
    qrScannerController.value?.toggleTorch();
  }

  @override
  void switchCamera() {
    qrScannerController.value?.switchCamera();
  }

  @override
  void onQRCodeDetected(String qrData) {
    detenerEscaneoQR();
    _buscarPorNumParte(qrData.trim());
  }

  final RxBool isSearchingByQR = false.obs;
  Future<void> _buscarPorNumParte(String qrData) async {
    final idProducto = int.tryParse(qrData.trim());
    if (idProducto == null) {
      showErrorSnackbar('Código QR no válido');
      return;
    }

    try {
      isSearchingByQR.value = true;

      final inventoryCtrl = Get.find<InventoryController>();
      final results = await inventoryCtrl.fetchInventarioUsecase.call(
        '',
        '',
        '',
        '',
        1,
        20,
        idProducto: idProducto,
      );

      if (results.isEmpty) {
        showErrorSnackbar('No se encontró producto con ID: $idProducto');
        return;
      }

      results.length == 1
          ? addProduct(results.first)
          : _showQRResultsSheet(results);
    } catch (e) {
      showErrorSnackbar('Error al buscar producto por QR');
      debugPrint('_buscarPorNumParte error: $e');
    } finally {
      isSearchingByQR.value = false;
    }
  }

  void _showQRResultsSheet(List<InventoryEntity> results) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(ThemeColor.paddingMedium),
          decoration: const BoxDecoration(
            color: ThemeColor.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ThemeColor.textSecondaryColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Selecciona producto (${results.length})',
                style: ThemeColor.headingSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: results.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: ThemeColor.dividerColor),
                  itemBuilder: (_, i) {
                    final p = results[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        p.description ?? '',
                        style: ThemeColor.bodyMedium,
                      ),
                      subtitle: Text(
                        'Parte: ${p.partNumber ?? ''} · \$${(p.price ?? 0).toStringAsFixed(2)}',
                        style: ThemeColor.bodySmall.copyWith(
                          color: ThemeColor.textSecondaryColor,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: ThemeColor.accentColor,
                      ),
                      onTap: () {
                        Get.back();
                        addProduct(p);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void abrirScannerQR(BuildContext context) {
    iniciarEscaneoQR();
    Get.bottomSheet(
      QRScannerWidget(
        controller: this,
        title: 'ESCANEAR PRODUCTO',
        description: 'Apunta al código QR o de barras del producto',
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).then((_) => _liberarCamara());
  }

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
