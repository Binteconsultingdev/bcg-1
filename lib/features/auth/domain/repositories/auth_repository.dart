


import 'package:bcg/features/auth/domain/entities/license/license_entity.dart';
import 'package:bcg/features/auth/domain/entities/response/login_response_entity.dart';
import 'package:bcg/features/auth/domain/entities/user/create_user_entity.dart';

abstract class AuthRepository {
  Future<LoginResponseEntity> login(String user,String password,String baseDatos);
  Future<void> createUser(CreateUserEntity entity);
Future<LicenseEntity>  validateLicenses(String licencia);
}