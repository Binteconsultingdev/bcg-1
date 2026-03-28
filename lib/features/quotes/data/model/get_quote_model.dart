import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';

class GetQuoteModel extends GetQuoteEntity {
  GetQuoteModel({
    required super.id,
    required super.folito,
    required super.date,
    required super.client,
    required super.total,
    required super.status,
    required super.seller,
    required super.reference,
    required super.quantityProducts,
  });

  factory GetQuoteModel.fromJson(Map<String, dynamic> json) {
    return GetQuoteModel(
      id: json['id'],
      folito: json['folio'],
      date: json['fecha'],
      client: json['cliente'],
      total: json['total'],
      status: json['status'],
      seller: json['vendedor'],
      reference: json['referencia'],
      quantityProducts: json['cantidadProductos'],
    );
  }
}
