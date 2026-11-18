import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/formatters.dart';
import 'package:delivery_app/core/utils/order_color_helper.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/rider/presentation/bloc/event/rider_orders_event.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/widgets/status_chip.dart';

class RiderDeliveryLogView extends StatelessWidget {
  final List<OrderEntity> orders;
  final Map<String, Color> orderColors;
  final RiderOrderFilter activeFilter;
  final ValueChanged<RiderOrderFilter> onFilterChanged;
  final ValueChanged<OrderEntity> onOrderTap;

  const RiderDeliveryLogView({
    super.key,
    required this.orders,
    required this.orderColors,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter chips
        Row(
          children: [
            _FilterPill(
              label: l10n.filterAll,
              selected: activeFilter == RiderOrderFilter.all,
              onTap: () => onFilterChanged(RiderOrderFilter.all),
            ),
            SizedBox(width: 8.w),
            _FilterPill(
              label: l10n.filterActive,
              selected: activeFilter == RiderOrderFilter.active,
              onTap: () => onFilterChanged(RiderOrderFilter.active),
            ),
            SizedBox(width: 8.w),
            _FilterPill(
              label: l10n.filterDelivered,
              selected: activeFilter == RiderOrderFilter.delivered,
              onTap: () => onFilterChanged(RiderOrderFilter.delivered),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        if (orders.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(
                l10n.noActiveOrders,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final order = orders[index];
                final color = orderColors[order.id] ??
                    OrderColorHelper.colorForOrderId(
                      order.id,
                      colorIndex: order.colorIndex,
                    );

                return ListTile(
                  onTap: () => onOrderTap(order),
                  leading: Container(
                    width: 12.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  title: Text(
                    '${order.orderNumber} • ${order.dropoff.contactName}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${Formatters.formatTime(order.createdAt)} • ${order.dropoff.addressText}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatCurrency(order.codAmountPkr),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      StatusChip(status: order.status),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.charcoal : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.charcoal : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
