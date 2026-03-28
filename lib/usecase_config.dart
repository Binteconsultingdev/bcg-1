


import 'package:bcg/features/Inventory/data/datasources/inventory_datasources_imp.dart';
import 'package:bcg/features/Inventory/data/repositories/inventory_repository_imp.dart';
import 'package:bcg/features/Inventory/domain/repositories/Inventory_repository.dart';
import 'package:bcg/features/Inventory/domain/usecase/fetch_familias_usecase.dart';
import 'package:bcg/features/Inventory/domain/usecase/fetch_inventario_usecase.dart';
import 'package:bcg/features/Inventory/domain/usecase/fetch_subfamilias_usecase.dart';
import 'package:bcg/features/auth/data/datasource/auth_data_source_imp.dart';
import 'package:bcg/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:bcg/features/auth/domain/usecase/create_user_usecase.dart';
import 'package:bcg/features/auth/domain/usecase/login_usecase.dart';
import 'package:bcg/features/auth/domain/usecase/validate_licenses_usecase.dart';
import 'package:bcg/features/quotes/data/datasources/quotes_data_sources_imp.dart';
import 'package:bcg/features/quotes/data/repositories/quotes_repository_imp.dart';
import 'package:bcg/features/quotes/domain/usecase/create_quotes_usecase.dart';
import 'package:bcg/features/quotes/domain/usecase/fetch_quote_usecase.dart';
import 'package:bcg/features/sales/data/datasources/sales_data_sources_imp.dart';
import 'package:bcg/features/sales/data/repositories/sales_repository_imp.dart';
import 'package:bcg/features/sales/domain/usecase/point_sales_usecase.dart';

class UsecaseConfig {
  AuthDataSourceImp? authDataSourceImp;
  QuotesDataSourcesImp? quotesDataSourcesImp;
  SalesDataSourcesImp? salesDataSourcesImp;

  AuthRepositoryImp? authRepositoryImp;
  QuotesRepositoryImp? quotesRepositoryImp;
  SalesRepositoryImp? salesRepositoryImp;

  LoginUsecase? loginUsecase;
  CreateUserUsecase? createUserUsecase;
  ValidateLicensesUsecase? validateLicensesUsecase;
 
  InventoryDatasourcesImp? inventoryDatasourcesImp; 
  InventoryRepositoryImp? inventoryRepositoryImp;

  FetchFamiliasUsecase? fetchFamiliasUsecase;
  FetchSubfamiliasUsecase? fetchSubfamiliasUsecase;
  FetchInventarioUsecase? fetchInventarioUsecase;

  CreateQuotesUsecase?createQuotesUsecase;
  FetchQuoteUsecase? fetchQuoteUsecase;

 PointSalesUsecase?pointSalesUsecase;
  UsecaseConfig(){
    authDataSourceImp = AuthDataSourceImp();
    quotesDataSourcesImp = QuotesDataSourcesImp();
    inventoryDatasourcesImp = InventoryDatasourcesImp();
    salesDataSourcesImp= SalesDataSourcesImp();
    
    authRepositoryImp = AuthRepositoryImp(authDataSourceImp: authDataSourceImp!);
    inventoryRepositoryImp = InventoryRepositoryImp(inventoryDatasourcesImp: inventoryDatasourcesImp!);
    quotesRepositoryImp = QuotesRepositoryImp(quotesDataSourcesImp: quotesDataSourcesImp!);
    salesRepositoryImp = SalesRepositoryImp(salesDataSourcesImp: salesDataSourcesImp!);

    loginUsecase = LoginUsecase(authRepository: authRepositoryImp!);
    
    createUserUsecase = CreateUserUsecase(authRepository: authRepositoryImp!);
    validateLicensesUsecase = ValidateLicensesUsecase(authRepository: authRepositoryImp!);
    fetchFamiliasUsecase = FetchFamiliasUsecase(inventoryRepository: inventoryRepositoryImp!);
    fetchSubfamiliasUsecase = FetchSubfamiliasUsecase(inventoryRepository: inventoryRepositoryImp!);
    fetchInventarioUsecase = FetchInventarioUsecase(inventoryRepository: inventoryRepositoryImp!);
    
    createQuotesUsecase = CreateQuotesUsecase(quotesRepository: quotesRepositoryImp!);
    fetchQuoteUsecase = FetchQuoteUsecase(quotesRepository: quotesRepositoryImp!); 
    
    pointSalesUsecase = PointSalesUsecase(salesRepository: salesRepositoryImp!);

  }
}