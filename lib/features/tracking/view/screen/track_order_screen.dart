import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/features/authentication/bloc/auth_bloc.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';
import 'package:delivery_app/features/tracking/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/tracking/bloc/tracking_event.dart';
import 'package:delivery_app/features/tracking/bloc/tracking_state.dart';
import 'package:delivery_app/features/tracking/view/widgets/order_selector_bar.dart';
import 'package:delivery_app/features/tracking/view/widgets/delivery_map_widget.dart';
import 'package:delivery_app/features/tracking/view/widgets/status_timeline_widget.dart';
import 'package:delivery_app/features/tracking/view/widgets/role_contact_panel.dart';
import 'package:delivery_app/features/orders/view/widgets/order_item_tile.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/shared/widgets/loading_indicator.dart';
import 'package:delivery_app/shared/widgets/empty_state_view.dart';
import 'package:delivery_app/shared/widgets/error_view.dart';

class TrackOrderScreen extends StatefulWidget {
  final String? initialOrderId;

  const TrackOrderScreen({super.key, this.initialOrderId});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TrackingBloc>().add(LoadTrackableOrdersEvent(initialOrderId: widget.initialOrderId));
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthBloc>().state.user;
    final userRole = authUser?.role ?? UserRole.customer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Delivery Tracking'),
        elevation: 0,
        actions: [
          BlocBuilder<TrackingBloc, TrackingState>(
            builder: (context, state) {
              if (state.selectedOrder == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi, size: 14, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          if (state.status == TrackingStatus.loading) {
            return const LoadingIndicator(message: 'Connecting to live delivery stream...');
          }

          if (state.status == TrackingStatus.error) {
            return ErrorView(
              message: state.errorMessage ?? 'Could not load tracking data.',
              onRetry: () {
                context.read<TrackingBloc>().add(LoadTrackableOrdersEvent(initialOrderId: widget.initialOrderId));
              },
            );
          }

          if (state.orders.isEmpty || state.selectedOrder == null) {
            return const EmptyStateView(
              icon: Icons.local_shipping_outlined,
              title: 'No Active Deliveries',
              message: 'You have no orders currently in transit to track.',
            );
          }

          final order = state.selectedOrder!;

          return Column(
            children: [
              // ORDER SELECTOR BAR
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: OrderSelectorBar(
                  orders: state.orders,
                  selectedOrderId: order.id,
                  onOrderSelected: (id) {
                    context.read<TrackingBloc>().add(SelectOrderForTrackingEvent(id));
                  },
                ),
              ),

              // EXPANDED BODY WITH MAP AND BOTTOM SHEET DETAILS
              Expanded(
                child: Stack(
                  children: [
                    // LIVE MAP VIEW
                    Positioned.fill(
                      child: DeliveryMapWidget(
                        key: ValueKey('map_${order.id}'),
                        order: order,
                        liveRiderLocation: state.liveRiderLocation,
                      ),
                    ),

                    // DRAGGABLE SCROLLABLE SHEET FOR DETAILS
                    DraggableScrollableSheet(
                      initialChildSize: 0.45,
                      minChildSize: 0.22,
                      maxChildSize: 0.85,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Drag Handle
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBorder,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ORDER NUMBER & ETA HEADER
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.orderNumber,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Assigned: ${order.rider?.name ?? "Waiting for proximity assignment"}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (order.eta != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withAlpha(30),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.timer_outlined, size: 16, color: AppColors.accent),
                                            const SizedBox(width: 4),
                                            Text(
                                              order.eta!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // STATUS TIMELINE
                                StatusTimelineWidget(currentStatus: order.status),
                                const SizedBox(height: 16),

                                // ROLE-AWARE CALL BUTTONS PANEL
                                RoleContactPanel(
                                  currentUserRole: userRole,
                                  order: order,
                                ),
                                const SizedBox(height: 20),

                                // ORDER ITEMS
                                const Text(
                                  'Package Contents',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 8),
                                ...order.items.map((item) => OrderItemTile(item: item)),

                                if (order.riderNote != null && order.riderNote!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.notes, size: 18, color: AppColors.textSecondary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Note: "${order.riderNote}"',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
