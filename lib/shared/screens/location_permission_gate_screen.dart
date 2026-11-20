import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/service/location_gate_cubit.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/widgets/language_toggle_pill.dart';

class LocationPermissionGateScreen extends StatefulWidget {
  const LocationPermissionGateScreen({super.key});

  @override
  State<LocationPermissionGateScreen> createState() =>
      _LocationPermissionGateScreenState();
}

class _LocationPermissionGateScreenState
    extends State<LocationPermissionGateScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LocationGateCubit>().checkAndRequestOnStartup();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check automatically when returning from Android/iOS Settings
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<LocationGateCubit>().recheckStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false, // Mandatory gate — cannot dismiss or skip
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<LocationGateCubit, LocationGateState>(
            builder: (context, state) {
              final isGpsOff = state.status == LocationAccessStatus.gpsDisabled;
              final isDeniedForever =
                  state.status == LocationAccessStatus.deniedForever;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar with Brand & Language Switcher
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.brandShort,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const LanguageTogglePill(),
                      ],
                    ),
                    const Spacer(),

                    // Center icon & explanation
                    Center(
                      child: Container(
                        width: 96.w,
                        height: 96.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(24),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withAlpha(60),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          isGpsOff
                              ? Icons.gps_off_rounded
                              : Icons.location_on_rounded,
                          size: 46.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      isGpsOff
                          ? l10n.locationGpsDisabledTitle
                          : l10n.locationGateTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      isGpsOff
                          ? l10n.locationGpsDisabledSubtitle
                          : isDeniedForever
                              ? l10n.locationDeniedForeverSubtitle
                              : l10n.locationGateSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Mandatory warning badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(18),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.error.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.error,
                            size: 20.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              l10n.locationGateMandatoryNote,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Primary CTA
                    if (isGpsOff)
                      AppButton(
                        text: l10n.openLocationSettings,
                        icon: Icons.settings_outlined,
                        isLoading: state.isChecking,
                        onPressed: () async {
                          await context
                              .read<LocationGateCubit>()
                              .openLocationSettings();
                        },
                      )
                    else if (isDeniedForever)
                      AppButton(
                        text: l10n.openAppSettings,
                        icon: Icons.settings_applications_outlined,
                        isLoading: state.isChecking,
                        onPressed: () async {
                          await context
                              .read<LocationGateCubit>()
                              .openAppSettings();
                        },
                      )
                    else
                      AppButton(
                        text: l10n.allowLocationPermission,
                        icon: Icons.my_location_rounded,
                        isLoading: state.isChecking,
                        onPressed: () {
                          context.read<LocationGateCubit>().requestPermission();
                        },
                      ),

                    SizedBox(height: 10.h),
                    TextButton.icon(
                      onPressed: state.isChecking
                          ? null
                          : () => context
                              .read<LocationGateCubit>()
                              .recheckStatus(),
                      icon: Icon(Icons.refresh_rounded, size: 18.sp),
                      label: Text(l10n.retry),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
