import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';
import 'package:bcg/features/sales/domain/usecase/point_sales_usecase.dart';
import 'package:get/get.dart';

class SalesController extends GetxController {
  final PointSalesUsecase pointSalesUsecase;
  SalesController({required this.pointSalesUsecase});

  // ── Estado ──────────────────────────────────────────────────────────────
  final RxList<PointSaleEntity> sales = <PointSaleEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Filtros activos ──────────────────────────────────────────────────────
  final RxString dateFromFilter = ''.obs;
  final RxString dateUntilFilter = ''.obs;
  final RxString clientFilter = ''.obs;
  final RxString statusPaymentFilter = ''.obs;
  final RxString userFilter = ''.obs;

  @override
  void onReady() {
    super.onReady();
    fetchSales();
  }

  // ── Helper: "dd/MM/yyyy" → "yyyy-MM-ddTHH:mm:ss" ────────────────────────
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
    try {
      isLoading.value = true;
      errorMessage.value = '';

      dateFromFilter.value = dateFrom;
      dateUntilFilter.value = dateUntil;
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
      );

      sales.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Error al cargar ventas: $e';
    } finally {
      isLoading.value = false;
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
    fetchSales(ignoreDates: true);
  }

  // ── Filtro local por tab + búsqueda ─────────────────────────────────────
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