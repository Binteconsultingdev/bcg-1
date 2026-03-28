class QuoteEntity {
  final String folio;
  final String cliente;
  final double total;
  final String cataPrecio;
  final String descuento;
  final String iva;
  final int diasEnt;
  final String comentarios;
  final String referencia;
  final List<ProductoEntity> productos;

  QuoteEntity({
    required this.folio,
    required this.cliente,
    required this.total,
    required this.cataPrecio,
    required this.descuento,
    required this.iva,
    required this.diasEnt,
    required this.comentarios,
    required this.referencia,
    required this.productos,
  });


}

class ProductoEntity {
  final String codigo;
  final String descripcion;
  final int disponible;
  final String unidad;
  final double precio;
  final int cantidad;
  final double importe;
  final String iva;
  final String claveSat;
  final String url;
  final double descuento;
  final int prioridad;

  ProductoEntity({
    required this.codigo,
    required this.descripcion,
    required this.disponible,
    required this.unidad,
    required this.precio,
    required this.cantidad,
    required this.importe,
    required this.iva,
    required this.claveSat,
    required this.url,
    required this.descuento,
    required this.prioridad,
  });
}