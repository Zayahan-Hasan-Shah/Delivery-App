import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/authentication/model/user_model.dart';
import 'package:delivery_app/features/authentication/state/auth_status.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? message;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.message,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, message];
}
