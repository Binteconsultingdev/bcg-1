class GetQuoteEntity {
  final int id;
  final String? folito;
  final String? date;
  final String? client;
  final num? total;
  final String? status;
  final String? seller;
  final String? reference;
  final int? quantityProducts; 
  GetQuoteEntity({
    required this.id,
     this.folito,
     this.date,
     this.client,
     this.total,
     this.status,
     this.seller,
     this.reference,
     this.quantityProducts,
  });
}