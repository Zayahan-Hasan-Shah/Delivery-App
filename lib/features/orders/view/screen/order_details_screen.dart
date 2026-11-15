import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/orders/view/widgets/order_item_tile.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/formatters.dart';
import 'package:delivery_app/shared/widgets/status_chip.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/routing/route_names.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(order.orderNumber),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: StatusChip(status: order.status),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Track Live Delivery CTA
            if (order.status.isActive) ...[
              AppButton(
                text: 'Track Order Live on Map',
                icon: Icons.map,
                onPressed: () {
                  context.pushNamed(
                    RouteNames.trackOrder,
                    queryParameters: {'orderId': order.id},
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // ROUTE CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Route',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.trip_origin, color: AppColors.primaryLight, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.pickup.contactName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Text(
                                order.pickup.contactPhone,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              if (order.pickup.address.isNotEmpty)
                                Text(
                                  order.pickup.address,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 9.0),
                      child: SizedBox(
                        height: 24,
                        child: VerticalDivider(color: AppColors.cardBorder, thickness: 2),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.pin_drop, color: AppColors.success, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.dropoff.contactName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Text(
                                order.dropoff.contactPhone,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              if (order.dropoff.address.isNotEmpty)
                                Text(
                                  order.dropoff.address,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ASSIGNED RIDER CARD (if assigned)
            if (order.rider != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryLight.withAlpha(38),
                        child: const Icon(Icons.two_wheeler, color: AppColors.primaryLight),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assigned Courier',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Text(
                              order.rider!.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              order.rider!.phone,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ITEMS CARD
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Items (${order.items.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map((item) => OrderItemTile(item: item)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // RIDER NOTE
            if (order.riderNote != null && order.riderNote!.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Note for Courier',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.riderNote!,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // STATUS HISTORY TIMELINE
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status Timeline History',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    if (order.statusHistory.isEmpty)
                      const Text('No status events recorded yet.')
                    else
                      ...order.statusHistory.map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: h.status.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      h.status.displayName,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    if (h.note != null)
                                      Text(
                                        h.note!,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                Formatters.formatTime(h.timestamp),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
