import 'package:bcg/features/sales/domain/entities/sales_pdf_entity.dart';
import 'package:bcg/features/sales/domain/repositories/sales_repository.dart';

class GeneratePdfSales {
  final SalesRepository salesRepository;
  GeneratePdfSales({required this.salesRepository});
  Future<SalesPdfEntity> call(int saleId) async {
    return await salesRepository.generatepdfSales(saleId);
  }
}