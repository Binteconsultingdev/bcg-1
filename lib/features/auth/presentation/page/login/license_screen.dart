import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/auth/presentation/page/login/license_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class _PasteAwareFormatter extends TextInputFormatter {
  final int fieldIndex;
  final void Function(String raw, int index) onPaste;

  _PasteAwareFormatter({required this.fieldIndex, required this.onPaste});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clean = newValue.text.replaceAll('-', '').replaceAll(' ', '');

    if (clean.length > 4) {
      Future.microtask(() => onPaste(clean, fieldIndex));
      final segment = clean.substring(0, 4);
      return TextEditingValue(
        text: segment,
        selection: TextSelection.collapsed(offset: segment.length),
      );
    }

    return newValue;
  }
}

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen>
    with SingleTickerProviderStateMixin {
  late final LicenseController _controller;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LicenseController>();

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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeColor.paddingLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: ThemeColor.paddingExtraLarge),
                    _buildLogo(),
                    const Spacer(),
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
                    _buildLicenseFields(),
                    const SizedBox(height: ThemeColor.paddingMedium),
                    _buildPrivacyCheckbox(),
                    const Spacer(),
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

  Widget _buildLogo() {
    return Image.asset(
      'assets/logo/logo.png',
      height: 70,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        height: 70,
        padding: const EdgeInsets.symmetric(
            horizontal: ThemeColor.paddingMedium),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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

  Widget _buildLicenseFields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const separatorsWidth = 3 * 28.0;
        final fieldWidth =
            ((availableWidth - separatorsWidth) / 4).clamp(50.0, 90.0);
        final fieldHeight = fieldWidth * 0.75;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final isLast = i == 3;
            return Row(
              children: [
                _LicenseField(
                  controller: _controller.fieldControllers[i],
                  focusNode: _controller.focusNodes[i],
                  onChanged: (v) => _controller.onFieldChanged(v, i),
                  fieldIndex: i,
                  onPaste: _controller.handlePaste,
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
 Widget _buildPrivacyCheckbox() {
  return Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _controller.togglePrivacy,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _controller.acceptPrivacy.value
                    ? ThemeColor.primaryColor
                    : ThemeColor.surfaceColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _controller.acceptPrivacy.value
                      ? ThemeColor.primaryColor
                      : ThemeColor.dividerColor,
                  width: 1.5,
                ),
                boxShadow: [ThemeColor.lightShadow],
              ),
              child: _controller.acceptPrivacy.value
                  ? const Icon(Icons.check, size: 14,
                      color: ThemeColor.accentColor)
                  : null,
            ),
          ),
          const SizedBox(width: ThemeColor.paddingSmall),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _controller.togglePrivacy,
                child: Text(
                  'Aceptar ',
                  style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.textSecondaryColor,
                  ),
                ),
              ),
              // ✅ Solo "aviso de privacidad" es clickeable y abre el webview
             GestureDetector(
  onTap: () async {
    final uri = Uri.parse(
        'https://binteconsulting.com/aviso-privacidad-bcg.html');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  },
  child: Text(
    'aviso de privacidad',
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
      ));
}

  Widget _buildContinueButton() {
    return Obx(() {
      final enabled = _controller.formValid.value;
      return AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 300),
        child: ThemeColor.widgetButton(
          text: 'Continuar',
          isLoading: _controller.isLoading.value,
          onPressed: enabled ? _controller.onContinueTap : null,
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
    });
  }
}

class _LicenseField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final void Function(String raw, int index) onPaste;
  final int fieldIndex;
  final double width;
  final double height;

  const _LicenseField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onPaste,
    required this.fieldIndex,
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
          color:
              _isFocused ? ThemeColor.accentColor : ThemeColor.dividerColor,
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
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
            _PasteAwareFormatter(
              fieldIndex: widget.fieldIndex,
              onPaste: widget.onPaste,
            ),
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