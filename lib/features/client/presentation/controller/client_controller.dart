import 'package:bcg/common/errors/convert_message.dart';
import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/domain/entities/create_client_entity.dart';
import 'package:bcg/features/client/domain/usecase/create_client_usecase.dart';
import 'package:bcg/features/client/domain/usecase/fetch_clients_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientController extends GetxController {
  final FetchClientsUsecase fetchClientsUsecase;
  final CreateClientUsecase createClientUsecase;
  ClientController({
    required this.fetchClientsUsecase,
    required this.createClientUsecase,
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

  bool get isFormValid =>
      empresaCtrl.text.trim().isNotEmpty && nombreCtrl.text.trim().isNotEmpty;

  final RxString clientFilter = ''.obs;
  final RxString companyFilter = ''.obs;
  final RxString rfcFilter = ''.obs;
  final RxString emailFilter = ''.obs;

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

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      loadMoreClients();
    }
  }

  Future<void> fetchClients({
    String client = '',
    String company = '',
    String rfc = '',
    String email = '',
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

      final result = await fetchClientsUsecase.call(
        client,
        company,
        rfc,
        email,
        _currentPage,
        _pageSize,
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
