import 'package:bcg/common/errors/convert_message.dart';
import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/settings/routes_names.dart';
import 'package:bcg/common/widgets/alert/custom_alert_type.dart';
import 'package:bcg/features/auth/domain/usecase/login_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class LoginController extends GetxController {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;

  final RxBool isLoading = false.obs;
  final RxBool showPassword = false.obs;

  final AuthService _authService = Get.find<AuthService>();
  final LoginUsecase loginUsecase;
  //final SaveTokenFcmUsecase saveTokenFcmUsecase;


  LoginController({
    required this.loginUsecase,
   //required this.saveTokenFcmUsecase,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  void onemailSubmitted() {
    passwordFocusNode.requestFocus();
  }

  void onPasswordSubmitted() {
    passwordFocusNode.unfocus();
    onLoginTap();
  }

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  void onLoginTap() async {
    if (!_validateFields()) return;

    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final loginResponse = await loginUsecase.execute(
        email: email,
        password: password,
      );

      await _authService.saveLoginResponse(loginResponse);
   
   
      _clearFields();
      await _resetControllersForNewSession();
      
      
   
        Get.offAllNamed( RoutesNames.homePage);
    } catch (e) {
      _showErrorAlert(
        'ACCESO INCORRECTO',
        cleanExceptionMessage(e),
      );
      print(e);
    } finally {
      isLoading.value = false;
    }
  }



  String _getDeviceType() {
    if (GetPlatform.isAndroid) {
      return 'Android';
    } else if (GetPlatform.isIOS) {
      return 'iOS';
    } else if (GetPlatform.isMacOS) {
      return 'macOS';
    } else if (GetPlatform.isWindows) {
      return 'Windows';
    } else if (GetPlatform.isLinux) {
      return 'Linux';
    } else if (GetPlatform.isWeb) {
      return 'Web';
    }
    return 'Unknown';
  }

  Future<void> _resetControllersForNewSession() async {
    print('🔄 Reseteando controllers para nueva sesión...');

    try {
      final controllersToDelete = [];

      for (final controllerType in controllersToDelete) {
        if (Get.isRegistered(tag: controllerType.toString())) {
          Get.delete(tag: controllerType.toString());
          print('🗑️ ${controllerType.toString()} eliminado');
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));

      print('✅ Controllers reseteados para nueva sesión');
    } catch (e) {
      print('❌ Error reseteando controllers: $e');
    }
  }

  void _showErrorAlert(String title, String message,
      {VoidCallback? onDismiss}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.error,
        onConfirm: onDismiss,
      );
    }
  }

  bool _validateFields() {
    if (emailController.text.isEmpty) {
      _showErrorAlert(
        'Advertencia',
        'Por favor, ingresa tu usuario',
      );
      return false;
    }

    if (passwordController.text.isEmpty) {
      _showErrorAlert(
        'Advertencia',
        'Por favor, ingresa tu contraseña',
      );
      return false;
    }

    return true;
  }

  void _clearFields() {
    if (emailController.hasListeners) {
      emailController.clear();
    }
    if (passwordController.hasListeners) {
      passwordController.clear();
    }
  }

  void onRegisterTap() {
    Get.toNamed(RoutesNames.registerPage);
  }

  @override
  void onClose() {
    if (!emailController.hasListeners) {
      emailController.dispose();
    }
    if (!passwordController.hasListeners) {
      passwordController.dispose();
    }

    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    super.onClose();
  }
}