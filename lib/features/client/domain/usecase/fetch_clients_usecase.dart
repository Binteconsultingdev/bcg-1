import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/domain/repositories/client_repository.dart';

class FetchClientsUsecase {
  final ClientRepository clientRepository;
  FetchClientsUsecase({required this.clientRepository});
  Future<List<ClientEntity>> call(String client,String company,String rfc,String email,int page,int pageSize) async {
    return await clientRepository.fetchClients( client, company, rfc, email, page, pageSize);
  }
}