import 'package:bcg/features/sales/domain/entities/create_sales_entity.dart';
import 'package:bcg/features/sales/domain/repositories/sales_repository.dart';

class GenerateSalesUsecase {
  final SalesRepository salesRepository;
  GenerateSalesUsecase({required this.salesRepository});
  Future<void> call(CreateSalesEntity entity) async {
    return await salesRepository.generateSales(entity);
  }
}