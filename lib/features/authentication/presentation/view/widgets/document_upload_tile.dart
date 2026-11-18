import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/service/document_picker_service.dart';

class DocumentUploadTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final PickedDocumentImage? pickedImage;
  final VoidCallback onTap;

  const DocumentUploadTile({
    super.key,
    required this.title,
    required this.icon,
    required this.pickedImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = pickedImage != null;
    final hasLocalFile =
        hasImage && !pickedImage!.isDemoSample && !kIsWeb && File(pickedImage!.path).existsSync();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 112.h,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: hasImage
              ? AppColors.success.withAlpha(14)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasImage ? AppColors.success : AppColors.textSecondary,
            width: 1.5,
          ),
        ),
        child: hasLocalFile
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.file(
                      File(pickedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 4.h,
                    left: 4.w,
                    right: 4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal.withAlpha(210),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '$title • ${l10n.changePhoto}',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasImage ? Icons.check_circle_rounded : icon,
                    color: hasImage ? AppColors.success : AppColors.charcoal,
                    size: 26.sp,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    hasImage ? l10n.photoAdded : l10n.addPhoto,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: hasImage
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
