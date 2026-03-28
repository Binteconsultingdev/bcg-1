import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/common/errors/api_errors.dart';
import 'package:bcg/features/sales/data/model/point_sale_model.dart';
import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';
import 'package:http/http.dart' as http;
class SalesDataSourcesImp  {
  String defaultApiServer = AppConstants.serverBase;

Future<List<PointSaleEntity>> fetchQuote(
    String token,
    String startDate,
    String endDate,
    bool ignoreDates,
    String client,
    String statusPayment,
    String userToFilter
    ) async {
  try {
    Uri url = Uri.parse(
        '$defaultApiServer/VentaSalida/filtrar?FechaInicio=$startDate&FechaFin=$endDate&IgnorarFechas=$ignoreDates&Cliente=$client&StatusPago=$statusPayment&UsuarioAFiltrar=$userToFilter');


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
}