import 'package:bcg/features/sales/domain/entities/point_sale_entity.dart';
import 'package:bcg/features/sales/domain/repositories/sales_repository.dart';

class PointSalesUsecase {
  final SalesRepository salesRepository;
  PointSalesUsecase({required this.salesRepository});
  Future<List<PointSaleEntity>> call(  String startDate,
  String endDate,
  bool ignoreDates,
  String client,
  String statusPayment,
  String userToFilter,
  int page,
  int pageSize, {
  String? folio,
  String? id,
}) async {
    return await salesRepository.pointSales( startDate, endDate, ignoreDates, client, statusPayment, userToFilter, page, pageSize,
    folio: folio,
    id: id,);
  }
}