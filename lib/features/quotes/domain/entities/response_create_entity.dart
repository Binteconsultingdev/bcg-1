class ResponseCreateEntity {
   final int id;
  final String? folio;
  final DateTime? fecha;
  final String? cliente;
  final double? total;
  final String? status;
  final String? vendedor;
  final String? referencia;
  final int? cantidadProductos;

  ResponseCreateEntity({
    required this.id,
     this.folio,
     this.fecha,
     this.cliente,
     this.total,
     this.status,
     this.vendedor,
     this.referencia,
     this.cantidadProductos,
  });
}