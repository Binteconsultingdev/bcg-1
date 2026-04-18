class CreateSalesEntity {
  final int numCliente;
  final String cliente;
  final String vendedor;
  final String user;
  final String metodoEmb;
  final String comentarios;
  final String refe;
  final DateTime fechaEntrega;
 
  final bool incIVA;
  final String folioPre;
  final double descuento;
  final List<PartidaEntity> partidas;

  CreateSalesEntity({
    required this.numCliente,
    required this.cliente,
    required this.vendedor,
    required this.user,
    required this.metodoEmb,
    required this.comentarios,
    required this.refe,
    required this.fechaEntrega,
 
    required this.incIVA,
    required this.folioPre,
    required this.descuento,
    required this.partidas,
  });
}

class PartidaEntity {
  final String numParte;
  final String descripcion;
  final double cantidad;
  final double precio;
  final String claveSat;
  final String um;

  PartidaEntity({
    required this.numParte,
    required this.descripcion,
    required this.cantidad,
    required this.precio,
    required this.claveSat,
    required this.um,
  });
}