class ResponseValidateCartEntity {
  final List<ResponseItemValidateCartEntity> items;
  final double priceWithoutVAT;
  final double priceWithVAT;

  ResponseValidateCartEntity({
    required this.items,
    required this.priceWithoutVAT,
    required this.priceWithVAT,
  });
}
class ResponseItemValidateCartEntity {
  final int productid;
  final double newPrice;
  final double newTotal;
  

  ResponseItemValidateCartEntity({
    required this.productid,
    required this.newPrice,
    required this.newTotal,
  });
}