import 'package:bcg/common/constants/constants.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bcg/common/errors/api_errors.dart';
import 'package:bcg/features/client/data/model/client_model.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:http/http.dart' as http;

class ClientDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  Future<List<ClientEntity>> fetchClients(
    String token,
    String client,
    String company,
    String rfc,
    String email,
    int page,
    int pageSize,
  ) async {
    try {
      Uri url = Uri.parse(
        '$defaultApiServer/Clientes?cliente=$client&empresa=$company&RFC=$rfc&correo=$email&pagina=$page&tamanoPagina=$pageSize',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

  if (response.statusCode == 200) {
  return (jsonDecode(utf8.decode(response.bodyBytes))['items'] as List? ?? [])
      .map((json) => ClientModel.fromJson(json))
      .toList();
}

      throw ApiExceptionCustom(response: response);
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }

      throw Exception(e);
    }
  }

  Future<void> createClient(ClientEntity entity, String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Cliente');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(ClientModel.fromEntity(entity).toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      ApiExceptionCustom exception = ApiExceptionCustom(response: response);
      exception.validateMesage();
      throw exception;
    } catch (e) {
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
