

import 'package:bcg/features/auth/domain/entities/response/login_response_entity.dart';
import 'package:bcg/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository authRepository;
  LoginUsecase({required this.authRepository});
  Future<LoginResponseEntity> call ({required String user,required String password, required String baseDatos}) async {
    return await authRepository.login(user, password,baseDatos);
  }
}