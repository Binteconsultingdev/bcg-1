import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/domain/repositories/client_repository.dart';

class FetchClientsUsecase {
  final ClientRepository clientRepository;
  FetchClientsUsecase({required this.clientRepository});
  Future<List<ClientEntity>> call() async {
    return await clientRepository.fetchClients();
  }
}