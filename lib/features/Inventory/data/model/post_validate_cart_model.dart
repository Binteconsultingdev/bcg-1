import 'package:bcg/features/Inventory/domain/entities/post_validate_cart_entity.dart';

class PostValidateCartModel extends PostValidateCartEntity {
  PostValidateCartModel({
    required super.items,
    required super.pricetype,
  });

  factory PostValidateCartModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PostValidateCartModel(
      pricetype: json['tipoPrecio'],
      items: (json['items'] as List)
          .map(
            (e) => PostItemValidateCartModel.fromJson(e),
          )
          .toList(),
    );
  }
  factory PostValidateCartModel.fromEntity(PostValidateCartEntity entity) {
    return PostValidateCartModel(
      pricetype: entity.pricetype,
      items: entity.items
          .map((e) => PostItemValidateCartModel(
                productid: e.productid,
                quantity: e.quantity,
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipoPrecio': pricetype,
      'items': items
          .map(
            (e) => {
              'productoId': e.productid,
              'cantidad': e.quantity,
            },
          )
          .toList(),
    };
  }
}

class PostItemValidateCartModel
    extends PostItemValidateCartEntity {
  PostItemValidateCartModel({
    required super.productid,
    required super.quantity,
  });

  factory PostItemValidateCartModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PostItemValidateCartModel(
      productid: json['productoId'],
      quantity: json['cantidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productoId': productid,
      'cantidad': quantity,
    };
  }
}