import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/repositories/quotes_repository.dart';

class FetchQuotesByidUsecase {
  final QuotesRepository quotesRepository;

  FetchQuotesByidUsecase({ required this.quotesRepository});
  Future<QuoteEntity> call(int id) async {
    return await quotesRepository.fetchQuotebyid(id);
  }
}