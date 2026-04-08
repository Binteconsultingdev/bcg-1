
import 'package:bcg/common/routes/router.dart';
import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/services/lisencias.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/Inventory/presentation/controller/inventory_controller.dart';
import 'package:bcg/features/auth/presentation/page/Splash/splash_controller.dart';
import 'package:bcg/features/auth/presentation/page/login/license_controller.dart';
import 'package:bcg/features/auth/presentation/page/login/login_controller.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
import 'package:bcg/features/quotes/presentation/controller/create_quote_controller.dart';
import 'package:bcg/features/quotes/presentation/controller/put_quotes_controller.dart';
import 'package:bcg/features/quotes/presentation/controller/quotes_controller.dart';
import 'package:bcg/features/sales/presentation/controller/create_sales_controller.dart';
import 'package:bcg/features/sales/presentation/controller/sales_controller.dart';
import 'package:bcg/usecase_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

UsecaseConfig usecaseConfig = UsecaseConfig();

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
   
   
      debugShowCheckedModeBanner: false,
      theme: ThemeColor.themeData, 
      initialBinding: BindingsBuilder(() {
        Get.put(AuthService(), permanent: true);
        Get.put(LicenseService(), permanent: true);
        Get.put(usecaseConfig.loginUsecase!, permanent: true);
        Get.put(usecaseConfig.createUserUsecase!, permanent: true);
        Get.put(usecaseConfig.validateLicensesUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchFamiliasUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchSubfamiliasUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchInventarioUsecase!, permanent: true);
        Get.put(usecaseConfig.createQuotesUsecase! ,permanent: true);
        Get.put(usecaseConfig.fetchQuotesByidUsecase!, permanent: true);
        Get.put(usecaseConfig.putQuotesUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchQuoteUsecase!,permanent: true);
        Get.put(usecaseConfig.pointSalesUsecase!, permanent: true);
        Get.put(usecaseConfig.generateSalesUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchFolioUsecase!, permanent: true);
        Get.put(usecaseConfig.fetchClientsUsecase!, permanent:  true);
        Get.put(usecaseConfig.createClientUsecase! , permanent:  true);
        Get.put(usecaseConfig.generatePdfUsecase!, permanent:  true);
       
       
        Get.lazyPut(() => LoginController(loginUsecase: Get.find(), validateLicensesUsecase: Get.find() ), fenix: true);
        Get.lazyPut(() => LicenseController(validateLicensesUsecase: Get.find()), fenix: true);
        Get.lazyPut(() => InventoryController(fetchInventarioUsecase: Get.find(), fetchSubfamiliasUsecase: Get.find(), fetchFamiliasUsecase: Get.find()),fenix: true);
        Get.lazyPut(() => SplashController(), fenix: true);
        Get.lazyPut(() => QuotesController(fetchQuoteUsecase: Get.find(),),fenix: true);
        Get.lazyPut(() => CreateQuoteController(createQuotesUsecase: Get.find(), fetchFolioUsecase: Get.find(), generatePdfUsecase: Get.find(),),fenix: true);
        Get.lazyPut(() => SalesController(pointSalesUsecase:Get.find()),fenix: true);
        Get.lazyPut(() => ClientController(fetchClientsUsecase:Get.find(), createClientUsecase: Get.find()),fenix: true);
        Get.lazyPut(() => CreateSalesController(generateSalesUsecase:  Get.find()),fenix: true);
        Get.lazyPut(() => PutQuotesController(putQuotesUsecase: Get.find(), fetchQuotesByidUsecase: Get.find()),fenix: true);

      }),

      getPages: AppPages.routes, 
      unknownRoute: AppPages.unknownRoute, 
    );
  }
} 