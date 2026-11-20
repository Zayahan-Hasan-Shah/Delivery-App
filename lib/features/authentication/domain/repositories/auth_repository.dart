import 'package:delivery_app/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String phoneOrEmail,
    required String password,
  });

  Future<UserEntity> registerSender({
    required String fullName,
    required String phone,
    required String pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    required String password,
  });

  Future<UserEntity> registerRider({
    required String fullName,
    required String phone,
    required String password,
    required String drivingLicenseImagePath,
    required String bikePapersImagePath,
    String? cnicNumber,
  });

  Future<String> requestPasswordResetOtp(String phoneOrEmail);

  Future<void> resetPassword({
    required String phoneOrEmail,
    required String otpCode,
    required String newPassword,
  });

  Future<UserEntity?> getStoredSession();

  Future<void> logout();

  Future<UserEntity> updateRiderOnlineStatus(bool isOnline);
}
