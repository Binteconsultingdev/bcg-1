import 'package:bcg/common/constants/constants.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/common/errors/api_errors.dart';
import 'package:bcg/features/client/data/model/client_model.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/quotes/data/model/folio_model.dart';
import 'package:bcg/features/quotes/data/model/get_quote_model.dart';
import 'package:bcg/features/quotes/data/model/quote_model.dart';
import 'package:bcg/features/quotes/domain/entities/folito_entity.dart';
import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:http/http.dart' as http;

class ClientDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;

Future<List<ClientEntity>> fetchClients(
    String token,) async {
  try {
    Uri url = Uri.parse(
        '$defaultApiServer/Cliente');


    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dataUTF8 = utf8.decode(response.bodyBytes);
   

      final responseData = jsonDecode(dataUTF8) as List;

      return responseData
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
      },        body: jsonEncode(ClientModel.fromEntity(entity).toJson()),
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