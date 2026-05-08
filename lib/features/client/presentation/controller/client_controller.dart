import 'package:bcg/common/errors/convert_message.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/features/client/domain/entities/account_statement_entity.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/domain/entities/create_client_entity.dart';
import 'package:bcg/features/client/domain/usecase/create_client_usecase.dart';
import 'package:bcg/features/client/domain/usecase/fetch_clients_usecase.dart';
import 'package:bcg/features/client/domain/usecase/generate_account_statement_usecase.dart';
import 'package:bcg/features/quotes/presentation/widget/create_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientController extends GetxController {
  final FetchClientsUsecase fetchClientsUsecase;
  final CreateClientUsecase createClientUsecase;
  final GenerateAccountStatementUsecase generateAccountStatementUsecase;

  ClientController({
    required this.fetchClientsUsecase,
    required this.createClientUsecase,
    required this.generateAccountStatementUsecase,
  });

  final ScrollController scrollController = ScrollController();

  final RxList<ClientEntity> clients = <ClientEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMorePages = true.obs;
  final RxString errorMessage = ''.obs;

  final empresaCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  final empresaFocus = FocusNode();
  final nombreFocus = FocusNode();
  final telefonoFocus = FocusNode();
  final emailFocus = FocusNode();

  final RxBool isCreating = false.obs;
  final RxString createError = ''.obs;

  final RxnInt loadingPdfClientId = RxnInt();

  bool get isFormValid =>
      empresaCtrl.text.trim().isNotEmpty && nombreCtrl.text.trim().isNotEmpty;

  final RxString clientFilter = ''.obs;
  final RxString companyFilter = ''.obs;
  final RxString rfcFilter = ''.obs;
  final RxString emailFilter = ''.obs;

  // null = todos, true = con adeudo, false = sin adeudo
  final Rxn<bool> porCobrarFilter = Rxn<bool>();
  // Para el sheet de filtros (temporal antes de aplicar)
  final Rxn<bool> filterPorCobrar = Rxn<bool>();

  int get activeFilters => [
    if (porCobrarFilter.value != null) true,
  ].length;

  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void onReady() {
    super.onReady();
    fetchClients();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    empresaCtrl.dispose();
    nombreCtrl.dispose();
    telefonoCtrl.dispose();
    emailCtrl.dispose();
    empresaFocus.dispose();
    nombreFocus.dispose();
    telefonoFocus.dispose();
    emailFocus.dispose();
    super.onClose();
  }

  void resetForm() {
    empresaCtrl.clear();
    nombreCtrl.clear();
    telefonoCtrl.clear();
    emailCtrl.clear();
    createError.value = '';
    isCreating.value = false;
  }

  Future<void> createClient() async {
    if (!isFormValid) return;
    try {
      isCreating.value = true;
      createError.value = '';

      await createClientUsecase.call(
        CreateClientEntity(
          company: empresaCtrl.text.trim().toUpperCase(),
          name: nombreCtrl.text.trim().toUpperCase(),
          phone: telefonoCtrl.text.trim(),
          email: emailCtrl.text.trim(),
        ),
      );

      resetForm();
      Get.back();
      await fetchClients();
      showSuccessSnackbar('Cliente creado correctamente');
    } catch (e) {
      createError.value = cleanExceptionMessage(e);
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> openAccountStatementPdf(
    BuildContext context,
    int clientId,
    String clientName,
    String dateFrom,
    String dateUntil,
  ) async {
    final pdfCtrl = Get.find<PdfController>();

    String toIso(String ddMMyyyy, {bool endOfDay = false}) {
      final parts = ddMMyyyy.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = endOfDay
          ? DateTime.utc(year, month, day, 23, 59, 59, 999)
          : DateTime.utc(year, month, day, 0, 0, 0, 0);
      return date.toIso8601String();
    }

    try {
      pdfCtrl.reset();
      loadingPdfClientId.value = clientId;
      pdfCtrl.isLoadingPdf.value = true;

      final result = await generateAccountStatementUsecase.call(
        AccountStatementEntity(
          clienteId: clientId,
          startdate: toIso(dateFrom),
          enddate: toIso(dateUntil, endOfDay: true),
        ),
      );

      if (result.generated && result.urlpdf.isNotEmpty) {
        pdfCtrl.folio = 'estado_cuenta_$clientName';
        pdfCtrl.setPdfUrl(result.urlpdf);
        pdfCtrl.isLoadingPdf.value = false;
        pdfCtrl.showOptionsSheet(context);
      }
    } catch (e) {
      showErrorSnackbar('Error al generar estado de cuenta');
    } finally {
      loadingPdfClientId.value = null;
      pdfCtrl.isLoadingPdf.value = false;
    }
  }

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      loadMoreClients();
    }
  }

  // Inicializa valores temporales del sheet antes de abrirlo
  void initFilterSheet() {
    filterPorCobrar.value = porCobrarFilter.value;
  }

  void applyFilterSheet() {
    porCobrarFilter.value = filterPorCobrar.value;
    fetchClients(porCobrar: porCobrarFilter.value);
  }

  void onFilterClear() {
    filterPorCobrar.value = null;
    porCobrarFilter.value = null;
    fetchClients();
  }

  Future<void> fetchClients({
    String client = '',
    String company = '',
    String rfc = '',
    String email = '',
    bool? porCobrar,
  }) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      isLoadingMore.value = false;
      errorMessage.value = '';
      _currentPage = 1;
      hasMorePages.value = true;

      clientFilter.value = client;
      companyFilter.value = company;
      rfcFilter.value = rfc;
      emailFilter.value = email;
      porCobrarFilter.value = porCobrar;

      final result = await fetchClientsUsecase.call(
        client,
        company,
        rfc,
        email,
        _currentPage,
        _pageSize,
        porCobrar: porCobrar,
      );

      clients.assignAll(result);
      if (result.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al cargar clientes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreClients() async {
    if (isLoadingMore.value || !hasMorePages.value || isLoading.value) return;
    try {
      isLoadingMore.value = true;
      _currentPage++;

      final result = await fetchClientsUsecase.call(
        clientFilter.value,
        companyFilter.value,
        rfcFilter.value,
        emailFilter.value,
        _currentPage,
        _pageSize,
        porCobrar: porCobrarFilter.value,
      );

      if (result.isEmpty || result.length < _pageSize) {
        hasMorePages.value = false;
      }
      clients.addAll(result);
    } catch (e) {
      _currentPage--;
      errorMessage.value = 'Error al cargar más clientes: $e';
    } finally {
      isLoadingMore.value = false;
    }
  }

  void clearFilters() => fetchClients();
}