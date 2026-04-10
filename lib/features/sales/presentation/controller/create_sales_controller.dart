import 'package:bcg/common/controller/product_search_controller.dart';
import 'package:bcg/common/errors/convert_message.dart';
import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_search_controller.dart';
import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_quote_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_quotes_byid_usecase.dart';
import 'package:bcg/features/sales/domain/entities/create_sales_entity.dart';
import 'package:bcg/features/sales/domain/usecase/generate_sales_usecase.dart';
import 'package:bcg/features/sales/presentation/controller/sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SaleItem {
  final InventoryEntity product;
  final RxDouble quantity;
  final RxDouble discount;

  SaleItem({required this.product, double initialQty = 1.0})
    : quantity = initialQty.obs,
      discount = 0.0.obs;

  double get unitPrice => (product.price ?? 0).toDouble();
  double get subtotal => unitPrice * quantity.value;
  double get total => subtotal - (subtotal * (discount.value / 100));
  double get stock => (product.availableQuantity ?? 0).toDouble();
  RxDouble get totalRx => total.obs;
}

class CreateSalesController extends GetxController {
  final GenerateSalesUsecase generateSalesUsecase;
  final FetchQuotesByidUsecase fetchQuotesByidUsecase;
  final FetchQuoteUsecase fetchQuoteUsecase;

  CreateSalesController({
    required this.generateSalesUsecase,
    required this.fetchQuotesByidUsecase,
    required this.fetchQuoteUsecase,
  });

  final _authService = AuthService();
  late final _salesCtrl = Get.find<SalesController>();

  // — Cliente —
  final clienteName = ''.obs;
  final clienteController = TextEditingController();
  final selectedClientId = Rxn<int>();

  // — Config venta —
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
  final tipoCambioCtrl = TextEditingController(text: '1.00');

  final metodosEmbarque = ['CAMIONETA', 'CLIENTE RECOGE', 'PAQUETERIA'];

  Worker? _quoteSearchDebounce;
 
  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get ivaAmount =>
      incIVA.value ? (subtotal - globalDiscount.value) * 0.16 : 0;
  double get totalToPay => subtotal - globalDiscount.value + ivaAmount;
  bool get hasOutOfStockItems =>
      items.any((i) => (i.product.availableQuantity ?? 0) <= 0);

  @override
  void onInit() {
    super.onInit();
    _quoteSearchDebounce = debounce(
      quoteSearchInput,
      (v) => v.trim().isNotEmpty ? searchQuoteByFolio() : quoteResults.clear(),
      time: const Duration(milliseconds: 600),
    );
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
        fetchQuoteUsecase.cal('', '', '', '', 1, 10, folio: query),
        fetchQuoteUsecase.cal(query, '', '', '', 1, 10),
        fetchQuoteUsecase.cal('', '', '', '', 1, 10, id: query),
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
      showErrorSnackbar('Error al buscar cotización: $e');
    } finally {
      isSearchingQuoteApi.value = false;
    }
  }

  Future<void> loadInitialQuotes() async {
    try {
      isSearchingQuoteApi.value = true;
      quoteResults.assignAll(
        await fetchQuoteUsecase.cal('', '', '', '', 1, 20),
      );
    } catch (e) {
      showErrorSnackbar('Error al cargar cotizaciones: $e');
    } finally {
      isSearchingQuoteApi.value = false;
    }
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

      final idMatch = RegExp(r'^\((\d+)\)\s*').firstMatch(quote.cliente);
      if (idMatch != null) {
        selectedClientId.value = int.tryParse(idMatch.group(1) ?? '');
        final nombre = quote.cliente
            .replaceFirst(idMatch.group(0)!, '')
            .replaceAll('"', '')
            .replaceAll("'", '')
            .trim();
        clienteController.text = nombre;
        clienteName.value = nombre;
        Get.find<ClientSearchController>().searchCtrl.text = nombre;
      } else {
        clienteController.text = quote.cliente;
        clienteName.value = quote.cliente;
        Get.find<ClientSearchController>().searchCtrl.text = quote.cliente;
      }

      commentsCtrl.text = quote.comentarios;
      referenciaCtrl.text = quote.folio;
      selectedFolioQuote.value = quote.folio;

      final desc = double.tryParse(quote.descuento) ?? 0;
      if (desc > 0) {
        globalDiscount.value = desc;
        globalDiscountCtrl.text = desc.toStringAsFixed(2);
      }

      items.assignAll(
        quote.productos.map(
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

  // — Fecha —
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

  // — Crear venta —
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

      await generateSalesUsecase.call(
        CreateSalesEntity(
          numCliente: selectedClientId.value ?? 0,
          cliente: clienteName.value.trim(),
          vendedor: vendedor,
          user: vendedor,
          metodoEmb: metodoEmbarque.value,
          comentarios: commentsCtrl.text.trim(),
          refe: referenciaCtrl.text.trim(),
          fechaEntrega: validUntil.value,
          tc: double.tryParse(tipoCambioCtrl.text) ?? 1.0,
          incIVA: incIVA.value,
          folioPre: selectedFolioQuote.value,
          descuento: globalDiscount.value,
          partidas: items
              .map(
                (i) => PartidaEntity(
                  numParte: i.product.partNumber ?? '',
                  descripcion: i.product.description ?? '',
                  cantidad: i.quantity.value,
                  precio: i.unitPrice,
                  claveSat: '',
                  um: 'PZA',
                ),
              )
              .toList(),
        ),
      );

      await _salesCtrl.fetchSales();
      showSuccessSnackbar('Venta creada correctamente');
    } catch (e) {
      errorMessage.value = cleanExceptionMessage(e);
      showErrorSnackbar(errorMessage.value);
    } finally {
      isCreating.value = false;
    }
  }

  @override
  void onClose() {
    _quoteSearchDebounce?.dispose();
    for (final c in [
      clienteController,
      commentsCtrl,
      globalDiscountCtrl,
      referenciaCtrl,
      tipoCambioCtrl,
      quoteSearchCtrl,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
