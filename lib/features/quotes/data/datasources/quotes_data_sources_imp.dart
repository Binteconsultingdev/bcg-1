import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/common/errors/api_errors.dart';
import 'package:bcg/features/quotes/data/model/folio_model.dart';
import 'package:bcg/features/quotes/data/model/get_quote_model.dart';
import 'package:bcg/features/Inventory/data/model/post_validate_cart_model.dart';
import 'package:bcg/features/quotes/data/model/quote_from_model.dart';
import 'package:bcg/features/quotes/data/model/quote_model.dart';
import 'package:bcg/features/quotes/data/model/quote_pdf_model.dart';
import 'package:bcg/features/quotes/data/model/response_create_model.dart';
import 'package:bcg/features/Inventory/data/model/response_validate_cart_model.dart';
import 'package:bcg/features/quotes/domain/entities/folito_entity.dart';
import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/post_validate_cart_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_from_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_pdf_entity.dart';
import 'package:bcg/features/quotes/domain/entities/response_create_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/response_validate_cart_entity.dart';
import 'package:http/http.dart' as http;

class QuotesDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  Future<List<GetQuoteEntity>> fetchQuote(
    String token,
    String client,
    String numParte,
    String status,
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
        'status': status,
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

  Future<void> updateQuote(String token, QuoteEntity entity, int id) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Cotizaciones/$id');

      final bodyRequest = QuoteModel.fromEntity(entity).toJson();
      final payload = jsonEncode(bodyRequest);

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: payload,
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

  Future<ResponseCreateEntity> createQuote(
    QuoteEntity entity,
    String token,
  ) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Cotizaciones');

      final bodyRequest = QuoteModel.fromEntity(entity).toJson();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyRequest),
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

  Future<ResponseCreateEntity> createQuotefrom(
    QuoteFromEntity entity,
    String token,
  ) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/Cotizaciones/form');

      final bodyRequest = QuoteFromModel.fromEntity(entity).toJson();

      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $token';

      bodyRequest.forEach((key, value) {
        if (value != null) {
          if (value is Map || value is List) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      if (entity.imagenes != null) {
        for (final entry in entity.imagenes!.entries) {
          final codigo = entry.key;
          final filePath = entry.value;

          final file = await http.MultipartFile.fromPath(
            'Imagenes[$codigo]',
            filePath,
            contentType: http.MediaType('image', 'jpeg'),
          );

          request.files.add(file);
        }
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataUTF8 = utf8.decode(response.bodyBytes);

        final responseDecode = jsonDecode(dataUTF8);

        return ResponseCreateModel.fromJson(responseDecode);
      }

      ApiExceptionCustom exception = ApiExceptionCustom(response: response);

      exception.validateMesage();
      throw exception;
    } catch (e, stack) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
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
