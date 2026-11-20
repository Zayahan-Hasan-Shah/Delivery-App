import 'package:delivery_app/features/authentication/data/data_sources/auth_local_data_source.dart';
import 'package:delivery_app/features/authentication/domain/entities/user_entity.dart';
import 'package:delivery_app/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<UserEntity> login({
    required String phoneOrEmail,
    required String password,
  }) {
    return localDataSource.login(
      phoneOrEmail: phoneOrEmail,
      password: password,
    );
  }

  @override
  Future<UserEntity> registerSender({
    required String fullName,
    required String phone,
    required String pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    required String password,
  }) {
    return localDataSource.registerSender(
      fullName: fullName,
      phone: phone,
      pickupAddress: pickupAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      password: password,
    );
  }

  @override
  Future<UserEntity> registerRider({
    required String fullName,
    required String phone,
    required String password,
    required String drivingLicenseImagePath,
    required String bikePapersImagePath,
    String? cnicNumber,
  }) {
    return localDataSource.registerRider(
      fullName: fullName,
      phone: phone,
      password: password,
      drivingLicenseImagePath: drivingLicenseImagePath,
      bikePapersImagePath: bikePapersImagePath,
      cnicNumber: cnicNumber,
    );
  }

  @override
  Future<String> requestPasswordResetOtp(String phoneOrEmail) {
    return localDataSource.requestPasswordResetOtp(phoneOrEmail);
  }

  @override
  Future<void> resetPassword({
    required String phoneOrEmail,
    required String otpCode,
    required String newPassword,
  }) {
    return localDataSource.resetPassword(
      phoneOrEmail: phoneOrEmail,
      otpCode: otpCode,
      newPassword: newPassword,
    );
  }

  @override
  Future<UserEntity?> getStoredSession() {
    return localDataSource.getStoredSession();
  }

  @override
  Future<void> logout() {
    return localDataSource.logout();
  }

  @override
  Future<UserEntity> updateRiderOnlineStatus(bool isOnline) {
    return localDataSource.updateRiderOnlineStatus(isOnline);
  }
}
