import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/input_validators.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/bloc/auth_bloc.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/event/auth_event.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/state/auth_state.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/state/auth_status.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/routing/route_names.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/widgets/app_text_field.dart';
import 'package:delivery_app/shared/widgets/language_toggle_pill.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _codeSent = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.forgotPasswordTitle),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 16.w),
            child: const Center(child: LanguageTogglePill()),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.passwordResetCodeSent) {
            setState(() => _codeSent = true);
            if (state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: AppColors.info,
                ),
              );
            }
          } else if (state.status == AuthStatus.passwordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Password reset successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            context.goNamed(RouteNames.login);
          } else if (state.status == AuthStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.forgotPasswordSubtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  AppTextField(
                    controller: _identifierController,
                    label: l10n.phoneOrEmailLabel,
                    hint: l10n.phoneOrEmailHint,
                    prefixIcon: Icons.phone_outlined,
                    validator: (v) => InputValidators.validateRequired(
                      v,
                      l10n.phoneOrEmailLabel,
                    ),
                  ),
                  if (_codeSent) ...[
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _otpController,
                      label: l10n.otpCodeLabel,
                      hint: '123456',
                      prefixIcon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => InputValidators.validateRequired(
                        v,
                        l10n.otpCodeLabel,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _newPasswordController,
                      label: l10n.newPasswordLabel,
                      hint: l10n.passwordHint,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: InputValidators.validatePassword,
                    ),
                  ],
                  SizedBox(height: 24.h),
                  AppButton(
                    text: _codeSent
                        ? l10n.confirmNewPassword
                        : l10n.sendResetCode,
                    isLoading: isLoading,
                    onPressed: () {
                      if (!(_formKey.currentState?.validate() ?? false)) return;
                      if (!_codeSent) {
                        context.read<AuthBloc>().add(
                              ForgotPasswordRequestedEvent(
                                _identifierController.text.trim(),
                              ),
                            );
                      } else {
                        context.read<AuthBloc>().add(
                              ResetPasswordSubmittedEvent(
                                phoneOrEmail: _identifierController.text.trim(),
                                otpCode: _otpController.text.trim(),
                                newPassword: _newPasswordController.text,
                              ),
                            );
                      }
                    },
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
