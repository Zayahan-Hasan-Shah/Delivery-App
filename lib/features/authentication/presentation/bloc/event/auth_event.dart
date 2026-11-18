import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LoginSubmittedEvent extends AuthEvent {
  final String phoneOrEmail;
  final String password;

  const LoginSubmittedEvent({
    required this.phoneOrEmail,
    required this.password,
  });

  @override
  List<Object?> get props => [phoneOrEmail, password];
}

class RegisterSenderSubmittedEvent extends AuthEvent {
  final String fullName;
  final String restaurantName;
  final String phone;
  final String restaurantAddress;
  final String password;

  const RegisterSenderSubmittedEvent({
    required this.fullName,
    required this.restaurantName,
    required this.phone,
    required this.restaurantAddress,
    required this.password,
  });

  @override
  List<Object?> get props => [
        fullName,
        restaurantName,
        phone,
        restaurantAddress,
        password,
      ];
}

class RegisterRiderSubmittedEvent extends AuthEvent {
  final String fullName;
  final String phone;
  final String password;
  final String drivingLicenseImagePath;
  final String bikePapersImagePath;
  final String? cnicNumber;

  const RegisterRiderSubmittedEvent({
    required this.fullName,
    required this.phone,
    required this.password,
    required this.drivingLicenseImagePath,
    required this.bikePapersImagePath,
    this.cnicNumber,
  });

  @override
  List<Object?> get props => [
        fullName,
        phone,
        password,
        drivingLicenseImagePath,
        bikePapersImagePath,
        cnicNumber,
      ];
}

class ForgotPasswordRequestedEvent extends AuthEvent {
  final String phoneOrEmail;

  const ForgotPasswordRequestedEvent(this.phoneOrEmail);

  @override
  List<Object?> get props => [phoneOrEmail];
}

class ResetPasswordSubmittedEvent extends AuthEvent {
  final String phoneOrEmail;
  final String otpCode;
  final String newPassword;

  const ResetPasswordSubmittedEvent({
    required this.phoneOrEmail,
    required this.otpCode,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [phoneOrEmail, otpCode, newPassword];
}

class ToggleRiderOnlineInAuthEvent extends AuthEvent {
  final bool isOnline;

  const ToggleRiderOnlineInAuthEvent(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}
