
import 'package:bcg/common/settings/routes_names.dart';
import 'package:bcg/features/auth/presentation/page/Splash/splash_page.dart';
import 'package:bcg/features/auth/presentation/page/home/start_page.dart';

import 'package:bcg/features/quotes/presentation/page/cotizaciones_page.dart';
import 'package:bcg/features/Inventory/presentation/page/inventario_screen.dart';
import 'package:bcg/features/auth/presentation/page/login/license_screen.dart';
import 'package:bcg/features/auth/presentation/page/login/login_page.dart';
import 'package:bcg/page/ventas_screen.dart';
import 'package:bcg/page/ver_cotizacion_screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
class AppPages {
  static final routes = [
   
   
        GetPage(name: RoutesNames.welcomePage, page: () => SplashPage()),

        GetPage(name: RoutesNames.loginPage, page: () => LoginPage()),
        GetPage(name: RoutesNames.licensePage, page: () => LicenseScreen()),

        GetPage(name: RoutesNames.homePage, page: () => StartPage()),
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