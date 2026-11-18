import 'package:delivery_app/features/authentication/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  const ForgotPasswordUseCase(this.repository);

  Future<String> call(String phoneOrEmail) {
    return repository.requestPasswordResetOtp(phoneOrEmail);
  }
}
