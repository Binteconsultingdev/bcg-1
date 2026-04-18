import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/common/errors/api_errors.dart';
import 'package:bcg/features/sales/data/model/create_sales_model.dart';
import 'package:bcg/features/sales/data/model/point_sale_model.dart';
import 'package:bcg/features/sales/data/model/response_create_sales_model.dart';
import 'package:bcg/features/sales/data/model/sales_pdf_model.dart';
import 'package:bcg/features/sales/domain/entities/create_sales_entity.dart';
import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';
import 'package:bcg/features/sales/domain/entities/response_create_sales_entity.dart';
import 'package:bcg/features/sales/domain/entities/sales_pdf_entity.dart';
import 'package:http/http.dart' as http;

class SalesDataSourcesImp {
  String defaultApiServer = AppConstants.serverBase;
  Future<List<PointSaleEntity>> fetchQuote(
    String token,
    String status,
    String startDate,
    String endDate,
    bool ignoreDates,
    String client,
    String statusPayment,
    String userToFilter,
    int page,
    int pageSize, {
    String? folio,
    String? id,
  }) async {
    try {
      final queryParams = {
          'status': status,
        'FechaInicio': startDate,
        'FechaFin': endDate,
        'IgnorarFechas': ignoreDates.toString(),
        'Cliente': client,
        'StatusPago': statusPayment,
        'UsuarioAFiltrar': userToFilter,
        'pagina': page.toString(),
        'tamanoPagina': pageSize.toString(),
        if (folio != null && folio.isNotEmpty) 'Folio': folio,
        if (id != null) 'Id': id.toString(),
      };

      Uri url = Uri.parse(
        '$defaultApiServer/VentaSalida/filtrar',
      ).replace(queryParameters: queryParams);
      print(url);
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
            .map((json) => PointSaleModel.fromJson(json))
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
  
  
  Future<ResponseCreateSalesEntity> generateSales(CreateSalesEntity entity, String token) async {
  try {
    Uri url = Uri.parse('$defaultApiServer/VentaSalida/generar');

    final payload = jsonEncode(CreateSalesModel.fromEntity(entity).toJson());

    print('🚀 Iniciando generateSales');
    print('🌐 URL: $url');
    print('📦 Payload: $payload');
    print('🔑 Token: $token');

    final response = await http.post(
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
  final dataUTF8 = utf8.decode(response.bodyBytes);
  final responseDecode = jsonDecode(dataUTF8);

  // ← Verifica success antes de retornar
  if (responseDecode['success'] == false) {
    final message = responseDecode['message'] ?? 'Error desconocido';
    throw Exception(message);
  }

  return ResponseCreateSalesModel.fromJson(responseDecode);
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
      print('🌐 Error de red');
      throw Exception(convertMessageException(error: e));
    }

    throw Exception('$e');
  }
}



  Future<SalesPdfEntity> generatePdf(int folio, String token) async {
    try {
      final uri = Uri.parse(
        '$defaultApiServer/VentaSalida/$folio/generar-pdf',
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

        return SalesPdfModel.fromJson(responseDecode);
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
