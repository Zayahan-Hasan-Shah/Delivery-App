import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/core/utils/app_logger.dart';
import 'package:delivery_app/features/authentication/domain/usecases/check_auth_status_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/forgot_password_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/register_rider_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/register_sender_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:delivery_app/features/authentication/domain/usecases/update_rider_online_status_usecase.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/event/auth_event.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/state/auth_state.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/state/auth_status.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final LoginUseCase loginUseCase;
  final RegisterSenderUseCase registerSenderUseCase;
  final RegisterRiderUseCase registerRiderUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final LogoutUseCase logoutUseCase;
  final UpdateRiderOnlineStatusUseCase updateRiderOnlineStatusUseCase;

  AuthBloc({
    required this.checkAuthStatusUseCase,
    required this.loginUseCase,
    required this.registerSenderUseCase,
    required this.registerRiderUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.logoutUseCase,
    required this.updateRiderOnlineStatusUseCase,
  }) : super(const AuthState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSenderSubmittedEvent>(_onRegisterSender);
    on<RegisterRiderSubmittedEvent>(_onRegisterRider);
    on<ForgotPasswordRequestedEvent>(_onForgotPassword);
    on<ResetPasswordSubmittedEvent>(_onResetPassword);
    on<ToggleRiderOnlineInAuthEvent>(_onToggleRiderOnline);
    on<LogoutRequestedEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await checkAuthStatusUseCase();
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        ));
      }
    } catch (e) {
      AppLogger.error('Session restore failed', error: e, tag: 'AuthBloc');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      ));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearMessage: true,
    ));
    try {
      final user = await loginUseCase(
        phoneOrEmail: event.phoneOrEmail,
        password: event.password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onRegisterSender(
    RegisterSenderSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearMessage: true,
    ));
    try {
      final user = await registerSenderUseCase(
        fullName: event.fullName,
        restaurantName: event.restaurantName,
        phone: event.phone,
        restaurantAddress: event.restaurantAddress,
        password: event.password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onRegisterRider(
    RegisterRiderSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearMessage: true,
    ));
    try {
      final user = await registerRiderUseCase(
        fullName: event.fullName,
        phone: event.phone,
        password: event.password,
        drivingLicenseImagePath: event.drivingLicenseImagePath,
        bikePapersImagePath: event.bikePapersImagePath,
        cnicNumber: event.cnicNumber,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearMessage: true,
    ));
    try {
      final msg = await forgotPasswordUseCase(event.phoneOrEmail);
      emit(state.copyWith(
        status: AuthStatus.passwordResetCodeSent,
        message: msg,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearMessage: true,
    ));
    try {
      await resetPasswordUseCase(
        phoneOrEmail: event.phoneOrEmail,
        otpCode: event.otpCode,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(
        status: AuthStatus.passwordResetSuccess,
        message: 'Password reset successfully. Please log in.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _cleanError(e),
      ));
    }
  }

  Future<void> _onToggleRiderOnline(
    ToggleRiderOnlineInAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final updated = await updateRiderOnlineStatusUseCase(event.isOnline);
      emit(state.copyWith(status: AuthStatus.authenticated, user: updated));
    } catch (e) {
      AppLogger.warning('Could not update rider online status: $e', tag: 'AuthBloc');
    }
  }

  Future<void> _onLogout(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUseCase();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  String _cleanError(Object error) {
    final raw = error.toString();
    return raw.replaceFirst(RegExp(r'^[A-Za-z]+Exception:\s*'), '');
  }
}
