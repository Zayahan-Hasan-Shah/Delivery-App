enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  passwordResetCodeSent,
  passwordResetSuccess,
  error;

  bool get isLoading => this == AuthStatus.loading;
  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isUnauthenticated => this == AuthStatus.unauthenticated;
  bool get isPasswordResetCodeSent => this == AuthStatus.passwordResetCodeSent;
  bool get isPasswordResetSuccess => this == AuthStatus.passwordResetSuccess;
}
