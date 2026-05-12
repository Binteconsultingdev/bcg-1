class PostValidateCartEntity {
  final List<PostItemValidateCartEntity> items;
  final String pricetype;

  PostValidateCartEntity({
    required this.items,
    required this.pricetype,
  });
}

class PostItemValidateCartEntity {
  final int productid;
  final int quantity;

  PostItemValidateCartEntity({
    required this.productid,
    required this.quantity,
  });
}