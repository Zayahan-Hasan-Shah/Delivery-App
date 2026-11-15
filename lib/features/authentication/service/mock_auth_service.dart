import 'dart:convert';

import 'package:delivery_app/features/authentication/service/auth_service.dart';
import 'package:delivery_app/features/authentication/model/user_model.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/core/errors/exceptions.dart';
import 'package:delivery_app/core/utils/app_logger.dart';
import 'package:delivery_app/shared/service/secure_storage_service.dart';

class MockAuthService implements AuthService {
  final SecureStorageService secureStorage;

  // Pre-seeded demo accounts for quick role-based testing
  static final List<UserModel> _demoUsers = [
    const UserModel(
      id: 'USR-CUST-001',
      name: 'Alice Johnson',
      email: 'customer@delivery.com',
      phone: '+1 555-0101',
      role: UserRole.customer,
      token: 'jwt_customer_token_sample',
    ),
    const UserModel(
      id: 'USR-CLNT-002',
      name: 'Apex Merchant Co.',
      email: 'client@delivery.com',
      phone: '+1 555-0202',
      role: UserRole.client,
      token: 'jwt_client_token_sample',
    ),
    const UserModel(
      id: 'USR-RIDR-003',
      name: 'Michael Swift',
      email: 'rider@delivery.com',
      phone: '+1 555-0303',
      role: UserRole.rider,
      token: 'jwt_rider_token_sample',
    ),
  ];

  MockAuthService({required this.secureStorage});

  @override
  Future<UserModel> login({
    required String usernameOrPhone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (password.length < 4) {
      throw const ServerException(
        message: 'Invalid credentials. Password too short.',
        statusCode: 400,
      );
    }

    final query = usernameOrPhone.trim().toLowerCase();
    UserModel? matched;
    for (final u in _demoUsers) {
      if (u.email.toLowerCase() == query ||
          u.phone.replaceAll(' ', '') == query.replaceAll(' ', '') ||
          u.role.name.toLowerCase() == query) {
        matched = u;
        break;
      }
    }

    matched ??= UserModel(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
      name: usernameOrPhone.split('@').first,
      email: usernameOrPhone.contains('@')
          ? usernameOrPhone
          : '$usernameOrPhone@delivery.com',
      phone: usernameOrPhone,
      role: UserRole.customer,
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
    );

    await secureStorage.write(
      AppConstants.keyAuthToken,
      matched.token ?? 'sample_token',
    );
    await secureStorage.write(
      AppConstants.keyUserData,
      jsonEncode(matched.toJson()),
    );

    return matched;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
    String? vehicleType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final newUser = UserModel(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
    );

    _demoUsers.add(newUser);

    await secureStorage.write(AppConstants.keyAuthToken, newUser.token!);
    await secureStorage.write(
      AppConstants.keyUserData,
      jsonEncode(newUser.toJson()),
    );

    AppLogger.info(
      'Registered new user [${role.displayName}] ${newUser.email}',
      tag: 'MockAuthService',
    );
    return newUser;
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(AppConstants.keyAuthToken);
    await secureStorage.delete(AppConstants.keyUserData);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final rawUser = await secureStorage.read(AppConstants.keyUserData);
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(rawUser);
        return UserModel.fromJson(data);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await secureStorage.read(AppConstants.keyAuthToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> requestPasswordReset({required String emailOrPhone}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (emailOrPhone.trim().isEmpty) {
      throw const ValidationException(
        message: 'Email or phone number is required.',
      );
    }
    AppLogger.info(
      'Password reset OTP (123456) dispatched to: $emailOrPhone',
      tag: 'MockAuthService',
    );
  }

  @override
  Future<void> resetPassword({
    required String emailOrPhone,
    required String otpCode,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (otpCode.trim().length < 4) {
      throw const ValidationException(message: 'Invalid verification code.');
    }
    if (newPassword.length < 6) {
      throw const ValidationException(
        message: 'New password must be at least 6 characters.',
      );
    }
    AppLogger.info(
      'Password successfully reset for: $emailOrPhone',
      tag: 'MockAuthService',
    );
  }
}
