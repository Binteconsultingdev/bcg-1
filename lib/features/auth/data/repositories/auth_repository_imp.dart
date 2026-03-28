

import 'dart:async';

import 'package:bcg/common/constants/constants.dart';
import 'package:bcg/features/auth/data/datasource/auth_data_source_imp.dart';
import 'package:bcg/features/auth/domain/entities/license/license_entity.dart';
import 'package:bcg/features/auth/domain/entities/response/login_response_entity.dart';
import 'package:bcg/features/auth/domain/entities/user/create_user_entity.dart';
import 'package:bcg/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImp extends AuthRepository {
  final AuthDataSourceImp authDataSourceImp;
  AuthRepositoryImp({required this.authDataSourceImp});
      String defaultApiServer = AppConstants.serverBase;

  @override
  Future<LoginResponseEntity> login(String user, String password, String baseDatos) async {
    return await authDataSourceImp.login(user, password, baseDatos);
  }

  @override
  Future<void> createUser(CreateUserEntity entity) async  {
    return await authDataSourceImp.createuser(entity);
  }
  
  @override
  Future<LicenseEntity> validateLicenses(String licencia) async {
    return await authDataSourceImp.validateLicenses(licencia);
  }

 

}