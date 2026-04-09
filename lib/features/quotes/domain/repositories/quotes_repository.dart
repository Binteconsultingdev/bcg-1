import 'package:bcg/features/quotes/domain/entities/folito_entity.dart';
import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_pdf_entity.dart';
import 'package:bcg/features/quotes/domain/entities/response_create_entity.dart';

abstract class QuotesRepository {
  Future<List<GetQuoteEntity>> fetchQuote(String client,String numParte,String dateFrom,String dateUntil,int page,int pageSize, {
  String? folio,
  String? id,
});
  Future<void> putQuotebyid(int id,QuoteEntity entity);
  Future<QuoteEntity> fetchQuotebyid(int id);
  Future<ResponseCreateEntity> createQuote(QuoteEntity entity);
  Future<FolioEntity> getfolio();
  Future<QuotePdfEntity> generatePdf(int folio);

}