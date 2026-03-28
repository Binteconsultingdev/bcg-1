import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';

class QuoteModel extends QuoteEntity {
  QuoteModel({
    required super.folio,
    required super.cliente,
    required super.total,
    required super.cataPrecio,
    required super.descuento,
    required super.iva,
    required super.diasEnt,
    required super.comentarios,
    required super.referencia,
    required super.productos,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      folio: json['folio'] ?? '',
      cliente: json['cliente'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      cataPrecio: json['cataPrecio'] ?? '',
      descuento: json['descuento'] ?? '',
      iva: json['iva'] ?? '',
      diasEnt: json['diasEnt'] ?? 0,
      comentarios: json['comentarios'] ?? '',
      referencia: json['referencia'] ?? '',
      productos: (json['productos'] as List<dynamic>?)
              ?.map((e) => ProductoModel.fromJson(e))
              .toList() ??
          [],
    );
  }
  factory QuoteModel.fromEntity(QuoteEntity entity) {
    return QuoteModel(
      folio: entity.folio,
      cliente: entity.cliente,
      total: entity.total,
      cataPrecio: entity.cataPrecio,
      descuento: entity.descuento,
      iva: entity.iva,
      diasEnt: entity.diasEnt,
      comentarios: entity.comentarios,
      referencia: entity.referencia,
      productos:
          entity.productos.map((e) => ProductoModel.fromEntity(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folio': folio,
      'cliente': cliente,
      'total': total,
      'cataPrecio': cataPrecio,
      'descuento': descuento,
      'iva': iva,
      'diasEnt': diasEnt,
      'comentarios': comentarios,
      'referencia': referencia,
      'productos':
          productos.map((e) => (e as ProductoModel).toJson()).toList(),
    };
  }
}

class ProductoModel extends ProductoEntity {
  ProductoModel({
    required super.codigo,
    required super.descripcion,
    required super.disponible,
    required super.unidad,
    required super.precio,
    required super.cantidad,
    required super.importe,
    required super.iva,
    required super.claveSat,
    required super.url,
    required super.descuento,
    required super.prioridad,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      codigo: json['codigo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      disponible: json['disponible'] ?? 0,
      unidad: json['unidad'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      cantidad: json['cantidad'] ?? 0,
      importe: (json['importe'] ?? 0).toDouble(),
      iva: json['iva'] ?? '',
      claveSat: json['clave_Sat'] ?? '',
      url: json['url'] ?? '',
      descuento: (json['descuento'] ?? 0).toDouble(),
      prioridad: json['prioridad'] ?? 0,
    );
  }
  factory ProductoModel.fromEntity(ProductoEntity entity) {
    return ProductoModel(
      codigo: entity.codigo,
      descripcion: entity.descripcion,
      disponible: entity.disponible,
      unidad: entity.unidad,
      precio: entity.precio,
      cantidad: entity.cantidad,
      importe: entity.importe,
      iva: entity.iva,
      claveSat: entity.claveSat,
      url: entity.url,
      descuento: entity.descuento,
      prioridad: entity.prioridad,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'descripcion': descripcion,
      'disponible': disponible,
      'unidad': unidad,
      'precio': precio,
      'cantidad': cantidad,
      'importe': importe,
      'iva': iva,
      'clave_Sat': claveSat,
      'url': url,
      'descuento': descuento,
      'prioridad': prioridad,
    };
  }
}