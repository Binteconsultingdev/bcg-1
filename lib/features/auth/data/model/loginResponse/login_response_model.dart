import 'package:bcg/features/auth/domain/entities/response/login_response_entity.dart';

class LoginResponseModel extends LoginResponseEntity {
  LoginResponseModel({
    required super.token,
    required super.userId,
    required super.nombre,
    required super.usuario,
    required super.area,
    super.logoUrl,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'],
      userId: json['userId'],
      nombre: json['nombre'],
      usuario: json['usuario'],
      area: json['area'],
      logoUrl: json['logoUrl'],
    );
  }

  factory LoginResponseModel.fromEntity(LoginResponseEntity entity) {
    return LoginResponseModel(
      token: entity.token,
      userId: entity.userId,
      nombre: entity.nombre,
      usuario: entity.usuario,
      area: entity.area,
      logoUrl: entity.logoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
      'nombre': nombre,
      'usuario': usuario,
      'area': area,
      'logoUrl': logoUrl,
    };
  }
}