import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/formatters.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/widgets/status_chip.dart';

class RiderOrderCard extends StatelessWidget {
  final OrderEntity order;
  final Color orderColor;
  final bool isHighlighted;
  final VoidCallback onTap;

  const RiderOrderCard({
    super.key,
    required this.order,
    required this.orderColor,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isHighlighted ? orderColor : AppColors.cardBorder,
            width: isHighlighted ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? orderColor.withAlpha(35)
                  : Colors.black.withAlpha(10),
              blurRadius: isHighlighted ? 10 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Unique Order Color Indicator Strip matching map pins & route
              Container(width: 7.w, color: orderColor),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(14.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Color Dot + Order # + Distance + Status Chip
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: orderColor.withAlpha(24),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: orderColor.withAlpha(90),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: orderColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  order.orderNumber,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                    color: orderColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${order.distanceKm} km',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          StatusChip(status: order.status),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Pickup line
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: 15.sp,
                            color: orderColor,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              '${l10n.pickupLabel}: ${order.pickup.contactName} • ${order.pickup.addressText}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),

                      // Drop-off line
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            size: 15.sp,
                            color: orderColor,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              '${l10n.dropoffLabel}: ${order.dropoff.contactName} • ${order.dropoff.addressText}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      // Footer: COD + Rider Share + Chevron
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'COD ${Formatters.formatCurrency(order.codAmountPkr)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${l10n.riderShare}: ${Formatters.formatCurrency(order.riderSharePkr)}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18.sp,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
