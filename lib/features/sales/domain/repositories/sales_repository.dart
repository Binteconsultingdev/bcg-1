import 'package:bcg/features/sales/domain/entities/create_sales_entity.dart';
import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';

abstract class SalesRepository {
  Future<List<PointSaleEntity>> pointSales(
    String startDate,
    String endDate,
    bool ignoreDates,
    String client,
    String statusPayment,
    String userToFilter,
  );
  Future<void>generateSales(CreateSalesEntity entity);
}
