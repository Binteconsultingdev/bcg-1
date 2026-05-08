import 'package:bcg/features/client/domain/entities/account_statement_entity.dart';
import 'package:bcg/features/client/domain/entities/generatepdf_count_statement_entity.dart';
import 'package:bcg/features/client/domain/repositories/client_repository.dart';

class GenerateAccountStatementUsecase {
  final ClientRepository clientRepository;

  GenerateAccountStatementUsecase({ required this.clientRepository});

  Future<GeneratepdfCountStatementEntity> call(AccountStatementEntity entity) async {
    return await clientRepository.generateAccountStatement(entity);
  }
}