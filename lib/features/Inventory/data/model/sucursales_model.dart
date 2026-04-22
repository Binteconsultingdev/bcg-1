import 'package:bcg/features/Inventory/domain/entities/sucursales_entity.dart';

class SucursalesModel extends SucursalesEntity {
  SucursalesModel({
    required super.numParte,
    required super.descripcion,
    required super.unidad,
    required super.totalDisponible,
    required super.productoResposeDtos,
  });

  factory SucursalesModel.fromJson(Map<String, dynamic> json) {
    return SucursalesModel(
      numParte: json['numParte'],
      descripcion: json['descripcion'],
      unidad: json['unidad'],
      totalDisponible: (json['totalDisponible'] as num).toDouble(),
      productoResposeDtos: (json['productoResposeDtos'] as List)
          .map((e) => ProductoResponseDtoModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numParte': numParte,
      'descripcion': descripcion,
      'unidad': unidad,
      'totalDisponible': totalDisponible,
      'productoResposeDtos':
          productoResposeDtos.map((e) => (e as ProductoResponseDtoModel).toJson()).toList(),
    };
  }
}
class ProductoResponseDtoModel extends ProductoResponseDto {
  ProductoResponseDtoModel({
    required super.id,
    required super.disponible,
    required super.precio,
    required super.sucursal,
  });

  factory ProductoResponseDtoModel.fromJson(Map<String, dynamic> json) {
    return ProductoResponseDtoModel(
      id: json['id'],
      disponible: (json['disponible'] as num).toDouble(),
      precio: (json['precio'] as num).toDouble(),
      sucursal: json['sucursal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disponible': disponible,
      'precio': precio,
      'sucursal': sucursal,
    };
  }
}