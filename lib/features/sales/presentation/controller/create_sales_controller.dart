import 'package:bcg/common/controller/product_search_controller.dart';
import 'package:bcg/common/errors/convert_message.dart';
import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/services/lisencias.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_search_controller.dart';
import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_quote_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_quotes_byid_usecase.dart';
import 'package:bcg/features/quotes/presentation/widget/create_pdf_controller.dart';
import 'package:bcg/features/sales/domain/entities/create_sales_entity.dart';
import 'package:bcg/features/sales/domain/usecase/generate_pdf_sales.dart';
import 'package:bcg/features/sales/domain/usecase/generate_sales_usecase.dart';
import 'package:bcg/features/sales/presentation/controller/sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SaleItem {
  final InventoryEntity product;
  final RxDouble quantity;
  final RxDouble discount;
  final RxnDouble manualPriceOverride = RxnDouble();

  SaleItem({required this.product, double initialQty = 1.0})
    : quantity = initialQty.obs,
      discount = 0.0.obs;

  double get unitPrice =>
      manualPriceOverride.value ?? (product.price ?? 0).toDouble();
  double get subtotal => unitPrice * quantity.value;
  double get total => subtotal - (subtotal * (discount.value / 100));
  double get stock => (product.availableQuantity ?? 0).toDouble();
  RxDouble get totalRx => total.obs;
}

class CreateSalesController extends GetxController {
  final GenerateSalesUsecase generateSalesUsecase;
  final FetchQuotesByidUsecase fetchQuotesByidUsecase;
  final FetchQuoteUsecase fetchQuoteUsecase;
  final GeneratePdfSales generatePdfSales;

  CreateSalesController({
    required this.generateSalesUsecase,
    required this.fetchQuotesByidUsecase,
    required this.fetchQuoteUsecase,
    required this.generatePdfSales,
  });

  final _authService = AuthService();
  late final _salesCtrl = Get.find<SalesController>();
  late final PdfController _pdfCtrl = Get.find<PdfController>();

  bool get isLoadingPdf => _pdfCtrl.isLoadingPdf.value;

  final createdSaleId = Rxn<int>();

  final clienteName = ''.obs;
  final clienteController = TextEditingController();
  final selectedClientId = Rxn<int>();

  final metodoEmbarque = 'CAMIONETA'.obs;
  final incIVA = true.obs;
  final validUntil = DateTime.now().add(const Duration(days: 15)).obs;
  final globalDiscount = 0.0.obs;
  final globalDiscountType = 'monto'.obs;
  final globalDiscountPercent = 0.0.obs; 
  final items = <SaleItem>[].obs;
  final quoteSearchType = 'folio'.obs;

  final quoteSearchInput = ''.obs;
  final quoteSearchCtrl = TextEditingController();
  final isSearchingQuote = false.obs;
  final isSearchingQuoteApi = false.obs;
  final isLoadingQuote = false.obs;
  final selectedFolioQuote = ''.obs;
  final quoteResults = <GetQuoteEntity>[].obs;
 
  final isCreating = false.obs;
  final errorMessage = ''.obs;

  final commentsCtrl = TextEditingController();
  final globalDiscountCtrl = TextEditingController();
  final referenciaCtrl = TextEditingController();

  final metodosEmbarque = ['CAMIONETA', 'CLIENTE RECOGE', 'PAQUETERIA'];

  Worker? _quoteSearchDebounce;

  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get ivaAmount =>
      incIVA.value ? (subtotal - globalDiscount.value) * 0.16 : 0;

  double get totalToPay =>
      subtotal -
      globalDiscount.value +
      ivaAmount +
      (envio.value ?? 0.0) +
      embalajeAmount;
  bool get hasOutOfStockItems => items.any((i) {
    final stock = (i.product.availableQuantity ?? 0);
    return stock <= 0 || i.quantity.value > stock;
  });

  final selectedShippingOptions = <String>{}.obs;
  final selectedPackagePercent = Rxn<double>();
  final envio = Rxn<double>();
  @override
  void onInit() {
    super.onInit();
    print('🟢 CreateSalesController.onInit() ejecutado');
     
    _quoteSearchDebounce = debounce(
      quoteSearchInput,
      (v) => v.trim().isNotEmpty ? searchQuoteByFolio() : quoteResults.clear(),
      time: const Duration(milliseconds: 600),
    );
  } 
 
  double get embalajeAmount {
    if (!selectedShippingOptions.contains('paquete')) return 0.0;
    final pct = selectedPackagePercent.value;
    if (pct == null) return 0.0;
    return subtotal * (pct / 100);
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

  void onClientSelected(ClientEntity client) {
    final name = client.displayName ?? '';
    clienteController.text = name;
    clienteName.value = name;
    selectedClientId.value = client.id;
    Get.find<ClientSearchController>().searchCtrl.text = name;
  }

  void addProduct(InventoryEntity product) {
    if ((product.price ?? 0) <= 0) {
      showErrorSnackbar('Este producto no tiene precio asignado');
      return;
    }
    final existing = items.firstWhereOrNull((i) => i.product.id == product.id);
    existing != null
        ? existing.quantity.value++
        : items.add(SaleItem(product: product));
    Get.find<ProductSearchController>().clearSearch();
  }

  void removeItem(SaleItem item) => items.remove(item);

  void onQuoteSearchChanged(String value) {
    quoteSearchInput.value = value;
    isSearchingQuote.value = value.isNotEmpty;
    if (value.isEmpty) quoteResults.clear();
  }

  Future<void> searchQuoteByFolio() async {
    final query = quoteSearchInput.value.trim();
    if (query.isEmpty) return;
    try {
      isSearchingQuoteApi.value = true;

      final results = await Future.wait([
        fetchQuoteUsecase.cal('', '', '', '', '', 1, 10, folio: query),
        fetchQuoteUsecase.cal(query, '', '', '', '', 1, 10),
        fetchQuoteUsecase.cal('', '', '', '', '', 1, 10, id: query),
      ]);

      final seen = <String>{};
      final merged = <GetQuoteEntity>[];
      for (final list in results) {
        for (final item in list) {
          final key = item.id?.toString() ?? item.folito ?? '';
          if (seen.add(key)) merged.add(item);
        }
      }

      quoteResults.assignAll(merged);
    } catch (e) {
      print(e);
    } finally {
      isSearchingQuoteApi.value = false;
    }
  }

  Future<void> loadInitialQuotes() async {
    try {
      isSearchingQuoteApi.value = true;
      quoteResults.assignAll(
        await fetchQuoteUsecase.cal('', '', 'GENERADA', '', '', 1, 20),
      );
    } catch (e) {
      print(e);
    } finally {
      isSearchingQuoteApi.value = false;
    }
  }

  int? _parseClientIdFromName(String nombre) {
    final match = RegExp(r'^\((\d+)\)').firstMatch(nombre.trim());
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  Future<void> loadFromQuote(GetQuoteEntity quoteEntity) async {
    if (quoteEntity.id == null) return;
    if ((quoteEntity.status ?? '').toUpperCase() != 'GENERADA') {
      showErrorSnackbar(
        'Solo se pueden cargar cotizaciones con estatus GENERADA',
      );
      return;
    }
    try {
      isLoadingQuote.value = true;

      final quote = await fetchQuotesByidUsecase.call(quoteEntity.id!);

      clienteController.text = quote.cliente;
      clienteName.value = quote.cliente;
      Get.find<ClientSearchController>().searchCtrl.text = quote.cliente;

      selectedClientId.value = _parseClientIdFromName(quote.cliente);
      commentsCtrl.text = quote.comentarios;
      referenciaCtrl.text = quote.folio;
      selectedFolioQuote.value = quote.folio;

      final desc = double.tryParse(quote.descuento) ?? 0;
      if (desc > 0) {
        globalDiscount.value = desc;
        globalDiscountCtrl.text = desc.toStringAsFixed(2);
      }

      selectedShippingOptions.clear();
      selectedPackagePercent.value = null;
      envio.value = null;

      final embalajeProducto = quote.productos.firstWhereOrNull(
        (p) => p.codigo == 'ARTEMP01',
      );
      if (embalajeProducto != null) {
        selectedShippingOptions.add('paquete');
        final match = RegExp(
          r'\((\d+\.?\d*)%\)',
        ).firstMatch(embalajeProducto.descripcion);
        if (match != null) {
          selectedPackagePercent.value = double.tryParse(match.group(1) ?? '');
        }
      }

      final envioProducto = quote.productos.firstWhereOrNull(
        (p) => p.codigo == 'ARTENV01',
      );
      if (envioProducto != null) {
        selectedShippingOptions.add('envio');
        envio.value = envioProducto.precio > 0 ? envioProducto.precio : 0.0;
      }

      items.assignAll(
        quote.productos
            .where((p) => p.codigo != 'ARTEMP01' && p.codigo != 'ARTENV01')
            .map(
              (p) => SaleItem(
                product: InventoryEntity(
                  id: 0,
                  partNumber: p.codigo,
                  description: p.descripcion,
                  price: p.precio,
                  availableQuantity: p.disponible.toInt(),
                  imageUrl: p.url.isNotEmpty ? p.url : null,
                ),
                initialQty: p.cantidad,
              ),
            ),
      );

      _clearQuoteSearch();
      showSuccessSnackbar('Cotización ${quote.folio} cargada correctamente');
    } catch (e) {
      showErrorSnackbar('Error al cargar cotización: $e');
    } finally {
      isLoadingQuote.value = false;
    }
  }

  void _clearQuoteSearch() {
    quoteResults.clear();
    quoteSearchCtrl.clear();
    quoteSearchInput.value = '';
    isSearchingQuote.value = false;
  }
void showItemDiscountDialog(BuildContext context, SaleItem item) {
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
              item.product.description ?? '',
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
  void showEditPriceDialog(BuildContext context, SaleItem item) {
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
              item.product.description ?? '',
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

  Future<void> createSale() async {
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
      final vendedor = (await _authService.getUserData())?.nombre ?? '';

      final List<PartidaEntity> partidas = items
          .map(
            (i) => PartidaEntity(
              numParte: i.product.partNumber ?? '',
              descripcion: i.product.description ?? '',
              cantidad: i.quantity.value,
              precio: i.unitPrice,
              claveSat: '',
              um: 'PZA',
              descuento: i.discount.value, 
            ),
          )
          .toList();

      if (selectedShippingOptions.contains('paquete') &&
          selectedPackagePercent.value != null &&
          embalajeAmount > 0) {
        partidas.add(
          PartidaEntity(
            numParte: 'ARTEMP01',
            descripcion:
                'EMPAQUE Y EMBALAJE (${selectedPackagePercent.value!.toString().replaceAll('.0', '')}%)',
            cantidad: 1,
            precio: embalajeAmount,
            claveSat: '31181701',
            um: 'UNIDAD DE SERVICIO',
             descuento: 0, 
          ),
        );
      }

      if (selectedShippingOptions.contains('envio')) {
        final costoEnvio = envio.value ?? 0.0;
        partidas.add(
          PartidaEntity(
            numParte: 'ARTENV01',
            descripcion: costoEnvio > 0
                ? 'COSTO DE ENVÍO'
                : 'COSTO DE ENVIO PENDIENTE',
            cantidad: 1,
            precio: costoEnvio,
            claveSat: '81141606',
            um: 'UNIDAD DE SERVICIO',
             descuento: 0, 
          ),
        );
      }

      final response = await generateSalesUsecase.call(
        CreateSalesEntity(
          numCliente: selectedClientId.value ?? 0,
          cliente: clienteName.value.trim(),
          vendedor: vendedor,
          user: vendedor,
          metodoEmb: metodoEmbarque.value,
          comentarios: commentsCtrl.text.trim(),
          refe: referenciaCtrl.text.trim(),
          fechaEntrega: validUntil.value,
          incIVA: incIVA.value,
          folioPre: selectedFolioQuote.value,
          descuento: globalDiscountAsPercent,
          partidas: partidas,
        ),
      );

      createdSaleId.value = response.saleId;
      await _salesCtrl.fetchSales();
      showSuccessSnackbar('Venta creada correctamente');
      await generateAndOpenPdf();
    } catch (e) {
      errorMessage.value = cleanExceptionMessage(e);
      showErrorSnackbar(errorMessage.value);
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
    final id = createdSaleId.value;
    if (id == null) return;

    try {
      _pdfCtrl.reset();
      _pdfCtrl.isLoadingPdf.value = true;
      final result = await generatePdfSales.call(id);

      if (result.generated && result.urlpdf.isNotEmpty) {
        _pdfCtrl.folio = 'venta_$id';
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

  @override
  void onClose() {
    _quoteSearchDebounce?.dispose();
    selectedShippingOptions.clear();
    selectedPackagePercent.value = null;
    envio.value = null;
    for (final c in [
      clienteController,
      commentsCtrl,
      globalDiscountCtrl,
      referenciaCtrl,
      quoteSearchCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
