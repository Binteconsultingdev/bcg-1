import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/domain/entities/create_client_entity.dart';

abstract class ClientRepository {
  Future<void> createClient(CreateClientEntity entity);
  Future<List<ClientEntity>> fetchClients(String client,String company,String rfc,String email,int page,int pageSize);
}