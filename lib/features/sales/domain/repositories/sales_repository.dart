import 'package:bcg/features/sales/domain/entities/create_sales_entity.dart';
import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';
import 'package:bcg/features/sales/domain/entities/response_create_sales_entity.dart';
import 'package:bcg/features/sales/domain/entities/sales_pdf_entity.dart';

abstract class SalesRepository {
  Future<List<PointSaleEntity>> pointSales(
    String status,
   String startDate,
  String endDate,
  bool ignoreDates,
  String client,
  String statusPayment,
  String userToFilter,
  int page,
  int pageSize, {
  String? folio,
  String? id,
}
  );
  Future<ResponseCreateSalesEntity>generateSales(CreateSalesEntity entity);

  Future<SalesPdfEntity> generatepdfSales(int saleId);
}
