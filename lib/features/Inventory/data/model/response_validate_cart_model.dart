import 'package:bcg/features/Inventory/domain/entities/response_validate_cart_entity.dart';

class ResponseValidateCartModel extends ResponseValidateCartEntity {
  ResponseValidateCartModel({
    required super.items,
    required super.priceWithoutVAT,
    required super.priceWithVAT,
  });

  factory ResponseValidateCartModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseValidateCartModel(
      priceWithoutVAT:
          (json['precioSinIVA'] as num).toDouble(),
      priceWithVAT:
          (json['precioConIVA'] as num).toDouble(),
      items: (json['items'] as List)
          .map(
            (e) => ResponseItemValidateCartModel.fromJson(e),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'precioSinIVA': priceWithoutVAT,
      'precioConIVA': priceWithVAT,
      'items': items
          .map(
            (e) => {
              'productoId': e.productid,
              'nuevoPrecio': e.newPrice,
              'nuevoTotal': e.newTotal,
            },
          )
          .toList(),
    };
  }
}

class ResponseItemValidateCartModel
    extends ResponseItemValidateCartEntity {
  ResponseItemValidateCartModel({
    required super.productid,
    required super.newPrice,
    required super.newTotal,
  });

  factory ResponseItemValidateCartModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResponseItemValidateCartModel(
      productid: json['productoId'],
      newPrice:
          (json['nuevoPrecio'] as num).toDouble(),
      newTotal:
          (json['nuevoTotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productoId': productid,
      'nuevoPrecio': newPrice,
      'nuevoTotal': newTotal,
    };
  }
}