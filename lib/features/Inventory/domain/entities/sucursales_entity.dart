class SucursalesEntity {
  final String numParte;
  final String descripcion;
  final String unidad;
  final double totalDisponible;
  final List<ProductoResponseDto> productoResposeDtos;

  SucursalesEntity({
    required this.numParte,
    required this.descripcion,
    required this.unidad,
    required this.totalDisponible,
    required this.productoResposeDtos,
  });
 
}

class ProductoResponseDto {
  final int id;
  final double disponible;
  final double precio;
  final String sucursal;

  ProductoResponseDto({
    required this.id,
    required this.disponible,
    required this.precio,
    required this.sucursal,
  });
 
}