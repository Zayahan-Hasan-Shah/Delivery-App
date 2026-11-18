import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/features/rider/bloc/rider_orders_bloc.dart';
import 'package:delivery_app/features/rider/bloc/rider_orders_event.dart';
import 'package:delivery_app/features/rider/bloc/rider_orders_state.dart';
import 'package:delivery_app/features/rider/view/widgets/order_filter_chips.dart';
import 'package:delivery_app/features/rider/view/widgets/rider_order_card.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/shared/widgets/loading_indicator.dart';
import 'package:delivery_app/shared/widgets/empty_state_view.dart';
import 'package:delivery_app/shared/widgets/error_view.dart';
import 'package:delivery_app/shared/routing/route_names.dart';

class RiderOrdersScreen extends StatefulWidget {
  const RiderOrdersScreen({super.key});

  @override
  State<RiderOrdersScreen> createState() => _RiderOrdersScreenState();
}

class _RiderOrdersScreenState extends State<RiderOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RiderOrdersBloc>().add(const LoadRiderOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Deliveries'),
        elevation: 0,
      ),
      body: BlocBuilder<RiderOrdersBloc, RiderOrdersState>(
        builder: (context, state) {
          if (state.status == RiderOrdersStatus.loading) {
            return const LoadingIndicator(message: 'Loading assigned deliveries...');
          }

          if (state.status == RiderOrdersStatus.error) {
            return ErrorView(
              message: state.errorMessage ?? 'Unable to fetch orders.',
              onRetry: () => context.read<RiderOrdersBloc>().add(const LoadRiderOrdersEvent()),
            );
          }

          return Column(
            children: [
              // Filter Chips
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: OrderFilterChips(
                  activeFilter: state.activeFilter,
                  onFilterChanged: (filter) {
                    context.read<RiderOrdersBloc>().add(FilterRiderOrdersEvent(filter));
                  },
                ),
              ),

              // Orders List
              Expanded(
                child: state.filteredOrders.isEmpty
                    ? EmptyStateView(
                        icon: Icons.assignment_outlined,
                        title: 'No Orders Found',
                        message: 'No deliveries currently matching "${state.activeFilter}".',
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          context.read<RiderOrdersBloc>().add(const LoadRiderOrdersEvent());
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = state.filteredOrders[index];
                            return RiderOrderCard(
                              order: order,
                              onTap: () {
                                context.pushNamed(
                                  RouteNames.trackOrder,
                                  queryParameters: {'orderId': order.id},
                                );
                              },
                              onAdvanceStatus: (nextStatus) {
                                context.read<RiderOrdersBloc>().add(
                                      UpdateRiderOrderStatusEvent(
                                        orderId: order.id,
                                        newStatus: nextStatus.name,
                                      ),
                                    );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
