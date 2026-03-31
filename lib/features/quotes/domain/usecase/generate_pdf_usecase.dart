import 'package:bcg/features/quotes/domain/entities/quote_pdf_entity.dart';
import 'package:bcg/features/quotes/domain/repositories/quotes_repository.dart';

class GeneratePdfUsecase {
  final QuotesRepository quotesRepository;
  GeneratePdfUsecase({required this.quotesRepository});
    Future<QuotePdfEntity> call(int folio) async  {
    return await quotesRepository.generatePdf(folio);
  }
}