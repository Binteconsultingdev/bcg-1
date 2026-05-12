class QuoteEntity {
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

  QuoteEntity({
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
  });
}
class ProductoEntity {
  final int? id;
  final String codigo;
  final String descripcion;
  final num disponible;
  final String unidad;
  final double precio;
  final double cantidad;  
  final double importe;
  final String claveSat;
  final String url;
  final double descuento;  
  final int prioridad;

  final String? iva;
  ProductoEntity({
      this.id,
    required this.codigo,
    this.iva,
    required this.descripcion,
    required this.disponible,
    required this.unidad,
    required this.precio,
    required this.cantidad,
    required this.importe,
    required this.claveSat,
    required this.url,
    required this.descuento,
    required this.prioridad,
  });
}