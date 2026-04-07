import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/presentation/controller/inventory_controller.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
import 'package:bcg/features/client/presentation/page/client_search_sheet.dart';
import 'package:bcg/features/sales/domain/entities/create_sales_entity.dart';
import 'package:bcg/features/sales/domain/usecase/generate_sales_usecase.dart';
import 'package:bcg/features/sales/presentation/controller/sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SaleItem {
  final InventoryEntity product;
  final RxInt quantity;
  final RxDouble discount;

  SaleItem({required this.product, int initialQty = 1})
      : quantity = initialQty.obs,
        discount = 0.0.obs;

  double get unitPrice => (product.price ?? 0).toDouble();
  double get subtotal => unitPrice * quantity.value;
  double get discountAmount => subtotal * (discount.value / 100);
  double get total => subtotal - discountAmount;
}

class CreateSalesController extends GetxController {
  final GenerateSalesUsecase generateSalesUsecase;
  CreateSalesController({required this.generateSalesUsecase});

  final AuthService _authService = AuthService();

  late final InventoryController _inventoryCtrl = Get.find<InventoryController>();
  late final SalesController _salesCtrl = Get.find<SalesController>();
  late final ClientController _clientCtrl = Get.find<ClientController>();

  // Cliente
  final clienteName = ''.obs;
  final clienteController = TextEditingController();
  final selectedClientId = Rxn<int>();

  // Campos de venta
  final metodoEmbarque = 'CAMIONETA'.obs;
  final incIVA = true.obs;
  final tipoCambio = 1.0.obs;
  final globalDiscount = 0.0.obs;
  final globalDiscountType = 'monto'.obs; // 'monto' o 'porcentaje'
  final globalDiscountPercent = 0.0.obs;
  final validUntil = DateTime.now().add(const Duration(days: 15)).obs;

  // Productos
  final items = <SaleItem>[].obs;
  final productSearchQuery = ''.obs;
  final isSearching = false.obs;

  // Estado
  final isCreating = false.obs;
  final isSuccess = false.obs;
  final errorMessage = ''.obs;

  // Controllers
  final commentsCtrl = TextEditingController();
  final productSearchCtrl = TextEditingController();
  final globalDiscountCtrl = TextEditingController();
  final referenciaCtrl = TextEditingController();
  final tipoCambioCtrl = TextEditingController(text: '1.00');

  final List<String> metodosEmbarque = [
    'CAMIONETA',
    'CLIENTE RECOGE',
    'PAQUETERIA',
  ];

  double get subtotal => items.fold(0, (s, i) => s + i.total);
  double get ivaAmount =>
      incIVA.value ? (subtotal - globalDiscount.value) * 0.16 : 0;
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
          selectedClientId.value = client.id;
        },
      ),
    );
  }

  void onProductSearchChanged(String value) {
    productSearchQuery.value = value;
    isSearching.value = value.isNotEmpty;
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
      items.add(SaleItem(product: product));
    }
    productSearchCtrl.clear();
    productSearchQuery.value = '';
    isSearching.value = false;
  }

  void removeItem(SaleItem item) => items.remove(item);

  void duplicateItem(SaleItem item) {
    items.add(SaleItem(product: item.product, initialQty: item.quantity.value));
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
      errorMessage.value = '';

      final userData = await _authService.getUserData();
      final vendedorName = userData?.nombre ?? '';

      final entity = CreateSalesEntity(
        numCliente: selectedClientId.value ?? 0,
        cliente: clienteName.value.trim(),
        vendedor: vendedorName,
        user: vendedorName,
        metodoEmb: metodoEmbarque.value,
        comentarios: commentsCtrl.text.trim(),
        refe: referenciaCtrl.text.trim(),
        fechaEntrega: validUntil.value,
        tc: double.tryParse(tipoCambioCtrl.text) ?? 1.0,
        incIVA: incIVA.value,
        folioPre: '',
        descuento: globalDiscount.value,
        partidas: items
            .map(
              (i) => PartidaEntity(
                numParte: i.product.partNumber ?? '',
                descripcion: i.product.description ?? '',
                cantidad: i.quantity.value.toDouble(),
                precio: i.unitPrice,
                claveSat: '',
                um: 'PZA',
              ),
            )
            .toList(),
      );

      await generateSalesUsecase.call(entity);
      isSuccess.value = true;
      await _salesCtrl.fetchSales();
      showSuccessSnackbar('Venta creada correctamente');
    } catch (e) {
      errorMessage.value = 'Error al crear venta: $e';
      showErrorSnackbar('Error al crear venta');
    } finally {
      isCreating.value = false;
    }
  }

  @override
  void onClose() {
    clienteController.dispose();
    commentsCtrl.dispose();
    productSearchCtrl.dispose();
    globalDiscountCtrl.dispose();
    referenciaCtrl.dispose();
    tipoCambioCtrl.dispose();
    super.onClose();
  }
}