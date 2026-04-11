import 'package:bcg/features/sales/domain/entities/response_create_sales_entity.dart';

class ResponseCreateSalesModel  extends ResponseCreateSalesEntity{
  ResponseCreateSalesModel({required super.saleId, super.message  });
  factory ResponseCreateSalesModel.fromJson(Map<String, dynamic> json) {
    return ResponseCreateSalesModel(
      saleId: json['ventaId'],
      message: json['message'],
    );
  }
}