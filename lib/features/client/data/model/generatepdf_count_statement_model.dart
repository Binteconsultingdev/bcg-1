import 'package:bcg/features/client/domain/entities/generatepdf_count_statement_entity.dart';

class GeneratepdfCountStatementModel  extends GeneratepdfCountStatementEntity {
  GeneratepdfCountStatementModel({required super.urlpdf, required super.generated});

  factory GeneratepdfCountStatementModel.fromJson(Map <String, dynamic> json) {
   return  GeneratepdfCountStatementModel(urlpdf: json['urlpdf'], generated: json['generado']);
  }
  
}