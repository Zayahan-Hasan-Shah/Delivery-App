import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/input_validators.dart';
import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/bloc/auth_bloc.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/event/auth_event.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/state/auth_state.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/state/auth_status.dart';
import 'package:delivery_app/features/authentication/presentation/view/widgets/document_upload_tile.dart';
import 'package:delivery_app/features/orders/presentation/view/widgets/location_picker_map.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/routing/route_names.dart';
import 'package:delivery_app/shared/service/document_picker_service.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole initialRole;

  const RegisterScreen({super.key, this.initialRole = UserRole.sender});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Sender-specific fields (Pickup Address & Map Location)
  final _pickupAddressController = TextEditingController();
  double _pickupLatitude = AppConstants.defaultLatitude;
  double _pickupLongitude = AppConstants.defaultLongitude;
  bool _isLocatingPickup = false;

  // Rider-specific fields
  final _cnicController = TextEditingController();
  PickedDocumentImage? _drivingLicensePhoto;
  PickedDocumentImage? _bikePapersPhoto;

  late UserRole _selectedRole;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
    _initSenderLocation();
  }

  void _initSenderLocation() {
    sl<LocationService>().getCurrentLocation().then((pos) {
      if (mounted && pos != null) {
        setState(() {
          _pickupLatitude = pos.latitude;
          _pickupLongitude = pos.longitude;
        });
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _pickupAddressController.dispose();
    _cnicController.dispose();
    super.dispose();
  }

  Future<void> _showDocumentPickerSheet({required bool isDrivingLicense}) async {
    final l10n = AppLocalizations.of(context);
    final pickerService = sl<DocumentPickerService>();
    final label = isDrivingLicense
        ? l10n.drivingLicenseLabel
        : l10n.bikePapersLabel;

    final picked = await showModalBottomSheet<PickedDocumentImage>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${l10n.choosePhotoSource} — $label',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.takePhotoCamera),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  onTap: () async {
                    final img = await pickerService.pickFromCamera();
                    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop(img);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.chooseFromGallery),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  onTap: () async {
                    final img = await pickerService.pickFromGallery();
                    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop(img);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.verified_outlined,
                    color: AppColors.success,
                  ),
                  title: Text(l10n.useSampleDocument),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  onTap: () {
                    Navigator.of(sheetCtx).pop(
                      pickerService.createSampleDocument(
                        isDrivingLicense ? 'driving_license' : 'bike_papers',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() {
        if (isDrivingLicense) {
          _drivingLicensePhoto = picked;
        } else {
          _bikePapersPhoto = picked;
        }
      });
    } else if (pickerService.lastErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pickerService.lastErrorMessage!),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedRole.isSender) {
      context.read<AuthBloc>().add(
            RegisterSenderSubmittedEvent(
              fullName: _fullNameController.text.trim(),
              phone: _phoneController.text.trim(),
              pickupAddress: _pickupAddressController.text.trim(),
              pickupLatitude: _pickupLatitude,
              pickupLongitude: _pickupLongitude,
              password: _passwordController.text,
            ),
          );
    } else {
      if (_drivingLicensePhoto == null || _bikePapersPhoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bothDocumentsRequired),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      context.read<AuthBloc>().add(
            RegisterRiderSubmittedEvent(
              fullName: _fullNameController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              drivingLicenseImagePath: _drivingLicensePhoto!.path,
              bikePapersImagePath: _bikePapersPhoto!.path,
              cnicNumber: _cnicController.text.trim().isEmpty
                  ? null
                  : _cnicController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRider = _selectedRole.isRider;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.error &&
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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar: Back + Brand + EN|اردو toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.goNamed(RouteNames.login);
                                }
                              },
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              l10n.brandShort,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Role Switcher (Sender vs Rider ONLY)
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _RoleSelectorTab(
                              label: l10n.roleSender,
                              icon: Icons.storefront_rounded,
                              selected: !isRider,
                              onTap: () =>
                                  setState(() => _selectedRole = UserRole.sender),
                            ),
                          ),
                          Expanded(
                            child: _RoleSelectorTab(
                              label: l10n.roleRider,
                              icon: Icons.two_wheeler_rounded,
                              selected: isRider,
                              onTap: () =>
                                  setState(() => _selectedRole = UserRole.rider),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Headline
                    Text(
                      isRider
                          ? l10n.registerTitleRider
                          : l10n.registerTitleSender,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isRider
                          ? l10n.registerSubtitleRider
                          : l10n.registerSubtitleSender,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Full Name (Both Sender & Rider)
                    AppTextField(
                      controller: _fullNameController,
                      label: l10n.fullNameLabel,
                      hint: isRider
                          ? l10n.fullNameHintRider
                          : l10n.fullNameHintSender,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => InputValidators.validateRequired(
                        v,
                        l10n.fullNameLabel,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Phone Number (Both Sender & Rider)
                    AppTextField(
                      controller: _phoneController,
                      label: l10n.phoneNumberLabel,
                      hint: l10n.phoneNumberHint,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: InputValidators.validatePhone,
                    ),
                    SizedBox(height: 14.h),

                    // Sender-Specific: Pickup Address Text Field + Pin Map
                    if (!isRider) ...[
                      AppTextField(
                        controller: _pickupAddressController,
                        label: l10n.pickupAddressLabel,
                        hint: l10n.restaurantAddressHint,
                        prefixIcon: Icons.location_on_outlined,
                        maxLines: 2,
                        validator: (v) => InputValidators.validateRequired(
                          v,
                          l10n.pickupAddressLabel,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Icon(
                            Icons.pin_drop_outlined,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Pin Pickup Location on Map',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          height: 180.h,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: LocationPickerMap(
                            latitude: _pickupLatitude,
                            longitude: _pickupLongitude,
                            isLocating: _isLocatingPickup,
                            isPickup: true,
                            onLocationChanged: (lat, lng) {
                              setState(() {
                                _pickupLatitude = lat;
                                _pickupLongitude = lng;
                              });
                            },
                            onGpsPressed: () async {
                              setState(() => _isLocatingPickup = true);
                              try {
                                final pos = await sl<LocationService>()
                                    .getCurrentLocation();
                                if (pos != null && mounted) {
                                  setState(() {
                                    _pickupLatitude = pos.latitude;
                                    _pickupLongitude = pos.longitude;
                                  });
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isLocatingPickup = false);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // Rider-Specific: CNIC (optional) + Driving License & Bike Papers Photos (REQUIRED)
                    if (isRider) ...[
                      AppTextField(
                        controller: _cnicController,
                        label: l10n.cnicNumberLabel,
                        hint: l10n.cnicNumberHint,
                        prefixIcon: Icons.badge_outlined,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: DocumentUploadTile(
                              title: l10n.drivingLicenseLabel,
                              icon: Icons.credit_card_rounded,
                              pickedImage: _drivingLicensePhoto,
                              onTap: () => _showDocumentPickerSheet(
                                isDrivingLicense: true,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: DocumentUploadTile(
                              title: l10n.bikePapersLabel,
                              icon: Icons.description_outlined,
                              pickedImage: _bikePapersPhoto,
                              onTap: () => _showDocumentPickerSheet(
                                isDrivingLicense: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // Password
                    AppTextField(
                      controller: _passwordController,
                      label: l10n.passwordLabel,
                      hint: l10n.passwordHint,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: InputValidators.validatePassword,
                    ),
                    SizedBox(height: 14.h),

                    Text(
                      l10n.otpNotice,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 14.h),

                    AppButton(
                      text: isRider
                          ? l10n.registerSubmitRider
                          : l10n.registerSubmitSender,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    SizedBox(height: 14.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.alreadyRegisteredPrompt,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.goNamed(RouteNames.login),
                          child: Text(
                            l10n.signIn,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RoleSelectorTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleSelectorTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.charcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
