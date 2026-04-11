import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
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

class QuoteItem {
  final InventoryEntity product;
  final RxDouble quantity;
  final RxDouble discount;

  QuoteItem({required this.product, double initialQty = 1.0})
      : quantity = initialQty.obs,
        discount = 0.0.obs;

  double get unitPrice => (product.price ?? 0).toDouble();
  double get subtotal => unitPrice * quantity.value;
  double get discountAmount => subtotal * (discount.value / 100);
  double get total => subtotal - discountAmount;
  RxDouble get totalRx => total.obs;
}

class CreateQuoteController extends GetxController {
  final CreateQuotesUsecase createQuotesUsecase;
  final FetchFolioUsecase fetchFolioUsecase;
  final GeneratePdfUsecase generatePdfUsecase;

  CreateQuoteController({
    required this.createQuotesUsecase,
    required this.fetchFolioUsecase,
    required this.generatePdfUsecase,
  });

  late final QuotesController _quotesCtrl = Get.find<QuotesController>();
  late final ClientController _clientCtrl = Get.find<ClientController>();
  late final PdfController _pdfCtrl = Get.find<PdfController>();

  bool get hasOutOfStockItems =>
      items.any((i) => (i.product.availableQuantity ?? 0) <= 0);

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
  final errorMessage = ''.obs;

  final commentsCtrl = TextEditingController();
  final productSearchCtrl = TextEditingController();
  final globalDiscountCtrl = TextEditingController();

  final createdQuoteId = Rxn<int>();

  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get ivaAmount => (subtotal - globalDiscount.value) * 0.16;
  double get totalToPay => subtotal - globalDiscount.value + ivaAmount;

  @override
  void onInit() {
    super.onInit();
    _loadFolio();
    resetState();
    Get.find<ClientSearchController>().onFreeText = onFreeTextClient;
    Get.find<ClientSearchController>().showResults.value = false;
    Get.find<ClientSearchController>().manuallyClosed = true;
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
    final existing = items.firstWhereOrNull((i) => i.product.id == product.id);
    if (existing != null) {
      existing.quantity.value++;
    } else {
      items.add(QuoteItem(product: product));
    }
    productSearchCtrl.clear();
    productSearchQuery.value = '';
    isSearching.value = false;
    searchResults.clear();
  }

  void removeItem(QuoteItem item) => items.remove(item);

  void duplicateItem(QuoteItem item) {
    items.add(QuoteItem(product: item.product, initialQty: item.quantity.value));
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
    globalDiscountCtrl.text =
        globalDiscount.value > 0 ? globalDiscount.value.toStringAsFixed(2) : '';
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

      final response = await createQuotesUsecase.call(entity);
      createdQuoteId.value = response.id;
      await _quotesCtrl.fetchQuotes();
    } catch (e) {
      errorMessage.value = 'Error al crear cotización: $e';
      showErrorSnackbar('Error al crear cotización');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> generateAndOpenPdf(BuildContext context) async {
    final id = createdQuoteId.value;
    if (id == null) return;

    try {
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