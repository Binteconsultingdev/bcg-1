import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/domain/usecase/create_quotes_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_folio_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_quote_usecase.dart';
import 'package:get/get.dart';

class QuotesController extends GetxController {
  final FetchQuoteUsecase fetchQuoteUsecase;
  final CreateQuotesUsecase createQuotesUsecase;
  final FetchFolioUsecase fetchFolioUsecase;
  QuotesController({required this.fetchQuoteUsecase, required this.createQuotesUsecase, required this.fetchFolioUsecase});

  // ── Estado ──────────────────────────────────────────────────────────────
  final RxList<GetQuoteEntity> quotes = <GetQuoteEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Filtros activos ──────────────────────────────────────────────────────
  final RxString clientFilter = ''.obs;
  final RxInt numParteFilter = 0.obs;
  final RxString dateFromFilter = ''.obs;
  final RxString dateUntilFilter = ''.obs;

  @override
  void onReady() {
    super.onReady();
    fetchQuotes();
  }

  Future<void> fetchQuotes({
    String client = '',
    int numParte = 0,
    String dateFrom = '',
    String dateUntil = '',
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Guardar filtros activos
      clientFilter.value = client;
      numParteFilter.value = numParte;
      dateFromFilter.value = dateFrom;
      dateUntilFilter.value = dateUntil;

      final result = await fetchQuoteUsecase.cal(
        client,
        numParte,
        dateFrom,
        dateUntil,
      );

      quotes.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Error al cargar cotizaciones: $e';
    } finally {
      isLoading.value = false;
    }
  }
// ── Helper: convierte "dd/MM/yyyy" → "yyyy-MM-ddT00:00:00" ─────────────
String _toIso(String ddMMyyyy, {bool endOfDay = false}) {
  if (ddMMyyyy.isEmpty) return '';
  final parts = ddMMyyyy.split('/');
  if (parts.length != 3) return '';
  final day   = parts[0];
  final month = parts[1];
  final year  = parts[2];
  final time  = endOfDay ? '23:59:59' : '00:00:00';
  return '$year-$month-${day}T$time';
}
  void applyFilters({
    required String client,
    required String dateFrom,
    required String dateUntil,
  }) {
    fetchQuotes(
      client: client,
      numParte: numParteFilter.value,
     dateFrom: _toIso(dateFrom),              // → "yyyy-MM-ddT00:00:00"
    dateUntil: _toIso(dateUntil, endOfDay: true), // → "yyyy-MM-ddT23:59:59"
    );
  }

  void clearFilters() {
    fetchQuotes();
  }

  // ── Filtro local por tab ─────────────────────────────────────────────────
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