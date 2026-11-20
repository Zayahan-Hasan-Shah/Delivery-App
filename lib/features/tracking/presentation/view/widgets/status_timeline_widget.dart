import 'package:material_ui/material_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/l10n/app_localizations.dart';

class StatusTimelineWidget extends StatelessWidget {
  final OrderStatus currentStatus;

  const StatusTimelineWidget({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stages = [
      (OrderStatus.assigned, l10n.statusAssigned),
      (OrderStatus.pickedUp, l10n.statusPickedUp),
      (OrderStatus.onTheWay, l10n.statusOnTheWay),
      (OrderStatus.delivered, l10n.statusDelivered),
    ];

    final currentIndex = currentStatus.timelineOrder;

    return Column(
      children: [
        Row(
          children: List.generate(stages.length, (i) {
            final active = currentIndex >= stages[i].$1.timelineOrder;
            return Expanded(
              child: Container(
                height: 6.h,
                margin: EdgeInsets.only(right: i < stages.length - 1 ? 6.w : 0),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stages.map((stage) {
            final active = currentIndex >= stage.$1.timelineOrder;
            return Text(
              stage.$2,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
