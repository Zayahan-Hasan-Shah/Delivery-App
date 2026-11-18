import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/order_color_helper.dart';
import 'package:delivery_app/features/rider/presentation/bloc/bloc/rider_orders_bloc.dart';
import 'package:delivery_app/features/rider/presentation/bloc/event/rider_orders_event.dart';
import 'package:delivery_app/features/rider/presentation/bloc/state/rider_orders_state.dart';
import 'package:delivery_app/features/rider/presentation/view/widgets/rider_multi_order_map.dart';
import 'package:delivery_app/features/rider/presentation/view/widgets/rider_order_card.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
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
    context.read<RiderOrdersBloc>().add(const LoadRiderDashboardEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.multiOrderLiveMap)),
      body: BlocBuilder<RiderOrdersBloc, RiderOrdersState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<RiderOrdersBloc>().add(
                    LoadRiderDashboardEvent(initialOnline: state.isOnline),
                  );
            },
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                RiderMultiOrderMap(
                  activeOrders: state.activeOrders,
                  orderColors: state.orderColors,
                  riderLatitude: state.riderLatitude,
                  riderLongitude: state.riderLongitude,
                  selectedOrderId: state.selectedOrderId,
                  isLiveTracking: state.isBackgroundTrackingActive,
                  onOrderFocus: (id) {
                    context
                        .read<RiderOrdersBloc>()
                        .add(SelectRiderOrderOnMapEvent(id));
                  },
                  onOrderTap: (order) async {
                    final color = state.orderColors[order.id] ??
                        OrderColorHelper.colorForOrderId(
                          order.id,
                          colorIndex: order.colorIndex,
                        );
                    await context.pushNamed(
                      RouteNames.orderDetails,
                      extra: {'order': order, 'color': color},
                    );
                    if (context.mounted) {
                      context.read<RiderOrdersBloc>().add(
                            LoadRiderDashboardEvent(
                              initialOnline: state.isOnline,
                            ),
                          );
                    }
                  },
                ),
                SizedBox(height: 16.h),
                ...state.activeOrders.map((order) {
                  final color = state.orderColors[order.id] ??
                      OrderColorHelper.colorForOrderId(
                        order.id,
                        colorIndex: order.colorIndex,
                      );
                  return RiderOrderCard(
                    order: order,
                    orderColor: color,
                    isHighlighted: state.selectedOrderId == order.id,
                    onTap: () async {
                      await context.pushNamed(
                        RouteNames.orderDetails,
                        extra: {'order': order, 'color': color},
                      );
                      if (context.mounted) {
                        context.read<RiderOrdersBloc>().add(
                              LoadRiderDashboardEvent(
                                initialOnline: state.isOnline,
                              ),
                            );
                      }
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
