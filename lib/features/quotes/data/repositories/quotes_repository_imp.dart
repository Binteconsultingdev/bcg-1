import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/features/quotes/data/datasources/quotes_data_sources_imp.dart';
import 'package:bcg/features/quotes/domain/entities/folito_entity.dart';
import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_entity.dart';
import 'package:bcg/features/quotes/domain/entities/quote_pdf_entity.dart';
import 'package:bcg/features/quotes/domain/entities/response_create_entity.dart';
import 'package:bcg/features/quotes/domain/repositories/quotes_repository.dart';

class QuotesRepositoryImp implements QuotesRepository {
  final QuotesDataSourcesImp quotesDataSourcesImp;
  AuthService authService = AuthService();
  QuotesRepositoryImp({required this.quotesDataSourcesImp});
  @override
  Future<ResponseCreateEntity> createQuote(QuoteEntity entity) async {
    final token =
        await authService.getToken() ??
        (throw ('No hay sesión activa. El usuario debe iniciar sesión.'));

    return quotesDataSourcesImp.createQuote(entity, token);
  }

  @override
  Future<List<GetQuoteEntity>> fetchQuote(
    String client,
    String numParte,
    String dateFrom,
    String dateUntil,
    int page,
    int pageSize,{
  String? folio,
  int? id,
}) async {
    final token =
        await authService.getToken() ??
        (throw ('No hay sesión activa. El usuario debe iniciar sesión.'));
    return quotesDataSourcesImp.fetchQuote(
      token,
      client,
      numParte,
      dateFrom,
      dateUntil,
      page,
    pageSize,
    folio: folio,
    id: id,
    );
  }

  @override
  Future<FolioEntity> getfolio() async {
    final token =
        await authService.getToken() ??
        (throw ('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await quotesDataSourcesImp.fetchFolio(token);
  }

  @override
  Future<QuotePdfEntity> generatePdf(int folio) async {
    final token =
        await authService.getToken() ??
        (throw ('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await quotesDataSourcesImp.generatePdf(folio, token);
  }
  
  @override
  Future<GetQuoteEntity> fetchQuotebyid(int id) async {
    final token =
        await authService.getToken() ??
        (throw ('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await quotesDataSourcesImp.fetchQuotebyid(token, id);
  }
}
