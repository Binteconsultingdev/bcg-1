
import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/common/errors/convert_message.dart';
import 'package:bcg/common/services/lisencias.dart';
import 'package:bcg/common/settings/routes_names.dart';
import 'package:bcg/common/widgets/alert/custom_alert_type.dart';
import 'package:bcg/features/auth/domain/usecase/validate_licenses_usecase.dart';
import 'package:bcg/framework/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LicenseController extends GetxController {
  final ValidateLicensesUsecase validateLicensesUsecase;
  final PreferencesUser _prefsUser = PreferencesUser();

  LicenseController({required this.validateLicensesUsecase});

  late final List<TextEditingController> fieldControllers;
  late final List<FocusNode> focusNodes;

  final RxBool isLoading = false.obs;
  final RxBool acceptPrivacy = false.obs;
  final RxBool formValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    fieldControllers = List.generate(4, (_) => TextEditingController());
    focusNodes = List.generate(4, (_) => FocusNode());

    for (final c in fieldControllers) {
      c.addListener(_updateFormValid);
    }
    ever(acceptPrivacy, (_) => _updateFormValid());
  }

  void _updateFormValid() {
    final allFilled = fieldControllers.every((c) => c.text.trim().length == 4);
    formValid.value = allFilled && acceptPrivacy.value;
  }

  void togglePrivacy() => acceptPrivacy.value = !acceptPrivacy.value;

void onFieldChanged(String value, int index) {
  // ── Detectar paste de clave completa ──────────────────────────────
  // Ejemplo: "PUCZ-HtUG-2NGU-qKaE" o "PUCZHtUG2NGUqKaE"
  final clean = value.replaceAll('-', '').replaceAll(' ', '');
  if (clean.length > 4) {
    handlePaste(clean, index);
    return;
  }

  // ── Comportamiento normal: avanzar/retroceder foco ────────────────
  if (value.length == 4 && index < 3) {
    focusNodes[index + 1].requestFocus();
  } else if (value.isEmpty && index > 0) {
    focusNodes[index - 1].requestFocus();
  }
}

// Cambia _handlePaste → handlePaste (quita el guión bajo)
void handlePaste(String raw, int startIndex) {
  final clean = raw.replaceAll(RegExp(r'[-\s]'), '');

  for (int i = startIndex; i < 4; i++) {
    final from = (i - startIndex) * 4;
    if (from >= clean.length) break;

    final segment = clean.substring(
      from,
      (from + 4).clamp(0, clean.length),
    );

    fieldControllers[i].text = segment;
    fieldControllers[i].selection = TextSelection.collapsed(
      offset: segment.length,
    );
  }

  final filled = fieldControllers.where((c) => c.text.length == 4).length;
  focusNodes[filled.clamp(0, 3)].requestFocus();
  _updateFormValid();
}

  String get _licencia =>
      fieldControllers.map((c) => c.text.trim()).join('-');

Future<void> onContinueTap() async {
  if (!formValid.value) return;

  try {
    isLoading.value = true;

    final licenseEntity = await validateLicensesUsecase.call(_licencia);

    final licenseService = Get.find<LicenseService>();
    await licenseService.saveLicense(licenseEntity);

    // ✅ Eliminar el savePrefs manual que sobreescribía con el string plano

    print('✅ Licencia válida → base: ${licenseEntity.base}');
    Get.offAllNamed(RoutesNames.loginPage);
  } catch (e) {
    _showErrorAlert('Licencia inválida', cleanExceptionMessage(e));
    print('❌ Error validando licencia: $e');
  } finally {
    isLoading.value = false;
  }
}

  void _showErrorAlert(String title, String message) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.error,
      );
    }
  }

  @override
  void onClose() {
    for (final c in fieldControllers) {
      c.removeListener(_updateFormValid);
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}