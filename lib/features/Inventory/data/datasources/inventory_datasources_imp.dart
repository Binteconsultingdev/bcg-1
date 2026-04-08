import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/common/errors/api_errors.dart';
import 'package:bcg/features/Inventory/data/model/inventory_category_model.dart';
import 'package:bcg/features/Inventory/data/model/inventory_model.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_category_entity.dart';
import 'package:bcg/features/Inventory/domain/entities/inventory_entity.dart';
import 'package:http/http.dart' as http;

class InventoryDatasourcesImp {
  String defaultApiServer = AppConstants.serverBase;

  Future<List<InventoryCategoryEntity>> fetchFamilias(String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/inventario/familias');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8) as List;
        return responseDecode
            .map((json) => InventoryCategoryModel.fromJson(json))
            .toList();
      }
      throw ApiExceptionCustom(response: response);
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }

  Future<List<InventoryEntity>> fetchInventario(String token,String description,String numparte,
    String familia,
    String subfamilia,int page,int pageSize) async {
    try {
      Uri url = Uri.parse(
        '$defaultApiServer/inventario/buscar?familia=$familia&descripcion=$description&numparte=$numparte&subfamilia=$subfamilia&pagina=$page&tamanoPagina=$pageSize',
      );
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json' , 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8) as List;
        return responseDecode
            .map((json) => InventoryModel.fromJson(json))
            .toList();
      }
      throw ApiExceptionCustom(response: response);
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }

  Future<List<InventoryCategoryEntity>> fetchSubfamilias(String token) async {
    try {
      Uri url = Uri.parse('$defaultApiServer/inventario/subfamilias');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final dataUTF8 = utf8.decode(response.bodyBytes);
        final responseDecode = jsonDecode(dataUTF8) as List;
        return responseDecode
            .map((json) => InventoryCategoryModel.fromJson(json))
            .toList();
      }
      throw ApiExceptionCustom(response: response);
    } catch (e) {
      if (e is SocketException ||
          e is http.ClientException ||
          e is TimeoutException) {
        throw Exception(convertMessageException(error: e));
      }
      throw Exception('$e');
    }
  }
}
