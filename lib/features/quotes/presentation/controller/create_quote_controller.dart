import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/presentation/controller/inventory_controller.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
import 'package:bcg/features/client/presentation/page/client_search_sheet.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/usecase/create_quotes_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_folio_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/generate_pdf_usecase.dart';
import 'package:bcg/features/quotes/presentation/controller/quotes_controller.dart';
import 'package:bcg/features/quotes/presentation/widget/pdf_options_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class QuoteItem {
  final InventoryEntity product;
  final RxInt quantity;
  final RxDouble discount; 

  QuoteItem({required this.product, int initialQty = 1})
    : quantity = initialQty.obs,
      discount = 0.0.obs;

  double get unitPrice => (product.price ?? 0).toDouble();
  double get subtotal => unitPrice * quantity.value;
  double get discountAmount => subtotal * (discount.value / 100);
  double get total => subtotal - discountAmount;
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
  late final InventoryController _inventoryCtrl = Get.find<InventoryController>(); 
  late final QuotesController _quotesCtrl = Get.find<QuotesController>();
  late final ClientController _clientCtrl = Get.find<ClientController>();
final RxBool isDownloading = false.obs;
final RxDouble downloadProgress = 0.0.obs;
  final folio = ''.obs;
  final selectedClientId = Rxn<String>();
  final selectedClientName = Rxn<String>();
  final createdQuoteId = Rxn<int>();
  final pdfUrl = Rxn<String>();
  final isLoadingPdf = false.obs;
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

  final productSearchQuery = ''.obs;
  final isSearching = false.obs;

  final commentsCtrl = TextEditingController();
  final productSearchCtrl = TextEditingController();
  final globalDiscountCtrl = TextEditingController();
  void onClienteChanged(String value) => clienteName.value = value;

  final List<String> priceOptions = ['Regular', 'Mayoreo', 'Especial'];

  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get ivaAmount => (subtotal - globalDiscount.value) * 0.16;
  double get totalToPay => subtotal - globalDiscount.value + ivaAmount;

  List<InventoryEntity> get searchResults {
    final q = productSearchQuery.value.toLowerCase();
    if (q.isEmpty) return [];
    return _inventoryCtrl.inventario
        .where(
          (p) =>
              (p.description?.toLowerCase().contains(q) ?? false) ||
              (p.partNumber?.toLowerCase().contains(q) ?? false),
        )
        .take(20)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadFolio();
  }
Future<void> sendWhatsApp() async {
  final url = pdfUrl.value;
  if (url == null || url.isEmpty) return;

  try {
    isLoadingPdf.value = true;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final fileName = 'cotizacion_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

    // Pide permiso en Android
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        showErrorSnackbar('Se necesita permiso para guardar archivos');
        return;
      }
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      showErrorSnackbar('No se pudo descargar el PDF');
      return;
    }

    final fileName = 'cotizacion_${folio.value}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    String savePath;

    if (Platform.isAndroid) {
      // Carpeta Downloads visible en Android
      savePath = '/storage/emulated/0/Download/$fileName';
    } else {
      // iOS: documentos de la app
      final dir = await getApplicationDocumentsDirectory();
      savePath = '${dir.path}/$fileName';
    }

    final file = File(savePath);
    await file.writeAsBytes(response.bodyBytes);

    showSuccessSnackbar('PDF guardado en Descargas: $fileName');
  } catch (e) {
    showErrorSnackbar('Error al descargar PDF: $e');
  } finally {
    isDownloading.value = false;
  }
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
  }

void addProduct(InventoryEntity product) {
  // Bloquea precio 0
  if ((product.price ?? 0) <= 0) {
    showErrorSnackbar('Este producto no tiene precio asignado');
    return;
  }

  // Si ya existe solo suma cantidad
  final existing = items.firstWhereOrNull((i) => i.product.id == product.id);
  if (existing != null) {
    existing.quantity.value++;
  } else {
    items.add(QuoteItem(product: product));
  }

  productSearchCtrl.clear();
  productSearchQuery.value = '';
  isSearching.value = false;
}
Future<void> generateAndOpenPdf(BuildContext context) async {
  final id = createdQuoteId.value;
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
  void removeItem(QuoteItem item) => items.remove(item);

  void duplicateItem(QuoteItem item) {
    items.add(
      QuoteItem(product: item.product, initialQty: item.quantity.value),
    );
  }

  void selectClient(String id, String name) {
    selectedClientId.value = id;
    selectedClientName.value = name;
  }

  void applyGlobalDiscount(double value) {
    globalDiscount.value = value;
    globalDiscountCtrl.text = value > 0 ? value.toStringAsFixed(2) : '';
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

  @override
  void onClose() {
    commentsCtrl.dispose();
    productSearchCtrl.dispose();
    globalDiscountCtrl.dispose();
    super.onClose();
  }
}
