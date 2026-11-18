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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmittedEvent(
              usernameOrPhone: _usernameController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _fillDemoCredentials(String username, String password) {
    _usernameController.text = username;
    _passwordController.text = password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status == AuthStatus.authenticated && state.user != null) {
            context.goNamed(RouteNames.home);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Branding
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            size: 44,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Log in to track, manage, or deliver packages',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Email or Phone
                      AuthTextField(
                        controller: _usernameController,
                        label: 'Email or Phone Number',
                        hint: 'e.g. customer@delivery.com or +1 555-0101',
                        prefixIcon: Icons.person_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => InputValidators.validateRequired(value, 'Email or Phone'),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onTogglePassword: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: InputValidators.validatePassword,
                      ),
                      const SizedBox(height: 8),

                      // FORGOT PASSWORD LINK
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(const ResetAuthStatusEvent());
                            context.pushNamed(RouteNames.forgotPassword);
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Login Button
                      AppButton(
                        text: 'Log In',
                        onPressed: _onLoginPressed,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 24),

                      // Demo Quick-Fill Roles
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.touch_app, size: 16, color: AppColors.textSecondary),
                                SizedBox(width: 6),
                                Text(
                                  'Quick Demo Accounts (Tap to fill):',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ActionChip(
                                  label: const Text('Customer'),
                                  avatar: const Icon(Icons.person, size: 16, color: AppColors.primary),
                                  onPressed: () => _fillDemoCredentials('customer@delivery.com', '123456'),
                                ),
                                ActionChip(
                                  label: const Text('Client'),
                                  avatar: const Icon(Icons.store, size: 16, color: AppColors.accent),
                                  onPressed: () => _fillDemoCredentials('client@delivery.com', '123456'),
                                ),
                                ActionChip(
                                  label: const Text('Rider'),
                                  avatar: const Icon(Icons.two_wheeler, size: 16, color: AppColors.success),
                                  onPressed: () => _fillDemoCredentials('rider@delivery.com', '123456'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Register Navigation Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<AuthBloc>().add(const ResetAuthStatusEvent());
                              context.pushNamed(RouteNames.register);
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
