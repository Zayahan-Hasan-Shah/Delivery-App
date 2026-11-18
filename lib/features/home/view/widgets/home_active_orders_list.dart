import 'package:material_ui/material_ui.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/shared/widgets/status_chip.dart';

class HomeActiveOrdersList extends StatelessWidget {
  final List<OrderModel> orders;
  final ValueChanged<OrderModel> onOrderTapped;

  const HomeActiveOrdersList({
    super.key,
    required this.orders,
    required this.onOrderTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        alignment: Alignment.center,
        child: const Text(
          'No orders currently in progress.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    return Column(
      children: orders.map((order) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onOrderTapped(order),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      StatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.trip_origin, size: 14, color: AppColors.primaryLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.pickup.contactName,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      const Icon(Icons.pin_drop, size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.dropoff.contactName,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (order.eta != null || order.rider != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (order.rider != null)
                          Row(
                            children: [
                              const Icon(Icons.two_wheeler, size: 14, color: AppColors.primaryLight),
                              const SizedBox(width: 4),
                              Text(
                                order.rider!.name,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),
                        if (order.eta != null)
                          Text(
                            order.eta!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
