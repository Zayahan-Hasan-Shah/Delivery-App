import 'package:flutter/material.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/orders/model/order_status.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/formatters.dart';
import 'package:delivery_app/shared/widgets/status_chip.dart';

class RiderOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final void Function(OrderStatus nextStatus)? onAdvanceStatus;

  const RiderOrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onAdvanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    OrderStatus? nextStatus;
    String? nextActionLabel;

    if (order.status == OrderStatus.assigned) {
      nextStatus = OrderStatus.pickedUp;
      nextActionLabel = 'Confirm Pickup';
    } else if (order.status == OrderStatus.pickedUp || order.status == OrderStatus.onTheWay) {
      nextStatus = OrderStatus.delivered;
      nextActionLabel = 'Confirm Delivery';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order # + Status + ETA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.inventory_2, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  StatusChip(status: order.status),
                ],
              ),
              const Divider(height: 24),

              // Locations
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.trip_origin, size: 16, color: AppColors.primaryLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pickup',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${order.pickup.contactName} • ${order.pickup.address.isNotEmpty ? order.pickup.address : order.pickup.contactPhone}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 7.0),
                child: SizedBox(
                  height: 14,
                  child: VerticalDivider(color: AppColors.cardBorder, thickness: 1.5),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.pin_drop, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Drop-off',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${order.dropoff.contactName} • ${order.dropoff.address.isNotEmpty ? order.dropoff.address : order.dropoff.contactPhone}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Footer: Time and Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formatters.formatTime(order.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (nextStatus != null && nextActionLabel != null && onAdvanceStatus != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        backgroundColor: AppColors.primaryLight,
                      ),
                      onPressed: () => onAdvanceStatus!(nextStatus!),
                      child: Text(nextActionLabel, style: const TextStyle(fontSize: 12)),
                    )
                  else
                    const Row(
                      children: [
                        Text('View Details', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
