import 'package:delivery_app/features/authentication/domain/entities/user_entity.dart';
import 'package:delivery_app/features/authentication/domain/repositories/auth_repository.dart';

class RegisterRiderUseCase {
  final AuthRepository repository;

  const RegisterRiderUseCase(this.repository);

  Future<UserEntity> call({
    required String fullName,
    required String phone,
    required String password,
    required String drivingLicenseImagePath,
    required String bikePapersImagePath,
    String? cnicNumber,
  }) {
    return repository.registerRider(
      fullName: fullName,
      phone: phone,
      password: password,
      drivingLicenseImagePath: drivingLicenseImagePath,
      bikePapersImagePath: bikePapersImagePath,
      cnicNumber: cnicNumber,
    );
  }
}
