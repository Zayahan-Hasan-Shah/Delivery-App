import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthSessionEvent extends AuthEvent {
  const CheckAuthSessionEvent();
}

class LoginSubmittedEvent extends AuthEvent {
  final String usernameOrPhone;
  final String password;

  const LoginSubmittedEvent({
    required this.usernameOrPhone,
    required this.password,
  });

  @override
  List<Object?> get props => [usernameOrPhone, password];
}

class RegisterSubmittedEvent extends AuthEvent {
  final String name;
  final String phone;
  final String email;
  final String password;
  final UserRole role;
  final String? vehicleType;

  const RegisterSubmittedEvent({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
    this.vehicleType,
  });

  @override
  List<Object?> get props => [name, phone, email, password, role, vehicleType];
}

class ForgotPasswordRequestedEvent extends AuthEvent {
  final String emailOrPhone;

  const ForgotPasswordRequestedEvent(this.emailOrPhone);

  @override
  List<Object?> get props => [emailOrPhone];
}

class ResetPasswordSubmittedEvent extends AuthEvent {
  final String emailOrPhone;
  final String otpCode;
  final String newPassword;

  const ResetPasswordSubmittedEvent({
    required this.emailOrPhone,
    required this.otpCode,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [emailOrPhone, otpCode, newPassword];
}

class ResetAuthStatusEvent extends AuthEvent {
  const ResetAuthStatusEvent();
}

class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}
