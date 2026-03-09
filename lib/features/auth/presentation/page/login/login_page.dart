import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/auth/presentation/page/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/fondo.png', fit: BoxFit.cover),
              ),

              Positioned.fill(
                child: Container(
                  color: const Color.fromARGB(255, 93, 93, 93).withOpacity(0.6),
                ),
              ),
            ],
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ThemeColor.paddingLarge,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    SizedBox(height: ThemeColor.paddingExtraLarge * 2),
                    _buildLoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('assets/logo/logo.png', width: 170, height: 70),
        ),
        SizedBox(height: ThemeColor.paddingLarge),
        Text(
          'Iniciar Sesión',
          style: ThemeColor.headingLarge.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ThemeColor.textDarkColor,
          ),
        ),
        SizedBox(height: ThemeColor.paddingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Aún no tienes una cuenta? ',
              style: ThemeColor.bodyMedium.copyWith(
                color: ThemeColor.textDarkColor,
              ),
            ),
            GestureDetector(
              onTap: controller.onRegisterTap,
              child: Text(
                'Registrarse',
                style: ThemeColor.bodyMedium.copyWith(
                  color: ThemeColor.primaryColor,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: ThemeColor.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeColor.createLabeledTextField(
            label: 'Correo electrónico:',
            controller: controller.emailController,
            focusNode: controller.emailFocusNode,
            hintText: 'correo@gmail.com',
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => controller.onemailSubmitted(),
          ),

          SizedBox(height: ThemeColor.paddingLarge),

          Obx(
            () => ThemeColor.createLabeledTextField(
              label: 'Contraseña:',
              controller: controller.passwordController,
              focusNode: controller.passwordFocusNode,
              hintText: '••••••••••',
              obscureText: !controller.showPassword.value,
              onSubmitted: (_) => controller.onPasswordSubmitted(),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.showPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: ThemeColor.textSecondaryColor,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),

          SizedBox(height: ThemeColor.paddingMedium),
          _buildRememberMeCheckbox(),
          SizedBox(height: ThemeColor.paddingExtraLarge),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Text(
          'Recuérdame',
          style: ThemeColor.bodyMedium.copyWith(
            color: ThemeColor.textSecondaryColor,
          ),
        ),
        SizedBox(width: ThemeColor.paddingSmall),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: ThemeColor.primaryColor,
            borderRadius: ThemeColor.smallBorderRadius,
          ),
          child: Icon(Icons.check, color: ThemeColor.textLightColor, size: 16),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.onLoginTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColor.tertiaryColor,
            foregroundColor: ThemeColor.textLightColor,
            disabledBackgroundColor: ThemeColor.primaryColor.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: ThemeColor.circularBorderRadius,
            ),
            elevation: ThemeColor.elevationSmall,
            shadowColor: ThemeColor.shadowColor,
          ),
          child: controller.isLoading.value
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeColor.textLightColor,
                    ),
                  ),
                )
              : Text(
                  'Iniciar Sesión',
                  style: ThemeColor.buttonText.copyWith(fontSize: 16),
                ),
        ),
      ),
    );
  }
}
