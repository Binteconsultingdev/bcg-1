import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/response_create_entity.dart';
import 'package:bcg/features/quotes/domain/repositories/quotes_repository.dart';

class CreateQuotesUsecase {
  final QuotesRepository quotesRepository;
  CreateQuotesUsecase({required this.quotesRepository});
  Future<ResponseCreateEntity> call(QuoteEntity entity) async {
    return await quotesRepository.createQuote(entity);
  }
}
