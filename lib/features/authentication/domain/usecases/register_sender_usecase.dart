import 'package:delivery_app/features/authentication/domain/entities/user_entity.dart';
import 'package:delivery_app/features/authentication/domain/repositories/auth_repository.dart';

class RegisterSenderUseCase {
  final AuthRepository repository;

  const RegisterSenderUseCase(this.repository);

  Future<UserEntity> call({
    required String fullName,
    required String restaurantName,
    required String phone,
    required String restaurantAddress,
    required String password,
  }) {
    return repository.registerSender(
      fullName: fullName,
      restaurantName: restaurantName,
      phone: phone,
      restaurantAddress: restaurantAddress,
      password: password,
    );
  }
}
