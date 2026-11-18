import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/core/localization/locale_cubit.dart';
import 'package:delivery_app/core/theme/app_colors.dart';

class LanguageTogglePill extends StatelessWidget {
  const LanguageTogglePill({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final isEnglish = locale.languageCode == 'en';
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            height: 36.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.charcoal, width: 1.5),
              borderRadius: BorderRadius.circular(20.r),
              color: Colors.transparent,
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LangButton(
                  label: 'EN',
                  isSelected: isEnglish,
                  onTap: () =>
                      context.read<LocaleCubit>().setLocale(const Locale('en')),
                ),
                _LangButton(
                  label: 'اردو',
                  isSelected: !isEnglish,
                  onTap: () =>
                      context.read<LocaleCubit>().setLocale(const Locale('ur')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: Alignment.center,
        color: isSelected ? AppColors.charcoal : Colors.transparent,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.charcoal,
          ),
        ),
      ),
    );
  }
}
