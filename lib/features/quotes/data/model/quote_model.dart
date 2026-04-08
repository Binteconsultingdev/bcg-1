import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';

class QuoteModel extends QuoteEntity {
  QuoteModel({
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
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
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
      productos: (json['productos'] as List<dynamic>?)
              ?.map((e) => ProductoModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory QuoteModel.fromEntity(QuoteEntity entity) {
    return QuoteModel(
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
    return {
      'id': id,
      'folio': folio,
      'fecha': fecha,
      'cliente': cliente,
      'total': total,
      'status': status,
      'vendedor': vendedor,
      'cataPrecio': cataPrecio,
      'descuento': descuento,
      'iva': iva,
      'diasEnt': diasEnt,
      'comentarios': comentarios,
      'referencia': referencia,
      'attn': attn,
      'cantidadProductos': cantidadProductos,
      'productos': productos.map((e) => (e as ProductoModel).toJson()).toList(),
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
    super.iva,
    required super.claveSat,
    required super.url,
    required super.descuento,
    required super.prioridad,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      codigo: (json['codigo'] ?? '').toString().trim(),
      descripcion: (json['descripcion'] ?? '').toString().trim(),
      disponible: (json['disponible'] ?? 0).toDouble(),
      unidad: json['unidad'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      cantidad: (json['cantidad'] ?? 0).toDouble(),
      importe: (json['importe'] ?? 0).toDouble(),
      iva: json['iva'],
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