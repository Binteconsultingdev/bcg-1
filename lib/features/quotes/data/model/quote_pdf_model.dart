import '../../domain/entities/quote_pdf_entity.dart';

class QuotePdfModel extends QuotePdfEntity {
  QuotePdfModel({required super.bytes});

  factory QuotePdfModel.fromBytes(List<int> bytes) {
    return QuotePdfModel(bytes: bytes);
  }
}