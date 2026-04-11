
import 'package:bcg/features/sales/domain/entities/sales_pdf_entity.dart';

class SalesPdfModel extends SalesPdfEntity {
  SalesPdfModel({required super.urlpdf, required super.generated});
  
  factory SalesPdfModel.fromJson(Map <String, dynamic> json) {
   return  SalesPdfModel(urlpdf: json['urlpdf'], generated: json['generado']);
  }
}