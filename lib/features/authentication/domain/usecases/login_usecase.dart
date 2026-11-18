import 'package:delivery_app/features/authentication/domain/entities/user_entity.dart';
import 'package:delivery_app/features/authentication/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<UserEntity> call({
    required String phoneOrEmail,
    required String password,
  }) {
    return repository.login(phoneOrEmail: phoneOrEmail, password: password);
  }
}
