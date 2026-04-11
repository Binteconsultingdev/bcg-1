import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/common/errors/api_errors.dart';
import 'package:bcg/features/quotes/data/model/folio_model.dart';
import 'package:bcg/features/quotes/data/model/get_quote_model.dart';
import 'package:bcg/features/quotes/data/model/quote_model.dart';
import 'package:bcg/features/quotes/data/model/quote_pdf_model.dart';
import 'package:bcg/features/quotes/data/model/response_create_model.dart';
import 'package:bcg/features/quotes/domain/entities/folito_entity.dart';
import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_pdf_entity.dart';
import 'package:bcg/features/quotes/domain/entities/response_create_entity.dart';
import 'package:http/http.dart' as http;

class QuotesDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  Future<List<GetQuoteEntity>> fetchQuote(
    String token,
    String client,
    String numParte,
    String dateFrom,
    String dateUntil,
    int page,
    int pageSize, {
    String? folio,
    String? id,
  }) async {
    try {
      final queryParams = {
        'cliente': client,
        'numParte': numParte,
        'fechaDesde': dateFrom,
        'fechaHasta': dateUntil,
        'pagina': page.toString(),
        'tamanoPagina': pageSize.toString(),
        if (folio != null && folio.isNotEmpty) 'folio': folio,
        if (id != null) 'id': id.toString(),
        
      };

      Uri url = Uri.parse(
        '$defaultApiServer/Cotizaciones',
      ).replace(queryParameters: queryParams);
 print('🔍 URL de búsqueda: $url');
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
            .map((json) => GetQuoteModel.fromJson(json))
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
  Future<QuoteEntity> fetchQuotebyid(String token, int id) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Cotizaciones/$id');
 print('🔍 URL de búsqueda por ID: $url');
       final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

         if (response.statusCode == 200 || response.statusCode == 201) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        return QuoteModel.fromJson(responseDecode);
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
 Future<void> updateQuote(
  String token,
  QuoteEntity entity,
  int id,
) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/Cotizaciones/$id');

    final payload = jsonEncode(QuoteModel.fromEntity(entity).toJson());

    print('🚀 Iniciando updateQuote');
    print('🆔 ID de cotización: $id');
    print('🌐 URL: $url');
    print('📦 Payload: $payload');
    print('🔑 Token: $token');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: payload,
    );

    print('📥 Status Code: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Cotización actualizada correctamente');
      return;
    }

    print('⚠️ Error en la respuesta del servidor');

    ApiExceptionCustom exception = ApiExceptionCustom(response: response);
    exception.validateMesage();
    throw exception;

  } catch (e) {
    print('❌ Error capturado: $e');

    if (e is SocketException ||
        e is http.ClientException ||
        e is TimeoutException) {
      print('🌐 Error de red detectado');
      throw Exception(convertMessageException(error: e));
    }

    throw Exception('$e');
  }
}
  Future<ResponseCreateEntity> createQuote(
    QuoteEntity entity,
    String token,
  ) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Cotizaciones');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(QuoteModel.fromEntity(entity).toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        return ResponseCreateModel.fromJson(responseDecode);
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

  Future<FolioEntity> fetchFolio(String token) async {
    try {
      final url = Uri.parse('$defaultApiServer/Cotizaciones/folio');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final folio = response.body.trim();
        return FolioModel.fromResponse(folio);
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

  Future<QuotePdfEntity> generatePdf(int folio, String token) async {
    try {
      final uri = Uri.parse(
        '$defaultApiServer/Cotizaciones/$folio/generar-pdf',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8);

        return QuotePdfModel.fromJson(responseDecode);
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
