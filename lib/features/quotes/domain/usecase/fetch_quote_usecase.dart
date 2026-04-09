import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/domain/repositories/quotes_repository.dart';

class FetchQuoteUsecase {
  final QuotesRepository quotesRepository;
  FetchQuoteUsecase({required this.quotesRepository});
  Future <List<GetQuoteEntity>> cal(String client,String numParte,String dateFrom,String dateUntil,int page, int pageSize,{
  String? folio,
  String? id,
}) async {
    return await quotesRepository.fetchQuote(client,numParte,dateFrom,dateUntil,page,pageSize,  folio: folio,
    id: id,);
  }
}