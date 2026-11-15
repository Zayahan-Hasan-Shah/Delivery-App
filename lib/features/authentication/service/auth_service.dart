import 'package:delivery_app/features/authentication/model/user_model.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';

abstract class AuthService {
  Future<UserModel> login({required String usernameOrPhone, required String password});

  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
    String? vehicleType,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<bool> hasValidToken();

  Future<void> requestPasswordReset({required String emailOrPhone});

  Future<void> resetPassword({
    required String emailOrPhone,
    required String otpCode,
    required String newPassword,
  });
}
