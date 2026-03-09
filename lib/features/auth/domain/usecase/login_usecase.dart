

import 'package:bcg/features/auth/domain/entities/response/login_response_entity.dart';
import 'package:bcg/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository authRepository;
  LoginUsecase({required this.authRepository});
  Future<LoginResponseEntity> execute ({required String email,required String password}) async {
    return await authRepository.login(email, password);
  }
}