import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/features/client/data/datasources/client_data_sources_imp.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/domain/entities/create_client_entity.dart';
import 'package:bcg/features/client/domain/repositories/client_repository.dart';

class ClientRepositoryImp extends ClientRepository {
  final ClientDataSourcesImp clientDataSourcesImp;
  AuthService authService = AuthService();
  ClientRepositoryImp({required this.clientDataSourcesImp});
  @override
  Future<void> createClient(CreateClientEntity entity) async {
    final token =
        await authService.getToken() ??
        (throw ('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await clientDataSourcesImp.createClient(entity, token);
  }

  @override
  Future<List<ClientEntity>> fetchClients(String client,String company,String rfc,String email,int page,int pageSize) async {
    final token =
        await authService.getToken() ??
        (throw ('No hay sesión activa. El usuario debe iniciar sesión.'));
    return await clientDataSourcesImp.fetchClients(token, client, company, rfc, email, page, pageSize);
  }
}
