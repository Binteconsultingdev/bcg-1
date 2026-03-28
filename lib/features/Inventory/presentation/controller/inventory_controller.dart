// inventory_controller.dart
import 'package:bcg/features/Inventory/domain/entities/inventory_category_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:bcg/features/Inventory/domain/usecase/fetch_familias_usecase.dart';
import 'package:bcg/features/Inventory/domain/usecase/fetch_inventario_usecase.dart';
import 'package:bcg/features/Inventory/domain/usecase/fetch_subfamilias_usecase.dart';
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

  // ── Estado ────────────────────────────────────────────────────────────────
  final RxList<InventoryEntity> inventario = <InventoryEntity>[].obs;
  final RxList<InventoryCategoryEntity> familias = <InventoryCategoryEntity>[].obs;
  final RxList<InventoryCategoryEntity> subfamilias = <InventoryCategoryEntity>[].obs;

  final RxBool isLoadingInventario = false.obs;
  final RxBool isLoadingCategorias = false.obs;
  final RxString errorMessage = ''.obs;

  // Filtros activos
  final Rx<String?> selectedFamilia = Rx<String?>(null);
  final Rx<String?> selectedSubfamilia = Rx<String?>(null);
  final RxString searchQuery = ''.obs;

  // ── Computed ──────────────────────────────────────────────────────────────
  List<InventoryEntity> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return inventario;
    return inventario
        .where((p) =>
            p.description!.toLowerCase().contains(q) ||
            p.partNumber!.toLowerCase().contains(q))
        .toList();
  }

  int get activeFiltersCount =>
      [selectedFamilia.value, selectedSubfamilia.value]
          .where((v) => v != null)
          .length;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  // ── Carga inicial (categorías + inventario sin filtros) ───────────────────
  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchCategorias(),
      fetchInventario(), // familia y subfamilia vacíos en primer load
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

  // ── Fetch inventario (con o sin filtros) ──────────────────────────────────
  Future<void> fetchInventario() async {
    try {
      isLoadingInventario.value = true;
      errorMessage.value = '';
      final result = await fetchInventarioUsecase.call(
        selectedFamilia.value ?? '',
        selectedSubfamilia.value ?? '',
      );
      inventario.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Error al cargar inventario: $e';
    } finally {
      isLoadingInventario.value = false;
    }
  }

  // ── Aplicar filtros desde el BottomSheet ──────────────────────────────────
  Future<void> applyFilters({
    required String? familia,
    required String? subfamilia,
  }) async {
    selectedFamilia.value = familia;
    selectedSubfamilia.value = subfamilia;
    await fetchInventario();
  }

  // ── Limpiar filtros ───────────────────────────────────────────────────────
  Future<void> clearFilters() async {
    selectedFamilia.value = null;
    selectedSubfamilia.value = null;
    await fetchInventario();
  }

  void onSearchChanged(String value) => searchQuery.value = value;
}