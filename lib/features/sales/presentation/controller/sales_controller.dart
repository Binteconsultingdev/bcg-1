import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_search_controller.dart';
import 'package:bcg/features/quotes/presentation/widget/create_pdf_controller.dart';
import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';
import 'package:bcg/features/sales/domain/usecase/generate_pdf_sales.dart';
import 'package:bcg/features/sales/domain/usecase/point_sales_usecase.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesController extends GetxController {
  final PointSalesUsecase pointSalesUsecase;
  final GeneratePdfSales generatePdfSales;
  SalesController({required this.pointSalesUsecase, required this.generatePdfSales});

  final ScrollController scrollController = ScrollController();

  // — Lista —
  final RxList<PointSaleEntity> sales = <PointSaleEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMorePages = true.obs;
  final RxString errorMessage = ''.obs;

  // — Filtros activos —
  final RxString dateFromFilter = ''.obs;
  final RxString dateUntilFilter = ''.obs;
  final RxString clientFilter = ''.obs;
  final RxString statusPaymentFilter = ''.obs;
  final RxString statusPaymentTabFilter = ''.obs;
  final RxString userFilter = ''.obs;
  final RxBool ignoreDatesFilter = true.obs;
  final RxInt selectedTab = 0.obs;

  // — Búsqueda —
  final RxString searchInput = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // — Filtros del sheet —
  final RxString filterDateFrom = ''.obs;
  final RxString filterDateUntil = ''.obs;
  final RxString filterClienteName = ''.obs;
  final RxnInt filterPagoIndex = RxnInt();

  int _currentPage = 1;
  static const int _pageSize = 20;

  String get _trimmed => searchInput.value.trim();
  bool get _isEmpty => _trimmed.isEmpty;
  bool get _isNumeric => int.tryParse(_trimmed) != null;

  // — Getters del sheet —
  String get filterStatusPayment {
    if (filterPagoIndex.value == 0) return 'pagado';
    if (filterPagoIndex.value == 1) return 'por cobrar';
    return '';
  }

  int get activeFilters => [
    if (filterDateFrom.value.isNotEmpty) true,
    if (filterDateUntil.value.isNotEmpty) true,
    if (filterClienteName.value.isNotEmpty) true,
    if (filterPagoIndex.value != null) true,
  ].length;

  // — PDF —
  Future<void> openSalePdf(BuildContext context, int saleId, String folio) async {
    final pdfCtrl = Get.find<PdfController>();
    
    try {
      pdfCtrl.reset(); 
      pdfCtrl.isLoadingPdf.value = true;
      final result = await generatePdfSales.call(saleId);
      if (result.generated && result.urlpdf.isNotEmpty) {
        pdfCtrl.folio = 'venta_$folio';
        pdfCtrl.setPdfUrl(result.urlpdf);
        pdfCtrl.isLoadingPdf.value = false;
        pdfCtrl.showOptionsSheet(context);
      }
    } catch (e) {
      showErrorSnackbar('Error al generar PDF');
    } finally {
      pdfCtrl.isLoadingPdf.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    fetchSales();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      loadMoreSales();
    }
  }

  String _toIso(String ddMMyyyy, {bool endOfDay = false}) {
    if (ddMMyyyy.isEmpty) return '';
    final parts = ddMMyyyy.split('/');
    if (parts.length != 3) return '';
    final time = endOfDay ? '23:59:59' : '00:00:00';
    return '${parts[2]}-${parts[1]}-${parts[0]}T$time';
  }

  List<PointSaleEntity> _mergeResults(List<List<PointSaleEntity>> lists) {
    final seen = <String>{};
    final merged = <PointSaleEntity>[];
    for (final list in lists) {
      for (final item in list) {
        final key = item.id.toString();
        if (seen.add(key)) merged.add(item);
      }
    }
    return merged;
  }

  String get _resolvedStatusPayment {
    if (statusPaymentTabFilter.value.isNotEmpty) return statusPaymentTabFilter.value;
    return statusPaymentFilter.value;
  }

  String _tabToStatusPayment(int tab) {
    switch (tab) {
      case 1: return 'por cobrar';
      case 2: return 'pagado';
      default: return '';
    }
  }

  void onTabChanged(int tab) {
    selectedTab.value = tab;
    statusPaymentTabFilter.value = _tabToStatusPayment(tab);
    fetchSales(
      dateFrom: dateFromFilter.value,
      dateUntil: dateUntilFilter.value,
      ignoreDates: ignoreDatesFilter.value,
      client: clientFilter.value,
      statusPayment: _resolvedStatusPayment,
      userToFilter: userFilter.value,
    );
  }

  Future<List<List<PointSaleEntity>>> _buildSearchCalls(int page) {
    final calls = <Future<List<PointSaleEntity>>>[];
    final dateFrom = ignoreDatesFilter.value ? '' : _toIso(dateFromFilter.value);
    final dateUntil = ignoreDatesFilter.value ? '' : _toIso(dateUntilFilter.value, endOfDay: true);
    final ignoreDates = ignoreDatesFilter.value;
    final client = clientFilter.value;
    final status = _resolvedStatusPayment;
    final user = userFilter.value;

    if (_isEmpty) {
      calls.add(pointSalesUsecase.call('', dateFrom, dateUntil, ignoreDates, client, status, user, page, _pageSize));
    } else if (_isNumeric) {
      calls.add(pointSalesUsecase.call('', dateFrom, dateUntil, ignoreDates, client, status, user, page, _pageSize, id: _trimmed));
    } else {
      calls.add(pointSalesUsecase.call('', dateFrom, dateUntil, ignoreDates, client, status, user, page, _pageSize, folio: _trimmed));
      calls.add(pointSalesUsecase.call('', dateFrom, dateUntil, ignoreDates, _trimmed, status, user, page, _pageSize));
    }

    return Future.wait(calls);
  }

  Future<void> fetchSales({
    String dateFrom = '',
    String dateUntil = '',
    bool ignoreDates = true,
    String client = '',
    String statusPayment = '',
    String userToFilter = '',
  }) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      isLoadingMore.value = false;
      errorMessage.value = '';
      _currentPage = 1;
      hasMorePages.value = true;

      dateFromFilter.value = dateFrom;
      dateUntilFilter.value = dateUntil;
      ignoreDatesFilter.value = ignoreDates;
      clientFilter.value = client;
      statusPaymentFilter.value = statusPayment;
      userFilter.value = userToFilter;

      final results = await _buildSearchCalls(_currentPage);
      final combined = _mergeResults(results);
      sales.assignAll(combined);
      if (combined.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al cargar ventas: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchSales() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _currentPage = 1;
      hasMorePages.value = true;

      final results = await _buildSearchCalls(_currentPage);
      final combined = _mergeResults(results);
      sales.assignAll(combined);
      if (combined.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al buscar: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreSales() async {
    if (isLoadingMore.value || !hasMorePages.value || isLoading.value) return;
    try {
      isLoadingMore.value = true;
      _currentPage++;

      final results = await _buildSearchCalls(_currentPage);
      final combined = _mergeResults(results);
      if (combined.isEmpty || combined.length < _pageSize) hasMorePages.value = false;
      sales.addAll(combined);
    } catch (e) {
      _currentPage--;
      errorMessage.value = 'Error al cargar más ventas: $e';
    } finally {
      isLoadingMore.value = false;
    }
  }

  // — Sheet de filtros —
  void initFilterSheet() {
    filterDateFrom.value = dateFromFilter.value;
    filterDateUntil.value = dateUntilFilter.value;
    filterClienteName.value = clientFilter.value;

    final sp = statusPaymentFilter.value.toLowerCase();
    if (sp == 'pagado') filterPagoIndex.value = 0;
    else if (sp == 'por cobrar') filterPagoIndex.value = 1;
    else filterPagoIndex.value = null;

    if (filterClienteName.value.isNotEmpty) {
      Get.find<ClientSearchController>().searchCtrl.text = filterClienteName.value;
    }
  }

  void onFilterClientSelected(ClientEntity client) {
    final fullName = client.displayName ?? '';
    final cleanName = fullName.replaceFirst(RegExp(r'^\(\d+\)\s*'), '').trim();
    filterClienteName.value = cleanName;
    Get.find<ClientSearchController>().searchCtrl.text = fullName;
  }

  Future<void> pickFilterDate(BuildContext context, RxString target) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: ThemeColor.primaryColor,
            onPrimary: Colors.white,
            onSurface: ThemeColor.textPrimaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      target.value =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  void onFilterClear() {
    filterDateFrom.value = '';
    filterDateUntil.value = '';
    filterClienteName.value = '';
    filterPagoIndex.value = null;
    Get.find<ClientSearchController>().clearSearch();
    clearFilters();
  }

  void applyFilterSheet() {
    applyFilters(
      dateFrom: filterDateFrom.value,
      dateUntil: filterDateUntil.value,
      client: filterClienteName.value,
      statusPayment: filterStatusPayment,
    );
  }

  void applyFilters({
    required String dateFrom,
    required String dateUntil,
    required String client,
    required String statusPayment,
    String userToFilter = '',
  }) {
    statusPaymentTabFilter.value = '';
    selectedTab.value = 0;
    fetchSales(
      dateFrom: dateFrom,
      dateUntil: dateUntil,
      ignoreDates: dateFrom.isEmpty && dateUntil.isEmpty,
      client: client,
      statusPayment: statusPayment,
      userToFilter: userToFilter,
    );
  }

  void onClientSelected(ClientEntity client) {
    final fullName = client.displayName ?? '';
    final name = fullName.replaceFirst(RegExp(r'^\(\d+\)\s*'), '').trim();
    clientFilter.value = name;
    Get.find<ClientSearchController>().searchCtrl.text = fullName;
  }

  void clearFilters() {
    searchController.clear();
    searchInput.value = '';
    statusPaymentTabFilter.value = '';
    statusPaymentFilter.value = '';
    selectedTab.value = 0;
    fetchSales(ignoreDates: true);
  }
}