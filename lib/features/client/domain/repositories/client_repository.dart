import 'package:bcg/features/client/domain/entities/client_entity.dart';

abstract class ClientRepository {
  Future<void> createClient();
  Future<List<ClientEntity>> fetchClients();
}