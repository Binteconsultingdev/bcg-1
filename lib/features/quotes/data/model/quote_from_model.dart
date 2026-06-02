import 'package:bcg/features/quotes/data/model/quote_model.dart'; 
import 'package:bcg/features/quotes/domain/entities/quote_from_entity.dart';

class QuoteFromModel extends QuoteFromEntity {
  QuoteFromModel({
    super.id,
    required super.folio,
    super.fecha,
    required super.cliente,
    required super.total,
    super.status,
    super.vendedor,
    required super.cataPrecio,
    required super.descuento,
    required super.iva,
    required super.diasEnt,
    required super.comentarios,
    required super.referencia,
    super.attn,
    super.cantidadProductos,
    required super.productos, 
    super.imagenes
  });

  factory QuoteFromModel.fromJson(Map<String, dynamic> json) {
    return QuoteFromModel(
      id: json['id'],
      folio: json['folio'] ?? '',
      fecha: json['fecha'],
      cliente: json['cliente'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'],
      vendedor: json['vendedor'],
      cataPrecio: json['cataPrecio'] ?? '',
      descuento: json['descuento'] ?? '',
      iva: json['iva'] ?? '',
      diasEnt: json['diasEnt'] ?? 0,
      comentarios: json['comentarios'] ?? '',
      referencia: json['referencia'] ?? '',
      attn: json['attn'],
      cantidadProductos: json['cantidadProductos'],
      productos: (json['ProductosJson'] as List<dynamic>?)
              ?.map((e) => ProductoModel.fromJson(e))
              .toList() ??
          [], 
    );
  }

  factory QuoteFromModel.fromEntity(QuoteFromEntity entity) {
    return QuoteFromModel(
      id: entity.id,
      folio: entity.folio,
      fecha: entity.fecha,
      cliente: entity.cliente,
      total: entity.total,
      status: entity.status,
      vendedor: entity.vendedor,
      cataPrecio: entity.cataPrecio,
      descuento: entity.descuento,
      iva: entity.iva,
      diasEnt: entity.diasEnt,
      comentarios: entity.comentarios,
      referencia: entity.referencia,
      attn: entity.attn,
      cantidadProductos: entity.cantidadProductos,
      productos:
          entity.productos.map((e) => ProductoModel.fromEntity(e)).toList(),
    
    );
  }

Map<String, dynamic> toJson() {
  final map = <String, dynamic>{
    'Folio': folio,
    'Cliente': cliente,
    'Total': total,
    'CataPrecio': cataPrecio,
    'Descuento': descuento,
    'IVA': iva,
    'DiasEnt': diasEnt,
    'ProductosJson': productos.map((e) => (e as ProductoModel).toJson()).toList(),
  };
 
  if (comentarios.trim().isNotEmpty) map['Comentarios'] = comentarios;
  if (referencia.trim().isNotEmpty) map['Referencia'] = referencia;
  if (id != null) map['id'] = id;
  if (fecha != null) map['Fecha'] = fecha;
  if (status != null) map['Status'] = status;
  if (vendedor != null) map['Vendedor'] = vendedor;
  if (attn != null) map['Attn'] = attn;
  if (cantidadProductos != null) map['CantidadProductos'] = cantidadProductos;

  return map;
}
}
