import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/features/authentication/bloc/auth_bloc.dart';
import 'package:delivery_app/features/authentication/bloc/auth_event.dart';
import 'package:delivery_app/features/authentication/bloc/auth_state.dart';
import 'package:delivery_app/features/authentication/state/auth_status.dart';
import 'package:delivery_app/features/authentication/view/widgets/auth_text_field.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/input_validators.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/routing/route_names.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailPhoneFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailPhoneController = TextEditingController();
  final _otpController = TextEditingController(text: '123456'); // Pre-fill mock OTP for smooth testing
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isStepTwo = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRequestResetCode() {
    if (_emailPhoneFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            ForgotPasswordRequestedEvent(_emailPhoneController.text.trim()),
          );
    }
  }

  void _onSubmitNewPassword() {
    if (_resetFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            ResetPasswordSubmittedEvent(
              emailOrPhone: _emailPhoneController.text.trim(),
              otpCode: _otpController.text.trim(),
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isStepTwo) {
              setState(() {
                _isStepTwo = false;
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status == AuthStatus.passwordResetCodeSent) {
            setState(() {
              _isStepTwo = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Reset code sent!'),
                backgroundColor: AppColors.info,
              ),
            );
          } else if (state.status == AuthStatus.passwordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Password reset successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<AuthBloc>().add(const ResetAuthStatusEvent());
            context.goNamed(RouteNames.login);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Indicator
                  Row(
                    children: [
                      _StepBadge(stepNumber: '1', title: 'Find Account', isActive: !_isStepTwo, isCompleted: _isStepTwo),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: _isStepTwo ? AppColors.primary : AppColors.cardBorder,
                        ),
                      ),
                      _StepBadge(stepNumber: '2', title: 'New Password', isActive: _isStepTwo, isCompleted: false),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (!_isStepTwo) ...[
                    // STEP 1: Enter email or phone
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Forgot Your Password?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your registered email address or phone number and we will send you a verification code to reset your password.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    Form(
                      key: _emailPhoneFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthTextField(
                            controller: _emailPhoneController,
                            label: 'Email or Phone Number',
                            hint: 'e.g. customer@delivery.com or +1 555-0101',
                            prefixIcon: Icons.contact_mail_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => InputValidators.validateRequired(val, 'Email or Phone'),
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            text: 'Send Verification Code',
                            icon: Icons.send_rounded,
                            isLoading: isLoading,
                            onPressed: _onRequestResetCode,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // STEP 2: Enter OTP & New Password
                    const Text(
                      'Create New Password',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter the 6-digit verification code sent to ${_emailPhoneController.text.trim()} and choose a strong password.',
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: _resetFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthTextField(
                            controller: _otpController,
                            label: 'Verification Code (OTP)',
                            hint: '6-digit code (Demo: 123456)',
                            prefixIcon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().length < 4) {
                                return 'Enter a valid verification code';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _newPasswordController,
                            label: 'New Password',
                            hint: 'At least 6 characters',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            isPasswordVisible: _isNewPasswordVisible,
                            onTogglePassword: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                            validator: InputValidators.validatePassword,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm New Password',
                            hint: 'Re-enter your new password',
                            prefixIcon: Icons.lock_reset_outlined,
                            isPassword: true,
                            isPasswordVisible: _isConfirmPasswordVisible,
                            onTogglePassword: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                            validator: (val) {
                              if (val != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          AppButton(
                            text: 'Update Password',
                            icon: Icons.check_circle_outline,
                            isLoading: isLoading,
                            onPressed: _onSubmitNewPassword,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back to Log In'),
                      onPressed: () {
                        context.read<AuthBloc>().add(const ResetAuthStatusEvent());
                        context.goNamed(RouteNames.login);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final String stepNumber;
  final String title;
  final bool isActive;
  final bool isCompleted;

  const _StepBadge({
    required this.stepNumber,
    required this.title,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted || isActive ? AppColors.primary : AppColors.textMuted;
    final bgColor = isCompleted
        ? AppColors.primary
        : isActive
            ? AppColors.primary.withAlpha(30)
            : AppColors.surfaceVariant;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    stepNumber,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
            color: isActive || isCompleted ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
