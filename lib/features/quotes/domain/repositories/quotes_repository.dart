import 'package:bcg/features/quotes/domain/entities/folito_entity.dart';
import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';

abstract class QuotesRepository {
  Future<List<GetQuoteEntity>> fetchQuote(String client,int numParte,String dateFrom,String dateUntil);
  Future<void> createQuote(QuoteEntity entity);
  Future<FolioEntity> getfolio();

}