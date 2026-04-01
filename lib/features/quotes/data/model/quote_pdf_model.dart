

import 'package:bcg/features/quotes/domain/entities/quote_pdf_entity.dart';

class QuotePdfModel extends QuotePdfEntity {
  QuotePdfModel({required super.urlpdf, required super.generated});
  
  factory QuotePdfModel.fromJson(Map <String, dynamic> json) {
   return  QuotePdfModel(urlpdf: json['urlpdf'], generated: json['generado']);
  }
}