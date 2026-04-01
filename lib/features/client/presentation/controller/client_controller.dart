import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/domain/usecase/fetch_clients_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientController extends GetxController {
  final FetchClientsUsecase fetchClientsUsecase;
  ClientController({required this.fetchClientsUsecase});

  // ── Scroll ────────────────────────────────────────────────────────────────
  final ScrollController scrollController = ScrollController();

  // ── Estado ────────────────────────────────────────────────────────────────
  final RxList<ClientEntity> clients = <ClientEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMorePages = true.obs;
  final RxString errorMessage = ''.obs;

  // ── Filtros activos ───────────────────────────────────────────────────────
  final RxString clientFilter = ''.obs;
  final RxString companyFilter = ''.obs;
  final RxString rfcFilter = ''.obs;
  final RxString emailFilter = ''.obs;

  // ── Paginación ────────────────────────────────────────────────────────────
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
    super.onClose();
  }

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      loadMoreClients();
    }
  }

  // ── Fetch página 1 (reset) ────────────────────────────────────────────────
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
        client, company, rfc, email, _currentPage, _pageSize,
      );

      clients.assignAll(result);
      if (result.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al cargar clientes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Cargar siguiente página ───────────────────────────────────────────────
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