import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';
import 'package:bcg/features/sales/domain/usecase/point_sales_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesController extends GetxController {
  final PointSalesUsecase pointSalesUsecase;
  SalesController({required this.pointSalesUsecase});

  final ScrollController scrollController = ScrollController();

  final RxList<PointSaleEntity> sales = <PointSaleEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMorePages = true.obs;
  final RxString errorMessage = ''.obs;

  final RxString dateFromFilter = ''.obs;
  final RxString dateUntilFilter = ''.obs;
  final RxString clientFilter = ''.obs;
  final RxString statusPaymentFilter = ''.obs;
  final RxString userFilter = ''.obs;
  final RxBool ignoreDatesFilter = true.obs;

  final RxString searchInput = ''.obs;
  final TextEditingController searchController = TextEditingController();

  int _currentPage = 1;
  static const int _pageSize = 20;

  String get _trimmed => searchInput.value.trim();
  bool get _isEmpty => _trimmed.isEmpty;
  bool get _isNumeric => int.tryParse(_trimmed) != null;

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
        final key = item.id?.toString() ?? item.folito ?? '';
        if (seen.add(key)) merged.add(item);
      }
    }
    return merged;
  }

  Future<List<List<PointSaleEntity>>> _buildSearchCalls(int page) {
    final calls = <Future<List<PointSaleEntity>>>[];
    final dateFrom = _toIso(dateFromFilter.value);
    final dateUntil = _toIso(dateUntilFilter.value, endOfDay: true);
    final ignoreDates = ignoreDatesFilter.value;
    final client = clientFilter.value;
    final status = statusPaymentFilter.value;
    final user = userFilter.value;

    if (_isEmpty) {
      calls.add(pointSalesUsecase.call(
        dateFrom, dateUntil, ignoreDates,
        client, status, user,
        page, _pageSize,
      ));
    } else if (_isNumeric) {
      calls.add(pointSalesUsecase.call(
        dateFrom, dateUntil, ignoreDates,
        client, status, user,
        page, _pageSize,
        id: _trimmed,
      ));
    } else {
      // Por folio
      calls.add(pointSalesUsecase.call(
        dateFrom, dateUntil, ignoreDates,
        client, status, user,
        page, _pageSize,
        folio: _trimmed,
      ));
      // Por cliente
      calls.add(pointSalesUsecase.call(
        dateFrom, dateUntil, ignoreDates,
        _trimmed, status, user,
        page, _pageSize,
      ));
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
      if (combined.isEmpty || combined.length < _pageSize) {
        hasMorePages.value = false;
      }
      sales.addAll(combined);
    } catch (e) {
      _currentPage--;
      errorMessage.value = 'Error al cargar más ventas: $e';
    } finally {
      isLoadingMore.value = false;
    }
  }

  void applyFilters({
    required String dateFrom,
    required String dateUntil,
    required String client,
    required String statusPayment,
    String userToFilter = '',
  }) {
    fetchSales(
      dateFrom: dateFrom,
      dateUntil: dateUntil,
      ignoreDates: dateFrom.isEmpty && dateUntil.isEmpty,
      client: client,
      statusPayment: statusPayment,
      userToFilter: userToFilter,
    );
  }

  void clearFilters() {
    searchController.clear();
    searchInput.value = '';
    fetchSales(ignoreDates: true);
  }

  List<PointSaleEntity> filteredByTab(int tab) {
    return sales.where((s) {
      return tab == 0 ||
          (tab == 1 && s.status?.toLowerCase() == 'pendiente');
    }).toList();
  }
}