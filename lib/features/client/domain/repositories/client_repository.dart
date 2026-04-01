import 'package:bcg/features/client/domain/entities/client_entity.dart';

abstract class ClientRepository {
  Future<void> createClient(ClientEntity entity);
  Future<List<ClientEntity>> fetchClients(String client,String company,String rfc,String email,int page,int pageSize);
}