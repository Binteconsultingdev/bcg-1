import 'package:bcg/features/auth/domain/entities/license/license_entity.dart';

class LicenseModel extends LicenseEntity {
  LicenseModel({required int id, required String validity, required String base, required String urllogo})
      : super(id: id, validity: validity, base: base, urllogo: urllogo);
   
  factory LicenseModel.fromJson(Map<String, dynamic> json) {
    return LicenseModel(
      id: json['id'],
      validity: json['vigencia'],
      base: json['base'],
      urllogo: json['urL_Logo'],
    );
  }
  factory LicenseModel.fromEntity(LicenseEntity entity) {
    return LicenseModel(
      id: entity.id,
      validity: entity.validity,
      base: entity.base,
      urllogo: entity.urllogo,
    );
  }
    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vigencia': validity,
      'base': base,
      'urL_Logo': urllogo,
    };
  }
}