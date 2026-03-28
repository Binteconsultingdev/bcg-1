import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';

class PointSaleModel extends PointSaleEntity {
  PointSaleModel({required super.id, required super.folito, required super.date, required super.client, required super.total, required super.status});

 
  factory PointSaleModel.fromJson(Map<String, dynamic> json) {
    return PointSaleModel(
      id: json['id'],
      folito: json['folio'],
      date: json['fecha'],
      client: json['cliente'],
      total: json['total'],
      status: json['status'],
    );
  }
}