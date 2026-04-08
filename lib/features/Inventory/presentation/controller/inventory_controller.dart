import 'package:bcg/features/Inventory/domain/entities/inventory_category_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/domain/usecase/fetch_familias_usecase.dart';
import 'package:bcg/features/Inventory/domain/usecase/fetch_inventario_usecase.dart';
import 'package:bcg/features/Inventory/domain/usecase/fetch_subfamilias_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryController extends GetxController {
  final FetchInventarioUsecase fetchInventarioUsecase;
  final FetchSubfamiliasUsecase fetchSubfamiliasUsecase;
  final FetchFamiliasUsecase fetchFamiliasUsecase;

  InventoryController({
    required this.fetchInventarioUsecase,
    required this.fetchSubfamiliasUsecase,
    required this.fetchFamiliasUsecase,
  });

  final ScrollController scrollController = ScrollController();

  final RxList<InventoryEntity> inventario = <InventoryEntity>[].obs;
  final RxList<InventoryCategoryEntity> familias = <InventoryCategoryEntity>[].obs;
  final RxList<InventoryCategoryEntity> subfamilias = <InventoryCategoryEntity>[].obs;
final RxBool searchByDescription = true.obs; // true = descripción, false = num parte

  final RxBool isLoadingInventario = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingCategorias = false.obs;
  final RxBool hasMorePages = true.obs;
  final RxString errorMessage = ''.obs;

  int _currentPage = 1;
  static const int _pageSize = 20;

  final Rx<String?> selectedFamilia = Rx<String?>(null);
  final Rx<String?> selectedSubfamilia = Rx<String?>(null);

  // Búsqueda por description via API
  final RxString searchInput = ''.obs;
  final TextEditingController searchController = TextEditingController();

  int get activeFiltersCount =>
      [selectedFamilia.value, selectedSubfamilia.value]
          .where((v) => v != null)
          .length;

String? get _parsedDescription {
  final trimmed = searchInput.value.trim();
  if (trimmed.isEmpty || !searchByDescription.value) return null;
  return trimmed;
}

String? get _parsedNumParte {
  final trimmed = searchInput.value.trim();
  if (trimmed.isEmpty || searchByDescription.value) return null;
  return trimmed;
}
  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      loadMoreInventario();
    }
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchCategorias(),
      fetchInventario(),
    ]);
  }

  Future<void> _fetchCategorias() async {
    try {
      isLoadingCategorias.value = true;
      final results = await Future.wait([
        fetchFamiliasUsecase.call(),
        fetchSubfamiliasUsecase.call(),
      ]);
      familias.assignAll(results[0]);
      subfamilias.assignAll(results[1]);
    } catch (e) {
      errorMessage.value = 'Error al cargar categorías: $e';
    } finally {
      isLoadingCategorias.value = false;
    }
  }

  Future<void> fetchInventario() async {
    if (isLoadingInventario.value) return;
    try {
      isLoadingInventario.value = true;
      isLoadingMore.value = false;
      errorMessage.value = '';
      _currentPage = 1;
      hasMorePages.value = true;

      final result = await fetchInventarioUsecase.call(
        _parsedDescription ?? '',
        _parsedNumParte ?? '',
        selectedFamilia.value ?? '',
        selectedSubfamilia.value ?? '',
        _currentPage,
        _pageSize,
      );

      inventario.assignAll(result);
      if (result.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al cargar inventario: $e';
    } finally {
      isLoadingInventario.value = false;
    }
  }

  Future<void> searchInventario() async {
    if (isLoadingInventario.value) return;
    try {
      isLoadingInventario.value = true;
      errorMessage.value = '';
      _currentPage = 1;
      hasMorePages.value = true;

      final result = await fetchInventarioUsecase.call(
        _parsedDescription ?? '',
        _parsedNumParte ?? '',
        selectedFamilia.value ?? '',
        selectedSubfamilia.value ?? '',
        _currentPage,
        _pageSize,
      );

      inventario.assignAll(result);
      if (result.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al buscar: $e';
    } finally {
      isLoadingInventario.value = false;
    }
  }

  Future<void> loadMoreInventario() async {
    if (isLoadingMore.value || !hasMorePages.value || isLoadingInventario.value) return;
    try {
      isLoadingMore.value = true;
      _currentPage++;

   final result = await fetchInventarioUsecase.call(
  _parsedDescription ?? '',
  _parsedNumParte ?? '',   // ✅ agrega este parámetro
  selectedFamilia.value ?? '',
  selectedSubfamilia.value ?? '',
  _currentPage,
  _pageSize,
);

      if (result.isEmpty || result.length < _pageSize) {
        hasMorePages.value = false;
      }
      inventario.addAll(result);
    } catch (e) {
      _currentPage--;
      errorMessage.value = 'Error al cargar más productos: $e';
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> applyFilters({
    required String? familia,
    required String? subfamilia,
  }) async {
    selectedFamilia.value = familia;
    selectedSubfamilia.value = subfamilia;
    await fetchInventario();
  }

Future<void> clearFilters() async {
  searchController.clear();
  searchInput.value = '';
  searchByDescription.value = true; // reset al default
  selectedFamilia.value = null;
  selectedSubfamilia.value = null;
  await fetchInventario();
}
}