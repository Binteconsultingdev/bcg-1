

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/common/errors/api_errors.dart';
import 'package:bcg/features/auth/data/model/license/license_model.dart';
import 'package:bcg/features/auth/data/model/loginResponse/login_response_model.dart';
import 'package:bcg/features/auth/data/model/user/create_user_model.dart';
import 'package:bcg/features/auth/domain/entities/license/license_entity.dart';
import 'package:bcg/features/auth/domain/entities/response/login_response_entity.dart';
import 'package:bcg/features/auth/domain/entities/user/create_user_entity.dart';
import 'package:http/http.dart' as http;


class AuthDataSourceImp {
  String defaultApiServer = AppConstants.serverBase;
  Future<LicenseEntity> validateLicenses(String licencia) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Licencias/validar');
      final bodyData = jsonEncode({'licencia': licencia});

      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: bodyData,
      );

         if (response.statusCode == 200 || response.statusCode == 201) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        return LicenseModel.fromJson(responseDecode);
      }

      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }
  Future<LoginResponseEntity> login(String user, String password, String baseDatos) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Auth/login');
      final bodyData = jsonEncode({'usuario': user, 'contrasena': password, 'baseDatos': baseDatos});

      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: bodyData,
      );

      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        return LoginResponseModel.fromJson(responseDecode);
      }

      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }

  Future<void> createuser(CreateUserEntity entity) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Auth/registrar');

      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(CreateUserModel.fromEntity(entity).toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e, stackTrace) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        print('🌐 Error de red detectado');
        throw Exception(convertMessageException(error: e));
      }

      throw Exception('$e');
    }
  }
}
