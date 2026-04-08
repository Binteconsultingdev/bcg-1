import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/repositories/quotes_repository.dart';

class PutQuotesUsecase {
  final QuotesRepository quotesRepository;

  PutQuotesUsecase({ required this.quotesRepository});
  Future<void> call(int id, QuoteEntity entity) async {
    return await quotesRepository.putQuotebyid(id, entity);
  }
}