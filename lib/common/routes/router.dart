
import 'package:bcg/common/settings/routes_names.dart';
import 'package:bcg/features/auth/presentation/page/Splash/splash_page.dart';
import 'package:bcg/features/auth/presentation/page/home/start_page.dart';

import 'package:bcg/features/quotes/presentation/page/cotizaciones_page.dart';
import 'package:bcg/features/Inventory/presentation/page/inventario_screen.dart';
import 'package:bcg/features/auth/presentation/page/login/license_screen.dart';
import 'package:bcg/features/auth/presentation/page/login/login_page.dart';
import 'package:bcg/features/quotes/presentation/page/create_quote_page.dart';
import 'package:bcg/features/quotes/presentation/page/put_quotes_page.dart';
import 'package:bcg/features/sales/presentation/page/CreateSalesPage.dart';
import 'package:bcg/features/sales/presentation/page/ventas_page.dart';
import 'package:bcg/page/ver_cotizacion_screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
class AppPages {
  static final routes = [
   
   
        GetPage(name: RoutesNames.welcomePage, page: () => SplashPage()),
        GetPage(name: RoutesNames.createQuotePage, page: () => CreateQuotePage()),
        GetPage(name: RoutesNames.createSalesPage, page: () =>CreateSalesPage()),

        GetPage(name: RoutesNames.loginPage, page: () => LoginPage()),
        GetPage(name: RoutesNames.licensePage, page: () => LicenseScreen()),

        GetPage(name: RoutesNames.homePage, page: () => StartPage()),
        GetPage(name: RoutesNames.putQuotePage, page: () => EditQuotePage()),
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