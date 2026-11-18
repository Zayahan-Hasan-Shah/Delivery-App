import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/core/errors/exceptions.dart';
import 'package:delivery_app/features/authentication/data/models/user_model.dart';
import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';
import 'package:delivery_app/shared/service/secure_storage_service.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login({
    required String phoneOrEmail,
    required String password,
  });

  Future<UserModel> registerSender({
    required String fullName,
    required String restaurantName,
    required String phone,
    required String restaurantAddress,
    required String password,
  });

  Future<UserModel> registerRider({
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

  Future<UserModel?> getStoredSession();

  Future<void> logout();

  Future<UserModel> updateRiderOnlineStatus(bool isOnline);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;
  final Uuid _uuid = const Uuid();

  // In-memory MVP account registry (Sender & Rider ONLY)
  final Map<String, _StoredAccount> _accounts = {};
  final Map<String, String> _activeOtps = {};

  AuthLocalDataSourceImpl({required this.secureStorage}) {
    _seedDemoAccounts();
  }

  void _seedDemoAccounts() {
    const demoSender = UserModel(
      id: 'sender_01',
      name: 'Ahmed Khan',
      phone: '03001234567',
      email: 'sender@shefscloud.com',
      role: UserRole.sender,
      restaurantName: 'Spice Cloud Kitchen',
      restaurantAddress: 'Plot 14, Street 6, F-7 Markaz, Islamabad',
    );
    const demoRider = UserModel(
      id: 'rider_01',
      name: 'Bilal Raza',
      phone: '03117654321',
      email: 'rider@shefscloud.com',
      role: UserRole.rider,
      cnicNumber: '61101-1234567-1',
      drivingLicenseImagePath: 'demo://documents/driving_license_verified.jpg',
      bikePapersImagePath: 'demo://documents/bike_papers_verified.jpg',
      documentsVerified: true,
      isOnline: true,
    );

    _accounts['sender@shefscloud.com'] =
        _StoredAccount(user: demoSender, password: 'password123');
    _accounts['03001234567'] =
        _StoredAccount(user: demoSender, password: 'password123');
    _accounts['rider@shefscloud.com'] =
        _StoredAccount(user: demoRider, password: 'password123');
    _accounts['03117654321'] =
        _StoredAccount(user: demoRider, password: 'password123');
  }

  String _normalizeKey(String input) =>
      input.trim().toLowerCase().replaceAll(' ', '');

  @override
  Future<UserModel> login({
    required String phoneOrEmail,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final key = _normalizeKey(phoneOrEmail);
    final account = _accounts[key];

    if (account == null || account.password != password) {
      throw const AuthException('Invalid phone number/email or password.');
    }

    await _persistSession(account.user);
    return account.user;
  }

  @override
  Future<UserModel> registerSender({
    required String fullName,
    required String restaurantName,
    required String phone,
    required String restaurantAddress,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final normalizedPhone = _normalizeKey(phone);
    if (_accounts.containsKey(normalizedPhone)) {
      throw const AuthException(
        'An account with this phone number already exists.',
      );
    }

    final cleanSlug = fullName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '.');
    final user = UserModel(
      id: 'sender_${_uuid.v4().substring(0, 6)}',
      name: fullName.trim(),
      phone: phone.trim(),
      email: '$cleanSlug@sender.shefscloud.com',
      role: UserRole.sender,
      restaurantName: restaurantName.trim(),
      restaurantAddress: restaurantAddress.trim(),
    );

    _accounts[normalizedPhone] = _StoredAccount(user: user, password: password);
    _accounts[user.email] = _StoredAccount(user: user, password: password);
    await _persistSession(user);
    return user;
  }

  @override
  Future<UserModel> registerRider({
    required String fullName,
    required String phone,
    required String password,
    required String drivingLicenseImagePath,
    required String bikePapersImagePath,
    String? cnicNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final normalizedPhone = _normalizeKey(phone);
    if (_accounts.containsKey(normalizedPhone)) {
      throw const AuthException(
        'An account with this phone number already exists.',
      );
    }
    if (drivingLicenseImagePath.trim().isEmpty ||
        bikePapersImagePath.trim().isEmpty) {
      throw const ValidationException(
        message: 'Driving license and bike papers images are required.',
      );
    }

    final cleanSlug = fullName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '.');
    final user = UserModel(
      id: 'rider_${_uuid.v4().substring(0, 6)}',
      name: fullName.trim(),
      phone: phone.trim(),
      email: '$cleanSlug@rider.shefscloud.com',
      role: UserRole.rider,
      cnicNumber: cnicNumber?.trim(),
      drivingLicenseImagePath: drivingLicenseImagePath,
      bikePapersImagePath: bikePapersImagePath,
      documentsVerified: true,
      isOnline: true,
    );

    _accounts[normalizedPhone] = _StoredAccount(user: user, password: password);
    _accounts[user.email] = _StoredAccount(user: user, password: password);
    await _persistSession(user);
    return user;
  }

  @override
  Future<String> requestPasswordResetOtp(String phoneOrEmail) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final key = _normalizeKey(phoneOrEmail);
    if (!_accounts.containsKey(key)) {
      throw const AuthException('No account found with this phone or email.');
    }
    const otp = '123456';
    _activeOtps[key] = otp;
    return 'OTP verification code ($otp) sent to $phoneOrEmail.';
  }

  @override
  Future<void> resetPassword({
    required String phoneOrEmail,
    required String otpCode,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final key = _normalizeKey(phoneOrEmail);
    final expected = _activeOtps[key];
    if (expected == null || expected != otpCode.trim()) {
      throw const AuthException('Invalid or expired OTP verification code.');
    }
    final existing = _accounts[key];
    if (existing == null) {
      throw const AuthException('Account not found.');
    }
    final updated = _StoredAccount(user: existing.user, password: newPassword);
    _accounts[_normalizeKey(existing.user.phone)] = updated;
    _accounts[_normalizeKey(existing.user.email)] = updated;
    _activeOtps.remove(key);
  }

  @override
  Future<UserModel?> getStoredSession() async {
    final raw = await secureStorage.read(AppConstants.keyUserData);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(AppConstants.keyAuthToken);
    await secureStorage.delete(AppConstants.keyUserData);
  }

  @override
  Future<UserModel> updateRiderOnlineStatus(bool isOnline) async {
    final current = await getStoredSession();
    if (current == null) {
      throw const AuthException('No active user session.');
    }
    final updated = UserModel.fromEntity(current.copyWith(isOnline: isOnline));
    await _persistSession(updated);
    return updated;
  }

  Future<void> _persistSession(UserModel user) async {
    await secureStorage.write(
      AppConstants.keyAuthToken,
      'mvp_token_${user.id}',
    );
    await secureStorage.write(
      AppConstants.keyUserData,
      jsonEncode(user.toJson()),
    );
  }
}

class _StoredAccount {
  final UserModel user;
  final String password;

  const _StoredAccount({required this.user, required this.password});
}
