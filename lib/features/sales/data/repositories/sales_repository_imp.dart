import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/features/sales/data/datasources/sales_data_sources_imp.dart';
import 'package:bcg/features/sales/domain/entities/create_sales_entity.dart';
import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';
import 'package:bcg/features/sales/domain/repositories/sales_repository.dart';

class SalesRepositoryImp extends SalesRepository {
  final SalesDataSourcesImp salesDataSourcesImp;
  AuthService authService = AuthService();
  SalesRepositoryImp({required this.salesDataSourcesImp});
  @override
  Future<List<PointSaleEntity>> pointSales(String startDate, String endDate, bool ignoreDates, String client, String statusPayment, String userToFilter) async {
    final token = await authService.getToken() ?? (throw ('No hay sesión activa. El usuario debe iniciar sesión.'));
   return await salesDataSourcesImp.fetchQuote(token, startDate, endDate, ignoreDates, client, statusPayment, userToFilter);
  }

  @override
  Future<void> generateSales(CreateSalesEntity entity) {
    // TODO: implement generateSales
    throw UnimplementedError();
  }
}