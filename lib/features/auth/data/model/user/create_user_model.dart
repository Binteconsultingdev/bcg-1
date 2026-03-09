

import 'package:bcg/features/auth/domain/entities/user/create_user_entity.dart';

class CreateUserModel extends CreateUserEntity {
  CreateUserModel({
    required super.name,
    required super.email,
    required super.password,
    required super.dateofbirth,
    required super.gender,
    required super.bio,
    required super.heightcm,
    required super.primarylanguage,
    required super.city,
    required super.lat,
    required super.lng,
    required super.interestsIds,
    required super.qualitiesIds,
  });

  factory CreateUserModel.fromEntity(CreateUserEntity entity) {
    return CreateUserModel(
      name: entity.name,
      email: entity.email,
      password: entity.password,
      dateofbirth: entity.dateofbirth,
      gender: entity.gender,
      bio: entity.bio,
      heightcm: entity.heightcm,
      primarylanguage: entity.primarylanguage,
      city: entity.city,
      lat: entity.lat,
      lng: entity.lng,
      interestsIds: entity.interestsIds,
      qualitiesIds: entity.qualitiesIds,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
      'email': email,
      'password': password,
      'fecha_nacimiento': dateofbirth,
      'genero': gender,
      'bio': bio,
      'altura_cm': heightcm,
      'idioma_principal': primarylanguage,
      'ciudad': city,
      'lat': lat,
      'lng': lng,
      'interesesIds': interestsIds,
      'cualidadesIds': qualitiesIds,
    };
  }
}
