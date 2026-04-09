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

  final RxBool isLoadingInventario = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingCategorias = false.obs;
  final RxBool hasMorePages = true.obs;
  final RxString errorMessage = ''.obs;

  int _currentPage = 1;
  static const int _pageSize = 20;

  final Rx<String?> selectedFamilia = Rx<String?>(null);
  final Rx<String?> selectedSubfamilia = Rx<String?>(null);

  final RxString searchInput = ''.obs;
  final TextEditingController searchController = TextEditingController();

  int get activeFiltersCount =>
      [selectedFamilia.value, selectedSubfamilia.value]
          .where((v) => v != null)
          .length;

  String? get _parsedDescription {
    final trimmed = searchInput.value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? get _parsedNumParte {
    final trimmed = searchInput.value.trim();
    return trimmed.isEmpty ? null : trimmed;
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

  List<InventoryEntity> _mergeResults(
    List<InventoryEntity> byDescription,
    List<InventoryEntity> byNumParte,
  ) {
    final seen = <String>{};
    final merged = <InventoryEntity>[];
    for (final item in [...byDescription, ...byNumParte]) {
      final key = item.partNumber ?? item.description ?? '';
      if (seen.add(key)) merged.add(item);
    }
    return merged;
  }

  Future<void> fetchInventario() async {
    if (isLoadingInventario.value) return;
    try {
      isLoadingInventario.value = true;
      isLoadingMore.value = false;
      errorMessage.value = '';
      _currentPage = 1;
      hasMorePages.value = true;

      final results = await Future.wait([
        fetchInventarioUsecase.call(
          _parsedDescription ?? '',
          '',
          selectedFamilia.value ?? '',
          selectedSubfamilia.value ?? '',
          _currentPage,
          _pageSize,
        ),
        fetchInventarioUsecase.call(
          '',
          _parsedNumParte ?? '',
          selectedFamilia.value ?? '',
          selectedSubfamilia.value ?? '',
          _currentPage,
          _pageSize,
        ),
      ]);

      final combined = _mergeResults(results[0], results[1]);
      inventario.assignAll(combined);
      if (combined.length < _pageSize) hasMorePages.value = false;
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

      final results = await Future.wait([
        fetchInventarioUsecase.call(
          _parsedDescription ?? '',
          '',
          selectedFamilia.value ?? '',
          selectedSubfamilia.value ?? '',
          _currentPage,
          _pageSize,
        ),
        fetchInventarioUsecase.call(
          '',
          _parsedNumParte ?? '',
          selectedFamilia.value ?? '',
          selectedSubfamilia.value ?? '',
          _currentPage,
          _pageSize,
        ),
      ]);

      final combined = _mergeResults(results[0], results[1]);
      inventario.assignAll(combined);
      if (combined.length < _pageSize) hasMorePages.value = false;
    } catch (e) {
      errorMessage.value = 'Error al buscar: $e';
    } finally {
      isLoadingInventario.value = false;
    }
  }

  // Método público para buscar desde otros controllers (ej. CreateQuoteController)
  Future<List<InventoryEntity>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];
    final trimmed = query.trim();

    final results = await Future.wait([
      fetchInventarioUsecase.call(trimmed, '', '', '', 1, 20),
      fetchInventarioUsecase.call('', trimmed, '', '', 1, 20),
    ]);

    return _mergeResults(results[0], results[1]);
  }

  Future<void> loadMoreInventario() async {
    if (isLoadingMore.value || !hasMorePages.value || isLoadingInventario.value) return;
    try {
      isLoadingMore.value = true;
      _currentPage++;

      final results = await Future.wait([
        fetchInventarioUsecase.call(
          _parsedDescription ?? '',
          '',
          selectedFamilia.value ?? '',
          selectedSubfamilia.value ?? '',
          _currentPage,
          _pageSize,
        ),
        fetchInventarioUsecase.call(
          '',
          _parsedNumParte ?? '',
          selectedFamilia.value ?? '',
          selectedSubfamilia.value ?? '',
          _currentPage,
          _pageSize,
        ),
      ]);

      final combined = _mergeResults(results[0], results[1]);
      if (combined.isEmpty || combined.length < _pageSize) {
        hasMorePages.value = false;
      }
      inventario.addAll(combined);
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
    selectedFamilia.value = null;
    selectedSubfamilia.value = null;
    await fetchInventario();
  }
}