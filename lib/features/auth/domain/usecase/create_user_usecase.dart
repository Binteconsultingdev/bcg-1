

import 'package:bcg/features/auth/domain/entities/user/create_user_entity.dart';
import 'package:bcg/features/auth/domain/repositories/auth_repository.dart';

class CreateUserUsecase {
  final AuthRepository authRepository;
  CreateUserUsecase({required this.authRepository});
  Future<void> call(CreateUserEntity entity) async {
    return await authRepository.createUser(entity);
  }
}