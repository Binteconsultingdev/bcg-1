
import 'package:bcg/common/settings/routes_names.dart';
import 'package:bcg/features/auth/presentation/page/home/start_page.dart';
import 'package:bcg/page/cotizaciones_screen.dart';
import 'package:bcg/page/inventario_screen.dart';
import 'package:bcg/page/license_screen.dart';
import 'package:bcg/page/login_screen.dart';
import 'package:bcg/page/ventas_screen.dart';
import 'package:bcg/page/ver_cotizacion_screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
class AppPages {
  static final routes = [
   
   
        GetPage(name: RoutesNames.welcomePage, page: () => StartPage()),
  ];

  static final unknownRoute = GetPage(
    name: '/not-found',
    page: () => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada'),
      ),
    ),
  );
}