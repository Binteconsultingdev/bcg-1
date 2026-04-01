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

  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void onReady() {
    super.onReady();
    fetchSales();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
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

      final result = await pointSalesUsecase.call(
        _toIso(dateFrom),
        _toIso(dateUntil, endOfDay: true),
        ignoreDates,
        client,
        statusPayment,
        userToFilter,
        _currentPage,_pageSize
      );

      sales.assignAll(result);
      if (result.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al cargar ventas: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreSales() async {
    if (isLoadingMore.value || !hasMorePages.value || isLoading.value) return;
    try {
      isLoadingMore.value = true;
      _currentPage++;

      final result = await pointSalesUsecase.call(
        _toIso(dateFromFilter.value),
        _toIso(dateUntilFilter.value, endOfDay: true),
        ignoreDatesFilter.value,
        clientFilter.value,
        statusPaymentFilter.value,
        userFilter.value,
        _currentPage,_pageSize
      );

      if (result.isEmpty || result.length < _pageSize) {
        hasMorePages.value = false;
      }
      sales.addAll(result);
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

  void clearFilters() => fetchSales(ignoreDates: true);

  List<PointSaleEntity> filteredByTab(int tab, String search) {
    return sales.where((s) {
      final matchTab = tab == 0 ||
          (tab == 1 && s.status?.toLowerCase() == 'pendiente');
      final matchSearch = search.isEmpty ||
          (s.client?.toLowerCase().contains(search.toLowerCase()) ?? false) ||
          (s.folito?.toLowerCase().contains(search.toLowerCase()) ?? false);
      return matchTab && matchSearch;
    }).toList();
  }
}