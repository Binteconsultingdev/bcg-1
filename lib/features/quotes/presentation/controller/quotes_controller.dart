import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_quote_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuotesController extends GetxController {
  final FetchQuoteUsecase fetchQuoteUsecase;
  QuotesController({required this.fetchQuoteUsecase});

  final ScrollController scrollController = ScrollController();

  final RxList<GetQuoteEntity> quotes = <GetQuoteEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMorePages = true.obs;
  final RxString errorMessage = ''.obs;

  final RxString clientFilter = ''.obs;
  final RxString numParteFilter = ''.obs;
  final RxString dateFromFilter = ''.obs;
  final RxString dateUntilFilter = ''.obs;

  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void onReady() {
    super.onReady();
    fetchQuotes();
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
      loadMoreQuotes();
    }
  }

  Future<void> fetchQuotes({
    String client = '',
    String numParte = '',
    String dateFrom = '',
    String dateUntil = '',
  }) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      isLoadingMore.value = false;
      errorMessage.value = '';
      _currentPage = 1;
      hasMorePages.value = true;

      clientFilter.value = client;
      numParteFilter.value = numParte;
      dateFromFilter.value = dateFrom;
      dateUntilFilter.value = dateUntil;

      final result = await fetchQuoteUsecase.cal(
        client,
        numParte,
        dateFrom,
        dateUntil,
        _currentPage,_pageSize
      );

      quotes.assignAll(result);
      if (result.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al cargar cotizaciones: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreQuotes() async {
    if (isLoadingMore.value || !hasMorePages.value || isLoading.value) return;
    try {
      isLoadingMore.value = true;
      _currentPage++;

      final result = await fetchQuoteUsecase.cal(
        clientFilter.value,
        numParteFilter.value,
        dateFromFilter.value,
        dateUntilFilter.value,
        _currentPage,
        _pageSize
      );

      if (result.isEmpty || result.length < _pageSize) {
        hasMorePages.value = false;
      }
      quotes.addAll(result);
    } catch (e) {
      _currentPage--;
      errorMessage.value = 'Error al cargar más cotizaciones: $e';
    } finally {
      isLoadingMore.value = false;
    }
  }

  String _toIso(String ddMMyyyy, {bool endOfDay = false}) {
    if (ddMMyyyy.isEmpty) return '';
    final parts = ddMMyyyy.split('/');
    if (parts.length != 3) return '';
    final time = endOfDay ? '23:59:59' : '00:00:00';
    return '${parts[2]}-${parts[1]}-${parts[0]}T$time';
  }

  void applyFilters({
    required String client,
    required String dateFrom,
    required String dateUntil,
  }) {
    fetchQuotes(
      client: client,
      numParte: numParteFilter.value,
      dateFrom: _toIso(dateFrom),
      dateUntil: _toIso(dateUntil, endOfDay: true),
    );
  }

  void clearFilters() => fetchQuotes();

  List<GetQuoteEntity> filteredByTab(int tab, String search) {
    return quotes.where((q) {
      final matchTab = tab == 0 ||
          (tab == 1 && q.status?.toLowerCase() == 'vencida') ||
          (tab == 2 && q.status?.toLowerCase() == 'vendida');
      final matchSearch = search.isEmpty ||
          (q.client?.toLowerCase().contains(search.toLowerCase()) ?? false) ||
          (q.folito?.toLowerCase().contains(search.toLowerCase()) ?? false);
      return matchTab && matchSearch;
    }).toList();
  }
}