// lib/features/start/start_controller.dart
import 'package:bcg/page/clientes_screen.dart';
import 'package:bcg/page/cotizaciones_screen.dart';
import 'package:bcg/page/inventario_screen.dart';
import 'package:bcg/page/ventas_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class StartController extends GetxController {
  final List<Widget> pages = [
    InventarioScreen(),
   // ForYouPage(),
    CotizacionesScreen(),
    VentasScreen(),
    ClientesScreen(),
  ];
final List<String> labels = [
  'Perfil',
  'Radar',
  'Match',
  'Chat',
];
  final List<String> iconPaths = [
    'assets/icons/home/cliente.png',
    
    'assets/icons/home/cotizaciones.png',
    'assets/icons/home/inventario.png',
    'assets/icons/home/ventas.png',
  ];

  final List<String> selectedIconPaths = [
    'assets/icons/home/cliente.png',
    
    'assets/icons/home/cotizaciones.png',
    'assets/icons/home/inventario.png',
    'assets/icons/home/ventas.png',
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