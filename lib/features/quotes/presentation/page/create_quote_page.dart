import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


// ─── Modelo simple de item de cotización ───────────────────────────────────

class QuoteItem {
  final String name;
  final double unitPrice;
  final String? imageUrl;
  final RxInt quantity;

  QuoteItem({
    required this.name,
    required this.unitPrice,
    this.imageUrl,
    int initialQty = 1,
  }) : quantity = initialQty.obs;

  double get total => unitPrice * quantity.value;
}

// ─── Controller ────────────────────────────────────────────────────────────

class CreateQuoteController extends GetxController {
  // Campos
  final selectedClient = Rxn<String>();
  final selectedPrice = 'Regular'.obs;
  final productSearch = ''.obs;

  // Items
  final items = <QuoteItem>[
    QuoteItem(name: 'Aceite de motor', unitPrice: 350, initialQty: 2),
    QuoteItem(name: 'Aceite de motor 2', unitPrice: 350, initialQty: 1),
  ].obs;

  // Descuento
  final discount = 0.0.obs;
  final double ivaRate = 0.16;

  // Fecha válida
  final validUntil = DateTime.now().add(const Duration(days: 15)).obs;

  // Comentarios
  final commentsController = TextEditingController();
  final productSearchController = TextEditingController();

  // ── Cálculos ──────────────────────────────────────────────────────────────

  double get subtotal => items.fold(0, (sum, i) => sum + i.total);
  double get ivaAmount => (subtotal - discount.value) * ivaRate;
  double get totalToPay => subtotal - discount.value + ivaAmount;

  // ── Opciones de precio ────────────────────────────────────────────────────
  final List<String> priceOptions = ['Regular', 'Mayoreo', 'Especial'];

  // ── Acciones ──────────────────────────────────────────────────────────────

  void removeItem(QuoteItem item) {
    items.remove(item);
  }

  void duplicateItem(QuoteItem item) {
    items.add(
      QuoteItem(
        name: item.name,
        unitPrice: item.unitPrice,
        imageUrl: item.imageUrl,
        initialQty: item.quantity.value,
      ),
    );
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

  void createQuote() {
    if (selectedClient.value == null) {
      Get.snackbar(
        'Atención',
        'Selecciona un cliente para continuar',
        backgroundColor: ThemeColor.warningColor,
        colorText: ThemeColor.textDarkColor,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // TODO: llamar al use case / repository
    Get.back();
  }

  void showAddDiscountDialog(BuildContext context) {
    final ctrl = TextEditingController(
      text: discount.value > 0 ? discount.value.toStringAsFixed(2) : '',
    );
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColor.surfaceColor,
        title: Text('Descuento', style: ThemeColor.headingSmall),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: ThemeColor.mediumBorderRadius,
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ThemeColor.mediumBorderRadius,
              borderSide: const BorderSide(
                color: ThemeColor.accentColor,
                width: 1.5,
              ),
            ),
          ),
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
              discount.value = double.tryParse(ctrl.text) ?? 0;
              Get.back();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    commentsController.dispose();
    productSearchController.dispose();
    super.onClose();
  }
}

// ─── Page ──────────────────────────────────────────────────────────────────

class CreateQuotePage extends GetView<CreateQuoteController> {
  const CreateQuotePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Asegurar que el controller esté disponible
    Get.put(CreateQuoteController());

    return Scaffold(
      backgroundColor: ThemeColor.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopSection(),
                  _buildDivider(),
                  _buildProductList(),
                  _buildTotalsSection(context),
                  _buildDivider(),
                  _buildValidUntilSection(context),
                  _buildDivider(),
                  _buildCommentsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.surfaceColor,
      foregroundColor: ThemeColor.textPrimaryColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: ThemeColor.textPrimaryColor,
          size: 20,
        ),
      ),
      title: Text('Crear Cotización', style: ThemeColor.headingSmall),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: ThemeColor.dividerColor),
      ),
    );
  }

  // ── Sección superior: cliente, precio, producto ───────────────────────────

  Widget _buildTopSection() {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingSmall,
      ),
      child: Column(
        children: [
          _buildRowField(
            label: 'Cliente',
            child: _buildClientSelector(),
          ),
          Divider(height: 1, color: ThemeColor.dividerColor),
          _buildRowField(
            label: 'Precio',
            child: _buildPriceSelector(),
          ),
          Divider(height: 1, color: ThemeColor.dividerColor),
          _buildRowField(
            label: 'Producto',
            child: _buildProductSearch(),
          ),
        ],
      ),
    );
  }

  Widget _buildRowField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: ThemeColor.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: ThemeColor.textPrimaryColor,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildClientSelector() {
    return Obx(() => GestureDetector(
          onTap: () {
            // TODO: abrir selector de cliente
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: ThemeColor.backgroundColor,
              borderRadius: ThemeColor.extraLargeBorderRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.selectedClient.value ?? 'Selecciona un cliente',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: controller.selectedClient.value != null
                        ? ThemeColor.textPrimaryColor
                        : ThemeColor.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildPriceSelector() {
    return Obx(() => GestureDetector(
          onTap: () {
            Get.bottomSheet(
              Container(
                padding: const EdgeInsets.all(ThemeColor.paddingMedium),
                decoration: const BoxDecoration(
                  color: ThemeColor.surfaceColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(ThemeColor.largeRadius),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: ThemeColor.paddingMedium),
                      child: Text('Tipo de precio',
                          style: ThemeColor.headingSmall),
                    ),
                    ...controller.priceOptions.map(
                      (opt) => ListTile(
                        title: Text(opt, style: ThemeColor.bodyLarge),
                        trailing: controller.selectedPrice.value == opt
                            ? const Icon(Icons.check,
                                color: ThemeColor.accentColor)
                            : null,
                        onTap: () {
                          controller.selectedPrice.value = opt;
                          Get.back();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: ThemeColor.backgroundColor,
              borderRadius: ThemeColor.extraLargeBorderRadius,
            ),
            child: Text(
              controller.selectedPrice.value,
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textSecondaryColor,
              ),
            ),
          ),
        ));
  }

  Widget _buildProductSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: ThemeColor.extraLargeBorderRadius,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: ThemeColor.textSecondaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.productSearchController,
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Buscar producto',
                hintStyle: ThemeColor.bodyMedium
                    .copyWith(color: ThemeColor.textSecondaryColor),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (v) => controller.productSearch.value = v,
            ),
          ),
        ],
      ),
    );
  }

  // ── Lista de productos ────────────────────────────────────────────────────

  Widget _buildProductList() {
    return Obx(() => Container(
          color: ThemeColor.surfaceColor,
          child: Column(
            children: controller.items.map((item) {
              return Column(
                children: [
                  _buildProductItem(item),
                  if (controller.items.last != item)
                    Divider(
                      height: 1,
                      color: ThemeColor.dividerColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
        ));
  }

  Widget _buildProductItem(QuoteItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: ThemeColor.backgroundColor,
              borderRadius: ThemeColor.smallBorderRadius,
              border: Border.all(color: ThemeColor.dividerColor),
            ),
            child: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: ThemeColor.smallBorderRadius,
                    child: Image.network(item.imageUrl!, fit: BoxFit.cover),
                  )
                : Icon(
                    Icons.image_outlined,
                    color: ThemeColor.textTertiaryColor,
                    size: 26,
                  ),
          ),
          const SizedBox(width: 12),
          // Info + cantidad
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: ThemeColor.subtitleMedium),
                const SizedBox(height: 2),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)}',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Quantity input
                SizedBox(
                  width: 60,
                  height: 32,
                  child: Obx(() => TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: ThemeColor.bodyMedium,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          filled: true,
                          fillColor: ThemeColor.backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: ThemeColor.smallBorderRadius,
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: ThemeColor.smallBorderRadius,
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: ThemeColor.smallBorderRadius,
                            borderSide: const BorderSide(
                              color: ThemeColor.accentColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        controller: TextEditingController(
                          text: item.quantity.value.toString(),
                        )..selection = TextSelection.collapsed(
                            offset:
                                item.quantity.value.toString().length),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null && parsed > 0) {
                            item.quantity.value = parsed;
                          }
                        },
                      )),
                ),
              ],
            ),
          ),
          // Total + opciones
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Botón de opciones (···)
              GestureDetector(
                onTap: () => _showItemOptions(item),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz,
                    color: ThemeColor.textSecondaryColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                    '\$${item.total.toStringAsFixed(2)}',
                    style: ThemeColor.subtitleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void _showItemOptions(QuoteItem item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(ThemeColor.paddingMedium),
        decoration: const BoxDecoration(
          color: ThemeColor.surfaceColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ThemeColor.largeRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_outlined,
                  color: ThemeColor.primaryColor),
              title: Text('Duplicar', style: ThemeColor.bodyLarge),
              onTap: () {
                controller.duplicateItem(item);
                Get.back();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: ThemeColor.errorColor),
              title: Text(
                'Eliminar',
                style: ThemeColor.bodyLarge
                    .copyWith(color: ThemeColor.errorColor),
              ),
              onTap: () {
                controller.removeItem(item);
                Get.back();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Totales ───────────────────────────────────────────────────────────────

  Widget _buildTotalsSection(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Obx(() => Column(
            children: [
              _buildTotalRow(
                label: 'Subtotal',
                value: '\$${controller.subtotal.toStringAsFixed(2)}',
                bold: false,
              ),
              const SizedBox(height: 6),
              // Descuento (tappable)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () =>
                        controller.showAddDiscountDialog(context),
                    child: Text(
                      controller.discount.value > 0
                          ? 'Descuento aplicado'
                          : 'Agregar un Descuento',
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    controller.discount.value > 0
                        ? '-\$${controller.discount.value.toStringAsFixed(2)}'
                        : '\$0.00',
                    style: ThemeColor.bodyMedium.copyWith(
                      color: ThemeColor.errorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildTotalRow(
                label: 'I.V.A',
                value: '\$${controller.ivaAmount.toStringAsFixed(2)}',
                bold: false,
              ),
              Divider(
                height: 20,
                color: ThemeColor.dividerColor,
              ),
              _buildTotalRow(
                label: 'Total a pagar',
                value: '\$${controller.totalToPay.toStringAsFixed(2)}',
                bold: true,
              ),
            ],
          )),
    );
  }

  Widget _buildTotalRow({
    required String label,
    required String value,
    required bool bold,
  }) {
    final style = bold
        ? ThemeColor.subtitleLarge.copyWith(fontWeight: FontWeight.w700)
        : ThemeColor.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }

  // ── Válida hasta ──────────────────────────────────────────────────────────

  Widget _buildValidUntilSection(BuildContext context) {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Row(
        children: [
          Text(
            'Válida hasta',
            style: ThemeColor.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeColor.textPrimaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => GestureDetector(
                  onTap: () => controller.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColor.backgroundColor,
                      borderRadius: ThemeColor.smallBorderRadius,
                      border: Border.all(color: ThemeColor.dividerColor),
                    ),
                    child: Text(
                      _formatDate(controller.validUntil.value),
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ── Comentarios ───────────────────────────────────────────────────────────

  Widget _buildCommentsSection() {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comentarios',
            style: ThemeColor.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeColor.textPrimaryColor,
            ),
          ),
          const SizedBox(height: ThemeColor.paddingSmall),
          TextField(
            controller: controller.commentsController,
            maxLines: 4,
            style: ThemeColor.bodyMedium,
            decoration: InputDecoration(
              filled: true,
              fillColor: ThemeColor.surfaceColor,
              contentPadding: const EdgeInsets.all(ThemeColor.paddingMedium),
              border: OutlineInputBorder(
                borderRadius: ThemeColor.smallBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ThemeColor.smallBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade300),
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
    );
  }

  // ── Divider helper ────────────────────────────────────────────────────────

  Widget _buildDivider() =>
      Container(height: 8, color: ThemeColor.backgroundColor);

  // ── Botón inferior ────────────────────────────────────────────────────────

  Widget _buildBottomButton() {
    return Container(
      color: ThemeColor.surfaceColor,
      padding: const EdgeInsets.fromLTRB(
        ThemeColor.paddingMedium,
        ThemeColor.paddingSmall,
        ThemeColor.paddingMedium,
        ThemeColor.paddingLarge,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ThemeColor.widgetButton(
          text: 'Crear Cotización',
          backgroundColor: ThemeColor.primaryColor,
          textColor: ThemeColor.textLightColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: ThemeColor.mediumRadius,
          onPressed: controller.createQuote,
        ),
      ),
    );
  }
}