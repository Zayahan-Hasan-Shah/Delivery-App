import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/formatters.dart';
import 'package:delivery_app/l10n/app_localizations.dart';

class CashInHandBar extends StatelessWidget {
  final double cashInHandPkr;
  final double limitPkr;

  const CashInHandBar({
    super.key,
    required this.cashInHandPkr,
    required this.limitPkr,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ratio =
        limitPkr <= 0 ? 0.0 : (cashInHandPkr / limitPkr).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.cashInHand,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${Formatters.formatCurrency(cashInHandPkr)} / ${Formatters.formatCurrency(limitPkr)}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 7.h,
            backgroundColor: AppColors.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(
              ratio > 0.85 ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
