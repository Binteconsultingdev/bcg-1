import 'package:bcg/features/sales/domain/entities/create_sales_entity.dart';

class CreateSalesModel extends CreateSalesEntity {
  CreateSalesModel({
    required super.numCliente,
    required super.cliente,
    required super.vendedor,
    required super.user,
    required super.metodoEmb,
    required super.comentarios,
    required super.refe,
    required super.fechaEntrega, 
    required super.incIVA,
    required super.folioPre,
    required super.descuento,
    required super.partidas,
  });

  factory CreateSalesModel.fromJson(Map<String, dynamic> json) {
    return CreateSalesModel(
      numCliente: json['numCliente'] ?? 0,
      cliente: json['cliente'] ?? '',
      vendedor: json['vendedor'] ?? '',
      user: json['user'] ?? '',
      metodoEmb: json['metodoEmb'] ?? '',
      comentarios: json['comentarios'] ?? '',
      refe: json['refe'] ?? '',
      fechaEntrega: DateTime.parse(json['fecha_Entrega']), 
      incIVA: json['incIVA'] ?? false,
      folioPre: json['folio_Pre'] ?? '',
      descuento: (json['descuento'] ?? 0).toDouble(),
      partidas: (json['partidas'] as List<dynamic>)
          .map((e) => PartidaModel.fromJson(e))
          .toList(),
    );
  }
factory CreateSalesModel.fromEntity(CreateSalesEntity entity) {
  return CreateSalesModel(
    numCliente: entity.numCliente,
    cliente: entity.cliente,
    vendedor: entity.vendedor,
    user: entity.user,
    metodoEmb: entity.metodoEmb,
    comentarios: entity.comentarios,
    refe: entity.refe,
    fechaEntrega: entity.fechaEntrega,
    
    incIVA: entity.incIVA,
    folioPre: entity.folioPre,
    descuento: entity.descuento,
    // ✅ Convierte cada PartidaEntity a PartidaModel aquí
    partidas: entity.partidas
        .map((p) => PartidaModel(
              numParte: p.numParte,
              descripcion: p.descripcion,
              cantidad: p.cantidad,
              precio: p.precio,
              claveSat: p.claveSat,
              um: p.um,
            ))
        .toList(),
  );
}
  Map<String, dynamic> toJson() {
    return {
      "numCliente": numCliente,
      "cliente": cliente,
      "vendedor": vendedor,
      "user": user,
      "metodoEmb": metodoEmb,
      "comentarios": comentarios,
      "refe": refe,
      "fecha_Entrega": fechaEntrega.toIso8601String(),
      
      "incIVA": incIVA,
      "folio_Pre": folioPre,
      "descuento": descuento,
      "partidas": partidas.map((e) => (e as PartidaModel).toJson()).toList(),
    };
  }
}

class PartidaModel extends PartidaEntity {
  PartidaModel({
    required super.numParte,
    required super.descripcion,
    required super.cantidad,
    required super.precio,
    required super.claveSat,
    required super.um,
  });

  factory PartidaModel.fromJson(Map<String, dynamic> json) {
    return PartidaModel(
      numParte: json['numParte'] ?? '',
      descripcion: json['descripcion'] ?? '',
      cantidad: (json['cantidad'] ?? 0).toDouble(),
      precio: (json['precio'] ?? 0).toDouble(),
      claveSat: json['clave_Sat'] ?? '',
      um: json['um'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "numParte": numParte,
      "descripcion": descripcion,
      "cantidad": cantidad,
      "precio": precio,
      "clave_Sat": claveSat,
      "um": um,
    };
  }
}
