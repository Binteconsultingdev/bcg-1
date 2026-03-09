


import 'package:bcg/features/auth/data/datasource/auth_data_source_imp.dart';
import 'package:bcg/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:bcg/features/auth/domain/usecase/create_user_usecase.dart';
import 'package:bcg/features/auth/domain/usecase/login_usecase.dart';

class UsecaseConfig {
  AuthDataSourceImp? authDataSourceImp;
  

  AuthRepositoryImp? authRepositoryImp;
  

  LoginUsecase? loginUsecase;
  CreateUserUsecase? createUserUsecase;



  UsecaseConfig(){
    authDataSourceImp = AuthDataSourceImp();
    
    authRepositoryImp = AuthRepositoryImp(authDataSourceImp: authDataSourceImp!);
    
    loginUsecase = LoginUsecase(authRepository: authRepositoryImp!);
    
    createUserUsecase = CreateUserUsecase(authRepository: authRepositoryImp!);
    


  }
}