import 'package:bcg/features/quotes/domain/entities/folito_entity.dart';
import 'package:bcg/features/quotes/domain/repositories/quotes_repository.dart';

class FetchFolioUsecase {
  final QuotesRepository quotesRepository;
  FetchFolioUsecase({required this.quotesRepository});
  Future<FolioEntity> call() async {
    return await quotesRepository.getfolio();
  }
}
