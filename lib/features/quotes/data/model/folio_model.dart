import 'package:bcg/features/quotes/domain/entities/folito_entity.dart';

class FolioModel extends FolioEntity {
  FolioModel({required String folio}) : super(folio: folio);

  factory FolioModel.fromResponse(String response) {
    return FolioModel(folio: response);
  }
}