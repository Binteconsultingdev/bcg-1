import 'package:bcg/common/errors/convert_message.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/common/controller/product_search_controller.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/post_validate_cart_entity.dart';
import 'package:bcg/features/Inventory/domain/usecase/validate_cart_usecase.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
import 'package:bcg/features/client/presentation/controller/client_search_controller.dart';
import 'package:bcg/features/client/presentation/page/client_search_sheet.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_quotes_byid_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/generate_pdf_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/put_quotes_usecase.dart';
import 'package:bcg/features/quotes/presentation/controller/quotes_controller.dart';
import 'package:bcg/features/quotes/presentation/widget/create_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditQuoteItem {
  final int? productId;
  final RxString codigo;
  final RxString descripcion;
  final RxDouble precio;
  final RxDouble quantity;
  final RxDouble descuento;
  final String unidad;
  final String claveSat;
  final String url;
  final num disponible;
  int prioridad;

  EditQuoteItem({
    this.productId,
    required String codigo,
    required String descripcion,
    required double precio,
    required double quantity,
    required double descuento,
    required this.unidad,
    required this.claveSat,
    required this.url,
    required this.disponible,
    required this.prioridad,
  }) : codigo = codigo.obs,
       descripcion = descripcion.obs,
       precio = precio.obs,
       quantity = quantity.obs,
       descuento = descuento.obs;

  RxDouble get totalRx => total.obs;
  double get subtotal => precio.value * quantity.value;
  double get discountAmount => subtotal * (descuento.value / 100);
  double get total => subtotal - discountAmount;

  factory EditQuoteItem.fromInventory(InventoryEntity product, int index) {
    return EditQuoteItem(
      productId: product.id,
      codigo: product.partNumber ?? '',
      descripcion: product.description ?? '',
      precio: (product.price ?? 0).toDouble(),
      quantity: 1,
      descuento: 0,
      unidad: 'PZA',
      claveSat: '',
      url: product.imageUrl ?? '',
      disponible: product.availableQuantity ?? 0,
      prioridad: index,
    );
  }

  factory EditQuoteItem.fromProductoEntity(ProductoEntity p) {
    return EditQuoteItem(
      productId: (p.id != null && p.id != 0) ? p.id : null,
      codigo: p.codigo,
      descripcion: p.descripcion,
      precio: p.precio,
      quantity: p.cantidad.toDouble(),
      descuento: p.descuento,
      unidad: p.unidad,
      claveSat: p.claveSat,
      url: p.url,
      disponible: p.disponible,
      prioridad: p.prioridad,
    );
  }
  final RxnString localImagePath = RxnString();

  bool get isCustom =>
      codigo.value == 'CUSTOM' ||
      (productId == null &&
          codigo.value != 'ARTEMP01' &&
          codigo.value != 'ARTENV01');
}

class PutQuotesController extends GetxController {
  final PutQuotesUsecase putQuotesUsecase;
  final FetchQuotesByidUsecase fetchQuotesByidUsecase;
  final GeneratePdfUsecase generatePdfUsecase;
  final ValidateCartUsecase validateCartUsecase;

  PutQuotesController({
    required this.putQuotesUsecase,
    required this.fetchQuotesByidUsecase,
    required this.generatePdfUsecase,
    required this.validateCartUsecase,
  });

  late final QuotesController _quotesCtrl = Get.find<QuotesController>();
  late final ClientController _clientCtrl = Get.find<ClientController>();
  late final PdfController _pdfCtrl = Get.find<PdfController>();

  bool get isLoadingPdf => _pdfCtrl.isLoadingPdf.value;

  final Rxn<int> quoteId = Rxn<int>();

  final isLoadingQuote = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  final folio = ''.obs;
  final clienteName = ''.obs;
  final clienteController = TextEditingController();
  final selectedPriceType = 'REGULAR'.obs;
  final validUntil = DateTime.now().add(const Duration(days: 15)).obs;
  final globalDiscount = 0.0.obs;
  final globalDiscountType = 'monto'.obs;
  final globalDiscountPercent = 0.0.obs;

  final isValidatingCart = false.obs;
  final validatedPriceWithoutVAT = Rxn<double>();
  final validatedPriceWithVAT = Rxn<double>();

  final items = <EditQuoteItem>[].obs;
  final selectedShippingOptions = <String>{}.obs;
  final selectedPackagePercent = Rxn<double>();
  final envio = Rxn<double>();

  double get embalajeAmount {
    if (!selectedShippingOptions.contains('paquete')) return 0.0;
    final pct = selectedPackagePercent.value;
    if (pct == null) return 0.0;
    return subtotal * (pct / 100);
  }

  final commentsCtrl = TextEditingController();
  final globalDiscountCtrl = TextEditingController();

  final quoteStatus = ''.obs;

  bool get isEditable => quoteStatus.value.toUpperCase() == 'GENERADA';
  bool get hasOutOfStockItems => items.any((i) => i.disponible <= 0);

  final List<String> priceOptions = [
    'REGULAR',
    'MEDIO M',
    'PAQUETE',
    'MAYOREO',
    'ESPECIAL',
  ];

  double get subtotal => items.fold(0, (s, i) => s + i.total);

  final includeIva = true.obs;

  double get ivaAmount =>
      includeIva.value ? (subtotal - globalDiscount.value) * 0.16 : 0.0;
  double get totalToPay =>
      subtotal - globalDiscount.value + ivaAmount + (envio.value ?? 0.0);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['idQuote'] != null) {
      loadQuote(args['idQuote'] as int);
    }

    Get.find<ClientSearchController>().onFreeText = onFreeTextClient;
    Get.find<ClientSearchController>().showResults.value = false;
    Get.find<ClientSearchController>().manuallyClosed = true;

    ever(selectedPriceType, (_) => validateCart());
  }

  Future<void> validateCart() async {
    final validItems = items
        .where((i) => i.productId != null && i.productId! > 0)
        .toList();

    if (validItems.isEmpty) {
      validatedPriceWithoutVAT.value = null;
      validatedPriceWithVAT.value = null;
      return;
    }

    try {
      isValidatingCart.value = true;

      final response = await validateCartUsecase.call(
        PostValidateCartEntity(
          pricetype: selectedPriceType.value,
          items: validItems
              .map(
                (i) => PostItemValidateCartEntity(
                  productid: i.productId!,
                  quantity: i.quantity.value.toInt(),
                ),
              )
              .toList(),
        ),
      );

      for (final r in response.items) {
        final match = items.firstWhereOrNull((i) => i.productId == r.productid);
        if (match != null) {
          match.precio.value = r.newPrice;
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

  void onFreeTextClient(String value) {
    clienteName.value = value;
  }

  void onClientSelected(ClientEntity client) {
    final name = client.displayName ?? '';
    clienteController.text = name;
    clienteName.value = name;
    Get.find<ClientSearchController>().searchCtrl.text = name;
  }

  Future<void> loadQuote(int id) async {
    try {
      quoteId.value = id;
      isLoadingQuote.value = true;
      errorMessage.value = '';
      final quote = await fetchQuotesByidUsecase.call(id);
      _populateFromEntity(quote);
      await validateCart();
    } catch (e) {
      errorMessage.value = 'Error al cargar cotización: $e';
      showErrorSnackbar('Error al cargar cotización');
    } finally {
      isLoadingQuote.value = false;
    }
  }

  void toggleShippingOption(String option) {
    if (selectedShippingOptions.contains(option)) {
      selectedShippingOptions.remove(option);
      if (option == 'paquete') {
        selectedPackagePercent.value = null;
        items.removeWhere((i) => i.codigo.value == 'ARTEMP01');
      }
      if (option == 'envio') {
        envio.value = null;
        items.removeWhere((i) => i.codigo.value == 'ARTENV01');
      }
    } else {
      selectedShippingOptions.add(option);
      if (option == 'envio') envio.value = 0.0;
    }
  }

  void _populateFromEntity(QuoteEntity quote) {
    folio.value = quote.folio;
    quoteStatus.value = quote.status ?? '';
    clienteName.value = quote.cliente;
    clienteController.text = quote.cliente;
    selectedPriceType.value = quote.cataPrecio;
    commentsCtrl.text = quote.comentarios;

    final daysToAdd = quote.diasEnt > 0 ? quote.diasEnt : 15;
    validUntil.value = DateTime.now().add(Duration(days: daysToAdd));

    final desc = double.tryParse(quote.descuento) ?? 0;
    globalDiscount.value = desc;
    if (desc > 0) globalDiscountCtrl.text = desc.toStringAsFixed(2);

    selectedShippingOptions.clear();
    selectedPackagePercent.value = null;
    envio.value = null;

    items.assignAll(
      quote.productos.map((p) => EditQuoteItem.fromProductoEntity(p)).toList(),
    );

    final embalajeItem = items.firstWhereOrNull(
      (i) => i.codigo.value == 'ARTEMP01',
    );
    if (embalajeItem != null) {
      selectedShippingOptions.add('paquete');
      final match = RegExp(
        r'\((\d+\.?\d*)%\)',
      ).firstMatch(embalajeItem.descripcion.value);
      if (match != null) {
        selectedPackagePercent.value = double.tryParse(match.group(1) ?? '');
      }
    }
    final envioItem = items.firstWhereOrNull(
      (i) => i.codigo.value == 'ARTENV01',
    );
    if (envioItem != null) {
      selectedShippingOptions.add('envio');
      envio.value = envioItem.precio.value > 0 ? envioItem.precio.value : 0.0;
    }

    final clientSearch = Get.find<ClientSearchController>();
    clientSearch.searchCtrl.text = quote.cliente;
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
        },
      ),
    );
  }

  void addProduct(InventoryEntity product) {
    if ((product.price ?? 0) <= 0) {
      showErrorSnackbar('Este producto no tiene precio asignado');
      return;
    }
    final existing = items.firstWhereOrNull(
      (i) => i.codigo.value == (product.partNumber ?? ''),
    );
    if (existing != null) {
      existing.quantity.value++;
    } else {
      items.add(EditQuoteItem.fromInventory(product, items.length + 1));
    }
    Get.find<ProductSearchController>().clearSearch();
    validateCart();
  }

  void removeItem(EditQuoteItem item) {
    items.remove(item);
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

  Future<void> saveQuote(BuildContext context) async {
    final id = quoteId.value;
    if (id == null) return;

    if (!isEditable) {
      showErrorSnackbar(
        'Solo se pueden editar cotizaciones con estatus GENERADA',
      );
      return;
    }
    if (clienteName.value.trim().isEmpty) {
      showErrorSnackbar('Selecciona un cliente para continuar');
      return;
    }
    if (items.isEmpty) {
      showErrorSnackbar('Agrega al menos un producto');
      return;
    }

    try {
      isSaving.value = true;
      errorMessage.value = '';

      await validateCart();

      final productosBase = items
          .where(
            (i) => i.codigo.value != 'ARTEMP01' && i.codigo.value != 'ARTENV01',
          )
          .toList();

      final List<ProductoEntity> productos = productosBase.asMap().entries.map((
        entry,
      ) {
        final i = entry.value;
        return ProductoEntity(
          codigo: i.codigo.value,
          descripcion: i.descripcion.value,
          disponible: i.disponible,
          unidad: i.unidad,
          precio: i.precio.value,
          cantidad: i.quantity.value,
          importe: i.total,
          iva: (i.total * 0.16).toStringAsFixed(2),
          claveSat: i.claveSat,
          url: i.url,
          descuento: i.descuento.value,
          prioridad: entry.key + 1,
        );
      }).toList();

      if (selectedShippingOptions.contains('paquete') &&
          selectedPackagePercent.value != null) {
        final subtotalBase = productosBase.fold(0.0, (s, i) => s + i.total);
        final monto = subtotalBase * (selectedPackagePercent.value! / 100);
        if (monto > 0) {
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
              claveSat: '',
              url:
                  'https://web.whatsapp.com"https://sgp-web.nyc3.digitaloceanspaces.com/sgp-web/Stown/Productos/PT_16042605083190',
              descuento: 0,
              prioridad: productos.length + 1,
            ),
          );
        }
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
            claveSat: '',
            url:
                'https://web.whatsapp.com"https://sgp-web.nyc3.digitaloceanspaces.com/sgp-web/Stown/Productos/PT_16042605083190',
            descuento: 0,
            prioridad: productos.length + 1,
          ),
        );
      }

      final entity = QuoteEntity(
        folio: folio.value,
        cliente: clienteName.value.trim(),
        total: totalToPay,
        cataPrecio: selectedPriceType.value,
        descuento: globalDiscountType.value == 'porcentaje'
            ? globalDiscountPercent.value.toStringAsFixed(2)
            : globalDiscount.value.toStringAsFixed(2),
        iva: includeIva.value ? 'SI' : 'NO',
        diasEnt: validUntil.value.difference(DateTime.now()).inDays,
        comentarios: commentsCtrl.text.trim(),
        referencia: '',
        productos: productos,
      );

      await putQuotesUsecase.call(id, entity);
      await _quotesCtrl.fetchQuotes();
      await generateAndOpenPdf(context);
    } catch (e) {
      errorMessage.value = 'Error al guardar: $e';
      showErrorSnackbar(
        'Error al guardar cotización ${cleanExceptionMessage(e)}',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> generateAndOpenPdf(BuildContext context) async {
    final id = quoteId.value;
    if (id == null) return;

    try {
      _pdfCtrl.reset();
      _pdfCtrl.isLoadingPdf.value = true;
      final result = await generatePdfUsecase.call(id);

      if (result.generated && result.urlpdf.isNotEmpty) {
        _pdfCtrl.folio = folio.value;
        _pdfCtrl.setPdfUrl(result.urlpdf);
        _pdfCtrl.isLoadingPdf.value = false;
        _pdfCtrl.showOptionsSheet(context);
      }
    } catch (e) {
      showErrorSnackbar('Error al generar PDF');
    } finally {
      _pdfCtrl.isLoadingPdf.value = false;
    }
  }

  void showItemDiscountDialog(BuildContext context, EditQuoteItem item) {
    final RxDouble tempDiscount = item.descuento.value.obs;

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
                item.descripcion.value,
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
                item.descuento.value = tempDiscount.value;
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

  void showEditCustomProductDialog(BuildContext context, EditQuoteItem item) {
    final descCtrl = TextEditingController(text: item.descripcion.value);
    final costoCtrl = TextEditingController(
      text: item.precio.value.toStringAsFixed(2),
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
              final desc = descCtrl.text.trim();
              final costo = double.tryParse(costoCtrl.text) ?? 0;
              final cant = double.tryParse(cantCtrl.text) ?? 1;
              if (desc.isEmpty) {
                showErrorSnackbar('Ingresa una descripción');
                return;
              }
              if (costo <= 0) {
                showErrorSnackbar('El costo debe ser mayor a 0');
                return;
              }
              if (cant <= 0) {
                showErrorSnackbar('La cantidad debe ser mayor a 0');
                return;
              }
              item.descripcion.value = desc;
              item.precio.value = costo;
              item.quantity.value = cant;
              items.refresh();
              Get.back();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    clienteController.dispose();
    commentsCtrl.dispose();
    globalDiscountCtrl.dispose();
    super.onClose();
  }
}
