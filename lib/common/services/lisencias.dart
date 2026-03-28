import 'dart:convert';
import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/features/auth/data/model/license/license_model.dart';
import 'package:bcg/features/auth/domain/entities/license/license_entity.dart';
import 'package:bcg/framework/preferences_service.dart';
import 'package:get/get.dart';

class LicenseService extends GetxService {
  static final LicenseService _instance = LicenseService._internal();
  final PreferencesUser _prefsUser = PreferencesUser();

  LicenseEntity? _cachedLicense;

  factory LicenseService() => _instance;

  LicenseService._internal();

  Future<LicenseService> init() async {
    await getLicenseData();
    return this;
  }

  // ================================
  // Obtener datos de licencia
  // ================================
Future<LicenseEntity?> getLicenseData() async {
  if (_cachedLicense != null) return _cachedLicense;

  try {
    final licenseJson = await _prefsUser.loadPrefs(
      type: String,
      key: AppConstants.licenseKey,
    );

    if (licenseJson != null && licenseJson.isNotEmpty) {
      // ✅ Verificar que sea JSON válido antes de parsear
      if (!licenseJson.trimLeft().startsWith('{')) {
        print('⚠️ Valor en prefs no es JSON válido, limpiando...');
        await _prefsUser.clearOnePreference(key: AppConstants.licenseKey);
        return null;
      }

      final Map<String, dynamic> decoded = jsonDecode(licenseJson);
      _cachedLicense = LicenseModel.fromJson(decoded);
      print('✅ Licencia cargada correctamente: ${_cachedLicense?.base}');
      return _cachedLicense;
    }

    return null;
  } catch (e) {
    print('❌ Error al obtener licencia: $e');
    // ✅ Si falla el parse, limpiar el valor corrupto
    await _prefsUser.clearOnePreference(key: AppConstants.licenseKey);
    return null;
  }
}

  // ================================
  // Helpers
  // ================================
  Future<String?> getBase() async {
    final license = await getLicenseData();
    return license?.base;
  }

  Future<String?> getUrlLogo() async {
    final license = await getLicenseData();
    return license?.urllogo;
  }

  Future<String?> getValidity() async {
    final license = await getLicenseData();
    return license?.validity;
  }

  Future<int?> getLicenseId() async {
    final license = await getLicenseData();
    return license?.id;
  }

  // ================================
  // Guardar licencia
  // ================================
Future<bool> saveLicense(LicenseEntity licenseEntity) async {
  try {
    _cachedLicense = licenseEntity;

    // ✅ Convertir el Map a String JSON antes de guardar
    final String jsonString = jsonEncode(
      LicenseModel.fromEntity(licenseEntity).toJson(),
    );

    _prefsUser.savePrefs(
      type: String,
      key: AppConstants.licenseKey,
      value: jsonString,
    );

    AppConstants.serverBase = licenseEntity.base;
    print('✅ Licencia guardada correctamente: ${licenseEntity.base}');
    return true;
  } catch (e) {
    print('❌ Error al guardar licencia: $e');
    return false;
  }
}

  // ================================
  // Estado de licencia
  // ================================
  Future<bool> hasValidLicense() async {
    final license = await getLicenseData();
    return license != null && license.base.isNotEmpty;
  }

  // ================================
  // Limpiar licencia
  // ================================
  Future<bool> clearLicense() async {
    try {
      _cachedLicense = null;
      await _prefsUser.clearOnePreference(key: AppConstants.licenseKey);
      print('✅ Licencia eliminada correctamente');
      return true;
    } catch (e) {
      print('❌ Error al eliminar licencia: $e');
      return false;
    }
  }
}