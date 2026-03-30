import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/domain/repositories/client_repository.dart';

class CreateClientUsecase {
  final ClientRepository clientRepository;
  CreateClientUsecase({required this.clientRepository});
  Future<void> call(ClientEntity entity) async {
    return await clientRepository.createClient(entity);
  }
}