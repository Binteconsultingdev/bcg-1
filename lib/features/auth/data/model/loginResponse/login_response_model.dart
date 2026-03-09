

import 'package:bcg/features/auth/domain/entities/response/login_response_entity.dart';

class LoginResponseModel extends LoginResponseEntity {
  LoginResponseModel({
    required super.token,
    required super.userId,
  });
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
        token: json['token'],
        userId: json['userId'],
    );
  }
  factory LoginResponseModel.fromEntity(LoginResponseEntity entity) {
    return LoginResponseModel(
      token: entity.token,
      userId: entity.userId,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
    };
  }

}