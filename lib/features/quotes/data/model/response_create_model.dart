import 'package:bcg/features/quotes/domain/entities/response_create_entity.dart';

class ResponseCreateModel extends ResponseCreateEntity {
  ResponseCreateModel({
    required super.id,
    required super.folio,
    required super.fecha,
    required super.cliente,
    required super.total,
    required super.status,
    required super.vendedor,
    required super.referencia,
    required super.cantidadProductos,
  });

  factory ResponseCreateModel.fromJson(Map<String, dynamic> json) {
    return ResponseCreateModel(
      id: json['id'] ?? 0,
      folio: json['folio'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      cliente: json['cliente'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      vendedor: json['vendedor'] ?? '',
      referencia: json['referencia'] ?? '',
      cantidadProductos: json['cantidadProductos'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "folio": folio,
      "fecha": fecha,
      "cliente": cliente,
      "total": total,
      "status": status,
      "vendedor": vendedor,
      "referencia": referencia,
      "cantidadProductos": cantidadProductos,
    };
  }
}