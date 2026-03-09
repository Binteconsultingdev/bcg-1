import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Asegúrate de importar tu ThemeColor
// import 'package:tu_app/core/theme/theme_color.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen>
    with SingleTickerProviderStateMixin {
  // 4 campos para la clave de licencia
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  bool _acceptPrivacy = false;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  void _onFieldChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  bool get _isFormValid {
    final allFilled = _controllers.every((c) => c.text.trim().isNotEmpty);
    return allFilled && _acceptPrivacy;
  }

  Future<void> _onContinue() async {
    if (!_isFormValid) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isLoading = false);
    // TODO: navegar a la siguiente pantalla
    // Get.offNamed(Routes.HOME);
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeColor.paddingLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Logo ──────────────────────────────────────────
                    const SizedBox(height: ThemeColor.paddingExtraLarge),
                    _buildLogo(),

                    const Spacer(),

                    // ── Título ────────────────────────────────────────
                    Text(
                      'CLAVE DE LICENCIA',
                      style: ThemeColor.headingMedium.copyWith(
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w800,
                        color: ThemeColor.textPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ThemeColor.paddingLarge),

                    // ── Campos de licencia ────────────────────────────
                    _buildLicenseFields(),
                    const SizedBox(height: ThemeColor.paddingMedium),

                    // ── Checkbox privacidad ───────────────────────────
                    _buildPrivacyCheckbox(),

                    const Spacer(),

                    // ── Botón Continuar ───────────────────────────────
                    _buildContinueButton(),
                    const SizedBox(height: ThemeColor.paddingExtraLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logo
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Image.asset(
      'assets/logo/logo.png',
      height: 70,
      fit: BoxFit.contain,
      // fallback si no existe el asset en desarrollo
      errorBuilder: (_, __, ___) => Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: ThemeColor.paddingMedium),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono hexágono BCG simulado
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ThemeColor.primaryColor,
                borderRadius: ThemeColor.smallBorderRadius,
              ),
              child: const Center(
                child: Text(
                  'B',
                  style: TextStyle(
                    color: ThemeColor.accentColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BCG',
                  style: ThemeColor.headingSmall.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Binte Consulting Group',
                  style: ThemeColor.caption.copyWith(
                    color: ThemeColor.textSecondaryColor,
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
  // Campos de licencia (4 bloques)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLicenseFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ancho disponible - padding horizontal de la pantalla (2 * paddingLarge)
        final availableWidth = constraints.maxWidth;
        // 3 separadores de ~20px c/u + 8px de padding horizontal c/u = ~84px total
        const separatorsWidth = 3 * 28.0;
        // Calcular ancho de cada campo dinámicamente
        final fieldWidth = ((availableWidth - separatorsWidth) / 4)
            .clamp(50.0, 90.0);
        final fieldHeight = fieldWidth * 0.75;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final isLast = i == 3;
            return Row(
              children: [
                _LicenseField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  onChanged: (v) => _onFieldChanged(v, i),
                  width: fieldWidth,
                  height: fieldHeight,
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '–',
                      style: ThemeColor.headingMedium.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                    ),
                  ),
              ],
            );
          }),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Checkbox aviso de privacidad
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPrivacyCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Checkbox personalizado con colores del theme
        GestureDetector(
          onTap: () => setState(() => _acceptPrivacy = !_acceptPrivacy),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _acceptPrivacy
                  ? ThemeColor.primaryColor
                  : ThemeColor.surfaceColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _acceptPrivacy
                    ? ThemeColor.primaryColor
                    : ThemeColor.dividerColor,
                width: 1.5,
              ),
              boxShadow: [ThemeColor.lightShadow],
            ),
            child: _acceptPrivacy
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: ThemeColor.accentColor,
                  )
                : null,
          ),
        ),
        const SizedBox(width: ThemeColor.paddingSmall),
        GestureDetector(
          onTap: () => setState(() => _acceptPrivacy = !_acceptPrivacy),
          child: Text(
            'Aceptar aviso de privacidad',
            style: ThemeColor.bodyMedium.copyWith(
              color: ThemeColor.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Botón Continuar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildContinueButton() {
    final bool enabled = _isFormValid;

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 300),
      child: ThemeColor.widgetButton(
        text: 'Continuar',
        isLoading: _isLoading,
        onPressed: enabled ? _onContinue : null,
        backgroundColor: ThemeColor.primaryColor,
        textColor: ThemeColor.textLightColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        padding: const EdgeInsets.symmetric(
          vertical: ThemeColor.paddingMedium,
          horizontal: ThemeColor.paddingLarge,
        ),
        borderRadius: ThemeColor.mediumRadius,
        customShadow: ThemeColor.darkShadow,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget interno: campo individual de licencia
// ─────────────────────────────────────────────────────────────────────────────
class _LicenseField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final double width;
  final double height;

  const _LicenseField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.width = 72,
    this.height = 54,
  });

  @override
  State<_LicenseField> createState() => _LicenseFieldState();
}

class _LicenseFieldState extends State<_LicenseField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: ThemeColor.surfaceColor,
        borderRadius: ThemeColor.smallBorderRadius,
        border: Border.all(
          color: _isFocused
              ? ThemeColor.accentColor
              : ThemeColor.dividerColor,
          width: _isFocused ? 2.0 : 1.2,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: ThemeColor.accentColor.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          else
            ThemeColor.lightShadow,
        ],
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          maxLength: 4,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(4),
          ],
          style: ThemeColor.subtitleLarge.copyWith(
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
            color: ThemeColor.textPrimaryColor,
          ),
          onChanged: widget.onChanged,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}