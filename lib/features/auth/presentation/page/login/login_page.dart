import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/auth/presentation/page/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final LoginController _controller;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LoginController>();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ThemeColor.backgroundColor,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeColor.paddingLarge,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeColor.paddingExtraLarge,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: ThemeColor.paddingExtraLarge),

                          _buildLogoCard(),
                          const Spacer(),
                          Text(
                            'BIENVENIDO',
                            style: ThemeColor.headingMedium.copyWith(
                              color: ThemeColor.textPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          ThemeColor.createLabeledTextField(
                            label: 'Usuario:',
                            controller: _controller.userController,
                            focusNode: _controller.emailFocusNode,
                            hintText: '',
                            keyboardType: TextInputType.text,
                            borderRadius: ThemeColor.circularBorderRadius,
                            fillColor: ThemeColor.tertiaryColor,

                            focusedBorderColor: ThemeColor.primaryColor,
                            textStyle: ThemeColor.bodyMedium.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeColor.textLightColor,
                            ),

                            onSubmitted: (_) => _controller.onemailSubmitted(),
                          ),
                          const SizedBox(height: ThemeColor.paddingMedium),

                          Obx(
                            () => ThemeColor.createLabeledTextField(
                              label: 'Contraseña:',
                              controller: _controller.passwordController,
                              focusNode: _controller.passwordFocusNode,
                              hintText: '',
                              obscureText: _controller.showPassword.value
                                  ? false
                                  : true,
                              borderRadius: ThemeColor.circularBorderRadius,
                              onSubmitted: (_) =>
                                  _controller.onPasswordSubmitted(),
                              suffixIcon: GestureDetector(
                                onTap: _controller.togglePasswordVisibility,
                                child: Icon(
                                  _controller.showPassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: ThemeColor.textSecondaryColor,
                                  size: 20,
                                ),
                              ),
                              fillColor: ThemeColor.tertiaryColor,
                              textColor: ThemeColor.textLightColor,
                              focusedBorderColor: ThemeColor.primaryColor,
                              textStyle: ThemeColor.bodyMedium.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ThemeColor.textLightColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: ThemeColor.paddingLarge),

                          _buildLoginButton(),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: ThemeColor.paddingLarge,
        horizontal: ThemeColor.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.surfaceColor,
        borderRadius: ThemeColor.extraLargeBorderRadius,
        boxShadow: [ThemeColor.darkShadow],
      ),
      child: Image.asset(
        'assets/logo/logo.png',
        height: 100,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor,
                borderRadius: ThemeColor.smallBorderRadius,
              ),
              child: const Center(
                child: Text(
                  'B',
                  style: TextStyle(
                    color: ThemeColor.accentColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BCG',
                  style: ThemeColor.headingLarge.copyWith(
                    letterSpacing: 3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Binte Consulting Group',
                  style: ThemeColor.caption.copyWith(
                    color: ThemeColor.textSecondaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => ThemeColor.widgetButton(
        text: 'Iniciar Sesión',
        isLoading: _controller.isLoading.value,
        onPressed: _controller.onLoginTap,
        backgroundColor: ThemeColor.tertiaryColor,
        textColor: ThemeColor.textLightColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        padding: const EdgeInsets.symmetric(vertical: ThemeColor.paddingMedium),
        borderRadius: ThemeColor.largeRadius,
        customShadow: ThemeColor.darkShadow,
      ),
    );
  }
}
