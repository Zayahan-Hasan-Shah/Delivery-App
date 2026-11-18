import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/features/authentication/bloc/auth_bloc.dart';
import 'package:delivery_app/features/authentication/bloc/auth_event.dart';
import 'package:delivery_app/features/authentication/bloc/auth_state.dart';
import 'package:delivery_app/features/authentication/state/auth_status.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';
import 'package:delivery_app/features/authentication/view/widgets/auth_text_field.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/input_validators.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/routing/route_names.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;
  String _selectedVehicle = 'Motorcycle';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterSubmittedEvent(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
              vehicleType: _selectedRole == UserRole.rider ? _selectedVehicle : null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
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
          } else if (state.status == AuthStatus.authenticated && state.user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome, ${state.user!.name}! Registered as ${state.user!.role.displayName}.'),
                backgroundColor: AppColors.success,
              ),
            );
            context.goNamed(RouteNames.home);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Join LogiFlow Delivery',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select your user role and complete your registration',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Role Selection (Customer, Client, Rider)
                    const Text(
                      'Select Role',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment(
                          value: UserRole.customer,
                          label: Text('Customer'),
                          icon: Icon(Icons.person_outline),
                        ),
                        ButtonSegment(
                          value: UserRole.client,
                          label: Text('Client'),
                          icon: Icon(Icons.storefront_outlined),
                        ),
                        ButtonSegment(
                          value: UserRole.rider,
                          label: Text('Rider'),
                          icon: Icon(Icons.two_wheeler_outlined),
                        ),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedRole = newSelection.first;
                        });
                      },
                    ),

                    if (_selectedRole == UserRole.rider) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.success.withAlpha(77)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: AppColors.success),
                                SizedBox(width: 6),
                                Text(
                                  'Courier Onboarding Note',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Orders are automatically assigned by the logistics engine based on proximity to pickup points.',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedVehicle,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Type',
                                prefixIcon: Icon(Icons.delivery_dining, size: 20),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Motorcycle', child: Text('Motorcycle / Scooter')),
                                DropdownMenuItem(value: 'Bicycle', child: Text('Bicycle / E-bike')),
                                DropdownMenuItem(value: 'Van', child: Text('Cargo Van / Car')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedVehicle = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Full Name
                    AuthTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'John Doe',
                      prefixIcon: Icons.badge_outlined,
                      validator: (value) => InputValidators.validateRequired(value, 'Name'),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    AuthTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+1 555-0199',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: InputValidators.validatePhone,
                    ),
                    const SizedBox(height: 16),

                    // Email Address
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'john@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: InputValidators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'At least 6 characters',
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
                    const SizedBox(height: 16),

                    // Confirm Password
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      prefixIcon: Icons.lock_reset_outlined,
                      isPassword: true,
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Register Button
                    AppButton(
                      text: 'Create Account',
                      onPressed: _onRegisterPressed,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 20),

                    // Already have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<AuthBloc>().add(const ResetAuthStatusEvent());
                            context.pop();
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
