import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// import 'package:tu_app/core/theme/theme_color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _obscurePass = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_userController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isLoading = false);
    // TODO: Get.offNamed(Routes.HOME);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ThemeColor.backgroundColor,
        // Scroll para teclado en pantallas pequeñas
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
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: ThemeColor.paddingExtraLarge),

                        // ── Logo card ─────────────────────────────────
                        _buildLogoCard(),

                        const Spacer(),

                        // ── Campos ────────────────────────────────────
                        ThemeColor.createLabeledTextField(
                          label: 'Usuario:',
                          controller: _userController,
                          focusNode: _userFocus,
                          hintText: '',
                          keyboardType: TextInputType.text,
                          borderRadius: ThemeColor.smallBorderRadius,
                          onSubmitted: (_) =>
                              _passFocus.requestFocus(),
                        ),
                        const SizedBox(height: ThemeColor.paddingMedium),

                        ThemeColor.createLabeledTextField(
                          label: 'Contraseña:',
                          controller: _passController,
                          focusNode: _passFocus,
                          hintText: '',
                          obscureText: _obscurePass,
                          borderRadius: ThemeColor.smallBorderRadius,
                          onSubmitted: (_) => _onLogin(),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                                () => _obscurePass = !_obscurePass),
                            child: Icon(
                              _obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: ThemeColor.textSecondaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: ThemeColor.paddingLarge),

                        // ── Botón ─────────────────────────────────────
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
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Card con logo
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLogoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: ThemeColor.paddingLarge,
        horizontal: ThemeColor.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: ThemeColor.surfaceColor,
        borderRadius: ThemeColor.mediumBorderRadius,
        boxShadow: [ThemeColor.cardShadow],
      ),
      child: Image.asset(
        'assets/logo/logo.png',
        height: 100,
        fit: BoxFit.contain,
        // Fallback si no existe el asset
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

  // ─────────────────────────────────────────────────────────────────────────
  // Botón iniciar sesión
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return ThemeColor.widgetButton(
      text: 'iniciar Sesión',
      isLoading: _isLoading,
      onPressed: _onLogin,
      backgroundColor: ThemeColor.primaryColor,
      textColor: ThemeColor.textLightColor,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      padding: const EdgeInsets.symmetric(
        vertical: ThemeColor.paddingMedium,
      ),
      borderRadius: ThemeColor.smallRadius,
      customShadow: ThemeColor.darkShadow,
    );
  }
}