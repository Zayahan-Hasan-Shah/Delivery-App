import 'package:delivery_app/features/authentication/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  const ResetPasswordUseCase(this.repository);

  Future<void> call({
    required String phoneOrEmail,
    required String otpCode,
    required String newPassword,
  }) {
    return repository.resetPassword(
      phoneOrEmail: phoneOrEmail,
      otpCode: otpCode,
      newPassword: newPassword,
    );
  }
}
