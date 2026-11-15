import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/features/authentication/bloc/auth_event.dart';
import 'package:delivery_app/features/authentication/bloc/auth_state.dart';
import 'package:delivery_app/features/authentication/service/auth_service.dart';
import 'package:delivery_app/features/authentication/state/auth_status.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(const AuthState()) {
    on<CheckAuthSessionEvent>(_onCheckAuthSession);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<ForgotPasswordRequestedEvent>(_onForgotPasswordRequested);
    on<ResetPasswordSubmittedEvent>(_onResetPasswordSubmitted);
    on<ResetAuthStatusEvent>(_onResetAuthStatus);
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthSession(
    CheckAuthSessionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await authService.getCurrentUser();
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
          message: null,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          errorMessage: null,
          message: null,
        ));
      }
    } catch (e, st) {
      AppLogger.error('Failed to restore session', error: e, stackTrace: st, tag: 'AuthBloc');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: 'Session expired. Please log in again.',
      ));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null, message: null));
    try {
      final user = await authService.login(
        usernameOrPhone: event.usernameOrPhone,
        password: event.password,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      ));
    } catch (e, st) {
      AppLogger.error('Login error', error: e, stackTrace: st, tag: 'AuthBloc');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', '').replaceFirst('ServerException: ', ''),
      ));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null, message: null));
    try {
      final user = await authService.register(
        name: event.name,
        phone: event.phone,
        email: event.email,
        password: event.password,
        role: event.role,
        vehicleType: event.vehicleType,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
        message: 'Account successfully created!',
      ));
    } catch (e, st) {
      AppLogger.error('Registration error', error: e, stackTrace: st, tag: 'AuthBloc');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null, message: null));
    try {
      await authService.requestPasswordReset(emailOrPhone: event.emailOrPhone);
      emit(state.copyWith(
        status: AuthStatus.passwordResetCodeSent,
        message: 'A 6-digit recovery code has been sent to ${event.emailOrPhone}.',
        errorMessage: null,
      ));
    } catch (e, st) {
      AppLogger.error('Forgot password error', error: e, stackTrace: st, tag: 'AuthBloc');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null, message: null));
    try {
      await authService.resetPassword(
        emailOrPhone: event.emailOrPhone,
        otpCode: event.otpCode,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(
        status: AuthStatus.passwordResetSuccess,
        message: 'Password reset successful! You can now log in with your new password.',
        errorMessage: null,
      ));
    } catch (e, st) {
      AppLogger.error('Reset password error', error: e, stackTrace: st, tag: 'AuthBloc');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onResetAuthStatus(
    ResetAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
      message: null,
    ));
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await authService.logout();
    } catch (e) {
      AppLogger.warning('Logout cleanup warning: $e', tag: 'AuthBloc');
    }
    emit(const AuthState(status: AuthStatus.unauthenticated, user: null));
  }
}
