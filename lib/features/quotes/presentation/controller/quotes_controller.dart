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

  final RxString numParteFilter = ''.obs;
  final RxString dateFromFilter = ''.obs;
  final RxString dateUntilFilter = ''.obs;
final RxInt selectedTab = 0.obs;

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
    fetchQuotes();
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
      loadMoreQuotes();
    }
  }

  String _toIso(String ddMMyyyy, {bool endOfDay = false}) {
    if (ddMMyyyy.isEmpty) return '';
    final parts = ddMMyyyy.split('/');
    if (parts.length != 3) return '';
    final time = endOfDay ? '23:59:59' : '00:00:00';
    return '${parts[2]}-${parts[1]}-${parts[0]}T$time';
  }

  List<GetQuoteEntity> _mergeResults(List<List<GetQuoteEntity>> lists) {
    final seen = <String>{};
    final merged = <GetQuoteEntity>[];
    for (final list in lists) {
      for (final item in list) {
        final key = item.id?.toString() ?? item.folito ?? '';
        if (seen.add(key)) merged.add(item);
      }
    }
    return merged;
  }

  Future<List<List<GetQuoteEntity>>> _buildSearchCalls(int page) {
    final calls = <Future<List<GetQuoteEntity>>>[];

    if (_isEmpty) {
      
      calls.add(fetchQuoteUsecase.cal(
        '', numParteFilter.value,
        dateFromFilter.value, dateUntilFilter.value,
        page, _pageSize,
      ));
    } else if (_isNumeric) {
      

      calls.add(fetchQuoteUsecase.cal(
        '', numParteFilter.value,
        dateFromFilter.value, dateUntilFilter.value,
        page, _pageSize,
        id: _trimmed,
      ));
    } else {
      
      calls.add(fetchQuoteUsecase.cal(
        '', numParteFilter.value,
        dateFromFilter.value, dateUntilFilter.value,
        page, _pageSize,
        folio: _trimmed,
      ));
      calls.add(fetchQuoteUsecase.cal(
        _trimmed, numParteFilter.value,
        dateFromFilter.value, dateUntilFilter.value,
        page, _pageSize,
      ));
      /*calls.add(fetchQuoteUsecase.cal(
        '', _trimmed,
        dateFromFilter.value, dateUntilFilter.value,
        page, _pageSize,
      ));*/
    }

    return Future.wait(calls);
  }

  Future<void> fetchQuotes({
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

      numParteFilter.value = numParte;
      dateFromFilter.value = dateFrom;
      dateUntilFilter.value = dateUntil;

      final results = await _buildSearchCalls(_currentPage);
      final combined = _mergeResults(results);
      quotes.assignAll(combined);
      if (combined.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al cargar cotizaciones: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchQuotes() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _currentPage = 1;
      hasMorePages.value = true;

      final results = await _buildSearchCalls(_currentPage);
      final combined = _mergeResults(results);
      quotes.assignAll(combined);
      if (combined.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al buscar: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreQuotes() async {
    if (isLoadingMore.value || !hasMorePages.value || isLoading.value) return;
    try {
      isLoadingMore.value = true;
      _currentPage++;

      final results = await _buildSearchCalls(_currentPage);
      final combined = _mergeResults(results);
      if (combined.isEmpty || combined.length < _pageSize) {
        hasMorePages.value = false;
      }
      quotes.addAll(combined);
    } catch (e) {
      _currentPage--;
      errorMessage.value = 'Error al cargar más cotizaciones: $e';
    } finally {
      isLoadingMore.value = false;
    }
  }

  void applyFilters({
    required String dateFrom,
    required String dateUntil,
  }) {
    fetchQuotes(
      dateFrom: _toIso(dateFrom),
      dateUntil: _toIso(dateUntil, endOfDay: true),
    );
  }

  void clearFilters() {
    searchController.clear();
    searchInput.value = '';
    dateFromFilter.value = '';
    dateUntilFilter.value = '';
    numParteFilter.value = '';
    fetchQuotes();
  }
List<GetQuoteEntity> filteredByTab(int tab) {
  return quotes.where((q) {
    final status = q.status?.toLowerCase() ?? '';
    switch (tab) {
      case 1: return status == 'generada';
      case 2: return status == 'vencida';
      case 3: return status == 'vendida';
      case 4: return status == 'cancelada';
      default: return true; 
    }
  }).toList();
}
}