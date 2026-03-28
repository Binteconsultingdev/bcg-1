import 'package:bcg/common/services/auth_service.dart';

import 'package:bcg/common/services/lisencias.dart';
import 'package:bcg/common/settings/routes_names.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final RxBool isLoading = true.obs;

  final AuthService _authService = Get.find<AuthService>();
  final LicenseService _licenseService = Get.find<LicenseService>();

  @override
  void onInit() async {
    super.onInit();
    await checkUserSession();
  }

  Future<void> checkUserSession() async {
    try {
      // ✅ 1. Verificar si hay licencia válida
      final hasLicense = await _licenseService.hasValidLicense();

      if (!hasLicense) {
        print('⚠️ Sin licencia → ir a licencia');
        Get.offAllNamed(RoutesNames.licensePage);
        return;
      }

      print('✅ Licencia encontrada → base: ${await _licenseService.getBase()}');

      // ✅ 2. Verificar si hay sesión activa
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        print('✅ Sesión activa → ir a home');
        Get.offAllNamed(RoutesNames.homePage);
      } else {
        print('⚠️ Sin sesión → ir a login');
        Get.offAllNamed(RoutesNames.loginPage);
      }
    } catch (e) {
      print('❌ Error en splash: $e');
      Get.offAllNamed(RoutesNames.loginPage);
    } finally {
      isLoading.value = false;
    }
  }
}