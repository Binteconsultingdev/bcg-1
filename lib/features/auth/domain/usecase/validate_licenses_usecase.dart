import 'package:bcg/features/auth/domain/entities/license/license_entity.dart';
import 'package:bcg/features/auth/domain/repositories/auth_repository.dart';

class ValidateLicensesUsecase {
  final AuthRepository authRepository;

  ValidateLicensesUsecase({ required this.authRepository });

  Future<LicenseEntity>  call(String licencia) async {
    return await authRepository.validateLicenses(licencia);
  }
}