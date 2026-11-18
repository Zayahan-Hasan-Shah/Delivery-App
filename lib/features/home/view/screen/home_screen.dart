import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/features/authentication/bloc/auth_bloc.dart';
import 'package:delivery_app/features/authentication/bloc/auth_event.dart';
import 'package:delivery_app/features/authentication/view/widgets/role_badge.dart';
import 'package:delivery_app/features/authentication/model/user_role.dart';
import 'package:delivery_app/features/home/bloc/home_bloc.dart';
import 'package:delivery_app/features/home/bloc/home_event.dart';
import 'package:delivery_app/features/home/bloc/home_state.dart';
import 'package:delivery_app/features/home/view/widgets/summary_card.dart';
import 'package:delivery_app/features/home/view/widgets/home_active_orders_list.dart';
import 'package:delivery_app/features/home/view/widgets/earnings_card.dart';
import 'package:delivery_app/features/rider/bloc/rider_orders_bloc.dart';
import 'package:delivery_app/features/rider/bloc/rider_orders_event.dart';
import 'package:delivery_app/features/rider/bloc/rider_orders_state.dart';
import 'package:delivery_app/features/tracking/view/widgets/delivery_map_widget.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/widgets/loading_indicator.dart';
import 'package:delivery_app/shared/widgets/error_view.dart';
import 'package:delivery_app/shared/routing/route_names.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRiderOnline = true;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeDashboardEvent());

    final user = context.read<AuthBloc>().state.user;
    if (user?.role == UserRole.rider) {
      context.read<RiderOrdersBloc>().add(const LoadRiderOrdersEvent());
      _setRiderTracking(true);
    }
  }

  void _setRiderTracking(bool online) {
    setState(() {
      _isRiderOnline = online;
    });
    final locationService = sl<LocationService>();
    if (online) {
      locationService.startTracking();
    } else {
      locationService.stopTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final role = user?.role ?? UserRole.customer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getRoleColor(role).withAlpha(38),
              child: Icon(_getRoleIcon(role), color: _getRoleColor(role), size: 20.r),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Delivery Portal',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                RoleBadge(role: role),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            tooltip: 'Log Out',
            onPressed: () {
              if (role == UserRole.rider) {
                _setRiderTracking(false);
              }
              context.read<AuthBloc>().add(const LogoutRequestedEvent());
              context.goNamed(RouteNames.login);
            },
          ),
        ],
      ),
      // Role-based Floating Action Button: Only Customer can create orders
      floatingActionButton: role == UserRole.customer
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Send Package'),
              onPressed: () => context.pushNamed(RouteNames.newOrder),
            )
          : null,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          if (role == UserRole.rider) {
            return BlocBuilder<RiderOrdersBloc, RiderOrdersState>(
              builder: (context, riderState) {
                return _buildDashboardContent(context, homeState, role, riderState: riderState);
              },
            );
          }
          return _buildDashboardContent(context, homeState, role);
        },
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    HomeState homeState,
    UserRole role, {
    RiderOrdersState? riderState,
  }) {
    if (homeState.status == HomeStatus.loading ||
        (role == UserRole.rider && riderState?.status == RiderOrdersStatus.loading)) {
      return const LoadingIndicator(message: 'Loading dashboard...');
    }

    if (homeState.status == HomeStatus.error) {
      return ErrorView(
        message: homeState.errorMessage ?? 'Unable to load dashboard.',
        onRetry: () {
          context.read<HomeBloc>().add(const LoadHomeDashboardEvent());
          if (role == UserRole.rider) {
            context.read<RiderOrdersBloc>().add(const LoadRiderOrdersEvent());
          }
        },
      );
    }

    final summary = homeState.summary;
    final ordersList = role == UserRole.rider && riderState != null
        ? riderState.allOrders.where((o) => o.status.isActive).toList()
        : homeState.orders;

    final activeOrder = ordersList.where((o) => o.status.isActive).isNotEmpty
        ? ordersList.firstWhere((o) => o.status.isActive)
        : null;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const RefreshHomeDashboardEvent());
        if (role == UserRole.rider) {
          context.read<RiderOrdersBloc>().add(const LoadRiderOrdersEvent());
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RIDER ONLY: Duty status toggle and earnings summary
            if (role == UserRole.rider) ...[
              _buildRiderDutySwitch(),
              SizedBox(height: 16.h),
              if (riderState?.earnings != null) ...[
                EarningsCard(earnings: riderState!.earnings!),
                SizedBox(height: 16.h),
              ],
            ],

            // ROLE-BASED SUMMARY CARDS (Shared Component)
            Row(
              children: [
                SummaryCard(
                  title: _getSummaryTitle1(role),
                  count: summary?.onRoadCount ?? 0,
                  icon: role == UserRole.rider ? Icons.two_wheeler : Icons.local_shipping_outlined,
                  color: AppColors.statusOnTheWay,
                ),
                SizedBox(width: 10.w),
                SummaryCard(
                  title: _getSummaryTitle2(role),
                  count: summary?.waitingCount ?? 0,
                  icon: role == UserRole.rider ? Icons.assignment_late_outlined : Icons.hourglass_top,
                  color: AppColors.accent,
                ),
                SizedBox(width: 10.w),
                SummaryCard(
                  title: _getSummaryTitle3(role),
                  count: summary?.deliveredCount ?? 0,
                  icon: Icons.check_circle_outline,
                  color: AppColors.statusDelivered,
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // LIVE MAP PREVIEW OF ACTIVE ORDER
            if (activeOrder != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getMapSectionTitle(role),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(
                        RouteNames.trackOrder,
                        queryParameters: {'orderId': activeOrder.id},
                      );
                    },
                    child: const Text('Live Tracking'),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Card(
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 200.h,
                  child: DeliveryMapWidget(
                    order: activeOrder,
                    liveRiderLocation: activeOrder.riderLocation,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],

            // ORDERS LIST SECTION (Role contextualized)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getOrderSectionTitle(role),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                if (role == UserRole.rider)
                  TextButton(
                    onPressed: () => context.pushNamed(RouteNames.riderOrders),
                    child: const Text('All Deliveries'),
                  )
                else if (ordersList.isNotEmpty)
                  TextButton(
                    onPressed: () => context.pushNamed(RouteNames.trackOrder),
                    child: const Text('Track All'),
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            HomeActiveOrdersList(
              orders: ordersList,
              onOrderTapped: (order) {
                context.pushNamed(
                  RouteNames.trackOrder,
                  queryParameters: {'orderId': order.id},
                );
              },
            ),
            SizedBox(height: role == UserRole.customer ? 80.h : 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRiderDutySwitch() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _isRiderOnline ? AppColors.success.withAlpha(26) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _isRiderOnline ? AppColors.success.withAlpha(77) : AppColors.cardBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12.r,
                height: 12.r,
                decoration: BoxDecoration(
                  color: _isRiderOnline ? AppColors.success : AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRiderOnline ? 'Online & Available' : 'Offline',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _isRiderOnline ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _isRiderOnline ? 'Receiving proximity delivery assignments' : 'GPS tracking paused',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isRiderOnline,
            activeThumbColor: AppColors.success,
            onChanged: _setRiderTracking,
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return AppColors.primaryLight;
      case UserRole.client:
        return AppColors.accent;
      case UserRole.rider:
        return AppColors.success;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.person;
      case UserRole.client:
        return Icons.storefront;
      case UserRole.rider:
        return Icons.two_wheeler;
    }
  }

  String _getSummaryTitle1(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'On Road';
      case UserRole.client:
        return 'Dispatched';
      case UserRole.rider:
        return 'Active Trips';
    }
  }

  String _getSummaryTitle2(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Waiting';
      case UserRole.client:
        return 'Processing';
      case UserRole.rider:
        return 'Pending';
    }
  }

  String _getSummaryTitle3(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Delivered';
      case UserRole.client:
        return 'Completed';
      case UserRole.rider:
        return 'Completed';
    }
  }

  String _getMapSectionTitle(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Live Package in Transit';
      case UserRole.client:
        return 'Active Store Fulfillment';
      case UserRole.rider:
        return 'Current Active Assignment';
    }
  }

  String _getOrderSectionTitle(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Recent Deliveries';
      case UserRole.client:
        return 'Store Orders';
      case UserRole.rider:
        return 'Assigned Orders Queue';
    }
  }
}
