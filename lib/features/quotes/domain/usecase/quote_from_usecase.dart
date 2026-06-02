import 'package:bcg/features/quotes/domain/entities/quote_from_entity.dart';
import 'package:bcg/features/quotes/domain/entities/response_create_entity.dart';
import 'package:bcg/features/quotes/domain/repositories/quotes_repository.dart';

class QuoteFromUsecase {
  final QuotesRepository quotesRepository;
  QuoteFromUsecase({ required this.quotesRepository});
   Future<ResponseCreateEntity> call(QuoteFromEntity entity) async {
    return await quotesRepository.createQuotefrom(entity);
  }
}