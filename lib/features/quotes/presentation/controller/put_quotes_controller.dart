import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/common/controller/product_search_controller.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/presentation/controller/inventory_controller.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
import 'package:bcg/features/client/presentation/controller/client_search_controller.dart';
import 'package:bcg/features/client/presentation/page/client_search_sheet.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_quotes_byid_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/generate_pdf_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/put_quotes_usecase.dart';
import 'package:bcg/features/quotes/presentation/controller/quotes_controller.dart';
import 'package:bcg/features/quotes/presentation/widget/pdf_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class EditQuoteItem {
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
  })  : codigo = codigo.obs,
        descripcion = descripcion.obs,
        precio = precio.obs,
        quantity = quantity.obs,
        descuento = descuento.obs;

  double get subtotal => precio.value * quantity.value;
  double get discountAmount => subtotal * (descuento.value / 100);
  double get total => subtotal - discountAmount;

  factory EditQuoteItem.fromInventory(InventoryEntity product, int index) {
    return EditQuoteItem(
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
}
class PutQuotesController extends GetxController {
  final PutQuotesUsecase putQuotesUsecase;
  final FetchQuotesByidUsecase fetchQuotesByidUsecase;
  final GeneratePdfUsecase generatePdfUsecase;

  PutQuotesController({
    required this.putQuotesUsecase,
    required this.fetchQuotesByidUsecase,
    required this.generatePdfUsecase,
  });

  late final QuotesController _quotesCtrl = Get.find<QuotesController>();
  late final ClientController _clientCtrl = Get.find<ClientController>();

  final Rxn<int> quoteId = Rxn<int>();

  final isLoadingQuote = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final pdfUrl = Rxn<String>();
  final RxBool isLoadingPdf = false.obs;

  final folio = ''.obs;
  final clienteName = ''.obs;
  final clienteController = TextEditingController();
  final selectedPriceType = 'REGULAR'.obs;
  final validUntil = DateTime.now().add(const Duration(days: 15)).obs;
  final globalDiscount = 0.0.obs;
  final globalDiscountType = 'monto'.obs;
  final globalDiscountPercent = 0.0.obs;

  final items = <EditQuoteItem>[].obs;

  final commentsCtrl = TextEditingController();
  final globalDiscountCtrl = TextEditingController();

  final List<String> priceOptions = [
    'REGULAR',
    'MEDIO M',
    'PAQUETE',
    'MAYOREO',
    'ESPECIAL',
  ];
void onClientSelected(ClientEntity client) {
  final name = client.displayName ?? '';
  clienteController.text = name;
  clienteName.value = name;
  Get.find<ClientSearchController>().searchCtrl.text = name;
}
  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get ivaAmount => (subtotal - globalDiscount.value) * 0.16;
  double get totalToPay => subtotal - globalDiscount.value + ivaAmount;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['idQuote'] != null) {
      loadQuote(args['idQuote'] as int);
    }
  }

  // ── Cargar cotización ──────────────────────────────────────────────────────

  Future<void> loadQuote(int id) async {
    try {
      quoteId.value = id;
      isLoadingQuote.value = true;
      errorMessage.value = '';

      final quote = await fetchQuotesByidUsecase.call(id);
      _populateFromEntity(quote);
    } catch (e) {
      errorMessage.value = 'Error al cargar cotización: $e';
      showErrorSnackbar('Error al cargar cotización');
    } finally {
      isLoadingQuote.value = false;
    }
  }

  void _populateFromEntity(QuoteEntity quote) {
  folio.value = quote.folio;
  clienteName.value = quote.cliente;
  clienteController.text = quote.cliente;
  selectedPriceType.value = quote.cataPrecio;
  commentsCtrl.text = quote.comentarios;

  final daysToAdd = quote.diasEnt > 0 ? quote.diasEnt : 15;
  validUntil.value = DateTime.now().add(Duration(days: daysToAdd));

  final desc = double.tryParse(quote.descuento) ?? 0;
  globalDiscount.value = desc;
  if (desc > 0) globalDiscountCtrl.text = desc.toStringAsFixed(2);

  items.assignAll(
    quote.productos.map((p) => EditQuoteItem.fromProductoEntity(p)).toList(),
  );

  // Sincroniza el campo visual del buscador de cliente
  Get.find<ClientSearchController>().searchCtrl.text = quote.cliente;
}

  // ── Cliente ────────────────────────────────────────────────────────────────

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

  // ── Productos ──────────────────────────────────────────────────────────────

  void addProduct(InventoryEntity product) {
    if ((product.price ?? 0) <= 0) {
      showErrorSnackbar('Este producto no tiene precio asignado');
      return;
    }
    final existing = items.firstWhereOrNull(
        (i) => i.codigo.value == (product.partNumber ?? ''));
    if (existing != null) {
      existing.quantity.value++;
    } else {
      items.add(EditQuoteItem.fromInventory(product, items.length + 1));
    }
    Get.find<ProductSearchController>().clearSearch();
  }

  void removeItem(EditQuoteItem item) => items.remove(item);

  // ── Descuento ──────────────────────────────────────────────────────────────

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

  // ── Fecha ──────────────────────────────────────────────────────────────────

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

  // ── Guardar ────────────────────────────────────────────────────────────────

  Future<void> generateAndOpenPdf(BuildContext context) async {
    final id = quoteId.value;
    if (id == null) return;

    try {
      isLoadingPdf.value = true;
      final result = await generatePdfUsecase.call(id);
      pdfUrl.value = result.urlpdf;

      if (result.generated && result.urlpdf.isNotEmpty) {
        isLoadingPdf.value = false;
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => PdfOptionsSheet(),
        );
      }
    } catch (e) {
      showErrorSnackbar('Error al generar PDF');
    } finally {
      isLoadingPdf.value = false;
    }
  }

  Future<void> saveQuote() async {
    final id = quoteId.value;
    if (id == null) return;

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

      final entity = QuoteEntity(
        folio: folio.value,
        cliente: clienteName.value.trim(),
        total: totalToPay,
        cataPrecio: selectedPriceType.value,
        descuento: globalDiscount.value.toStringAsFixed(2),
        iva: ivaAmount.toStringAsFixed(2),
        diasEnt: validUntil.value.difference(DateTime.now()).inDays,
        comentarios: commentsCtrl.text.trim(),
        referencia: '',
        productos: items.asMap().entries.map((entry) {
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
            descuento: i.discountAmount,
            prioridad: entry.key + 1,
          );
        }).toList(),
      );

      await putQuotesUsecase.call(id, entity);
      await _quotesCtrl.fetchQuotes();

      final result = await generatePdfUsecase.call(id);
      pdfUrl.value = result.urlpdf;

      showSuccessSnackbar('Cotización actualizada correctamente');
    } catch (e) {
      errorMessage.value = 'Error al guardar: $e';
      showErrorSnackbar('Error al guardar cotización');
    } finally {
      isSaving.value = false;
    }
  }

  // ── PDF ────────────────────────────────────────────────────────────────────

  Future<void> sendWhatsApp() async {
    final url = pdfUrl.value;
    if (url == null || url.isEmpty) return;

    try {
      isLoadingPdf.value = true;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final fileName =
            'cotizacion_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Cotización ${folio.value}',
          text: 'Te comparto la cotización ${folio.value}',
        );
      } else {
        showErrorSnackbar('No se pudo descargar el PDF');
      }
    } catch (e) {
      showErrorSnackbar('Error al compartir PDF');
    } finally {
      isLoadingPdf.value = false;
    }
  }

  Future<void> downloadPdf() async {
    final url = pdfUrl.value;
    if (url == null || url.isEmpty) return;

    try {
      isDownloading.value = true;
      downloadProgress.value = 0;

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        showErrorSnackbar('No se pudo descargar el PDF');
        return;
      }

      final fileName =
          'cotizacion_${folio.value}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String savePath;

      if (Platform.isAndroid) {
        savePath = '/storage/emulated/0/Download/$fileName';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        savePath = '${dir.path}/$fileName';
      }

      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
      showSuccessSnackbar('PDF guardado en Descargas');
    } catch (e) {
      showErrorSnackbar('Error al descargar PDF: $e');
    } finally {
      isDownloading.value = false;
    }
  }

  @override
  void onClose() {
    clienteController.dispose();
    commentsCtrl.dispose();
    globalDiscountCtrl.dispose();
    super.onClose();
  }
}