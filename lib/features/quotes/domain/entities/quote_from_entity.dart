import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';

class QuoteFromEntity {
  final int? id;
  final String folio;
  final String? fecha;
  final String cliente;
  final double total;
  final String? status;
  final String? vendedor;
  final String cataPrecio;
  final String descuento;
  final String iva;
  final int diasEnt;
  final String comentarios;
  final String referencia;
  final String? attn;
  final int? cantidadProductos;
 
  final List<ProductoEntity> productos;
final Map<String, String>? imagenes;
  QuoteFromEntity({
     this.id,
    required this.folio,
     this.fecha,
    required this.cliente,
    required this.total,
     this.status,
     this.vendedor,
    required this.cataPrecio,
    required this.descuento,
    required this.iva,
    required this.diasEnt,
    required this.comentarios,
    required this.referencia,
     this.attn,
     this.cantidadProductos,
    required this.productos,
    this.imagenes,
  });
}