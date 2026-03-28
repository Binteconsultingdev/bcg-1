// lib/features/start/start_controller.dart
import 'package:bcg/page/clientes_screen.dart';
import 'package:bcg/features/quotes/presentation/page/cotizaciones_page.dart';
import 'package:bcg/features/Inventory/presentation/page/inventario_screen.dart';
import 'package:bcg/page/ventas_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartController extends GetxController {
  final List<Widget> pages = [
    InventarioScreen(),
    CotizacionesPage(),
    VentasScreen(),
    ClientesScreen(),
  ];
  final List<String> labels = ['Inventario', 'Cotizaciones', 'Ventas', 'Clientes'];
  final List<String> iconPaths = [
    'assets/icons/home/inventario.png',
    'assets/icons/home/cotizaciones.png',
    'assets/icons/home/ventas.png',
    'assets/icons/home/cliente.png',
  ];

  final List<String> selectedIconPaths = [
    'assets/icons/home/inventario.png',

    'assets/icons/home/cotizaciones.png',
    'assets/icons/home/ventas.png',
    'assets/icons/home/cliente.png',
  ];

  final RxInt selectedIndex = 0.obs;

  final RxBool isCheckingProfile = true.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  Widget get currentPage => pages[selectedIndex.value];

  String getIconPath(int index) {
    return selectedIndex.value == index
        ? selectedIconPaths[index]
        : iconPaths[index];
  }

  @override
  void onInit() {
    super.onInit();
  }

  // ==========================================
  // VERIFICAR PERFIL COMPLETO
  // ==========================================

  @override
  void onClose() {
    super.onClose();
  }
}
