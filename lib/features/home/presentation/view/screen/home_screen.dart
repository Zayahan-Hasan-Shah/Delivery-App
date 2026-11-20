import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/order_color_helper.dart';
import 'package:delivery_app/features/authentication/domain/entities/user_entity.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/bloc/auth_bloc.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/event/auth_event.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/state/auth_state.dart';
import 'package:delivery_app/features/authentication/presentation/view/widgets/role_badge.dart';
import 'package:delivery_app/features/home/presentation/bloc/bloc/home_bloc.dart';
import 'package:delivery_app/features/home/presentation/bloc/event/home_event.dart';
import 'package:delivery_app/features/home/presentation/bloc/state/home_state.dart';
import 'package:delivery_app/features/home/presentation/view/widgets/cash_in_hand_bar.dart';
import 'package:delivery_app/features/home/presentation/view/widgets/sender_order_tile.dart';
import 'package:delivery_app/features/home/presentation/view/widgets/summary_card.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/rider/presentation/bloc/bloc/rider_orders_bloc.dart';
import 'package:delivery_app/features/rider/presentation/bloc/event/rider_orders_event.dart';
import 'package:delivery_app/features/rider/presentation/bloc/state/rider_orders_state.dart';
import 'package:delivery_app/features/rider/presentation/view/widgets/rider_delivery_log_view.dart';
import 'package:delivery_app/features/rider/presentation/view/widgets/rider_earnings_view.dart';
import 'package:delivery_app/features/rider/presentation/view/widgets/rider_multi_order_map.dart';
import 'package:delivery_app/features/rider/presentation/view/widgets/rider_order_card.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/routing/route_names.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/widgets/empty_state_view.dart';
import 'package:delivery_app/shared/widgets/language_toggle_pill.dart';
import 'package:delivery_app/shared/widgets/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _riderTabIndex = 0; // 0: Active Map & Orders, 1: Log, 2: Earnings
  String? _selectedSenderOrderId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoleData());
  }

  void _loadRoleData() {
    if (!mounted) return;
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    if (user.role.isRider) {
      context.read<RiderOrdersBloc>().add(
            LoadRiderDashboardEvent(initialOnline: user.isOnline),
          );
    } else {
      context.read<HomeBloc>().add(
            LoadHomeDashboardEvent(role: user.role, userId: user.id),
          );
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(90.w, 40.h),
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final user = context.read<AuthBloc>().state.user;
      if (user?.role.isRider == true) {
        context
            .read<RiderOrdersBloc>()
            .add(const ToggleRiderOnlineShiftEvent(false));
      }
      context.read<AuthBloc>().add(const LogoutRequestedEvent());
    }
  }

  Future<void> _openOrderDetails(
    OrderEntity order, {
    Color? assignedColor,
    required bool isRider,
    bool riderOnline = true,
  }) async {
    await context.pushNamed(
      RouteNames.orderDetails,
      extra: {'order': order, 'color': assignedColor},
    );
    if (!mounted) return;
    if (isRider) {
      context
          .read<RiderOrdersBloc>()
          .add(LoadRiderDashboardEvent(initialOnline: riderOnline));
    } else {
      _loadRoleData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        if (user == null) {
          return const Scaffold(body: LoadingIndicator());
        }

        final isRider = user.role.isRider;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            titleSpacing: 16.w,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRider ? l10n.riderDashboard : l10n.senderDashboard,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.helloUser(user.name),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            actions: [
              const Center(child: LanguageTogglePill()),
              IconButton(
                tooltip: l10n.logout,
                onPressed: () => _confirmLogout(context),
                icon: Icon(
                  Icons.logout_rounded,
                  color: AppColors.textSecondary,
                  size: 21.sp,
                ),
              ),
              SizedBox(width: 4.w),
            ],
          ),
          body: isRider
              ? _buildRiderBody(context, user, l10n)
              : _buildSenderBody(context, user, l10n),
          bottomNavigationBar: isRider
              ? NavigationBar(
                  selectedIndex: _riderTabIndex,
                  backgroundColor: AppColors.surface,
                  indicatorColor: AppColors.primary.withAlpha(28),
                  onDestinationSelected: (idx) {
                    setState(() => _riderTabIndex = idx);
                  },
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.map_outlined),
                      selectedIcon: const Icon(
                        Icons.map_rounded,
                        color: AppColors.primary,
                      ),
                      label: l10n.tabMapOrders,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.receipt_long_outlined),
                      selectedIcon: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primary,
                      ),
                      label: l10n.tabDeliveryLog,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      selectedIcon: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                      ),
                      label: l10n.tabEarnings,
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  // ==================== SENDER VIEW ====================
  Widget _buildSenderBody(
    BuildContext context,
    UserEntity user,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final summary = state.summary;
        final activeOrders = summary?.activeOrders ?? const <OrderEntity>[];
        final senderOrderColors = OrderColorHelper.buildColorMap(
          activeOrders.map((o) => o.id).toList(),
        );

        return RefreshIndicator(
          onRefresh: () async => _loadRoleData(),
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Sender Restaurant Banner Card + Primary Actions
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (user.pickupAddress?.isNotEmpty == true ||
                                    user.restaurantAddress?.isNotEmpty == true)
                                  Text(
                                    user.pickupAddress ??
                                        user.restaurantAddress!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          RoleBadge(role: user.role),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppButton(
                              text: l10n.createDelivery,
                              icon: Icons.add_box_rounded,
                              onPressed: () async {
                                await context.pushNamed(RouteNames.newOrder);
                                if (mounted) _loadRoleData();
                              },
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.fromHeight(52.h),
                              ),
                              onPressed: () =>
                                  context.pushNamed(RouteNames.trackOrder),
                              child: Text(
                                l10n.trackOrder,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // SENDER LIVE MULTI-ORDER COLOR-CODED MAP
              if (activeOrders.isNotEmpty) ...[
                RiderMultiOrderMap(
                  activeOrders: activeOrders,
                  orderColors: senderOrderColors,
                  selectedOrderId: _selectedSenderOrderId,
                  isLiveTracking: true,
                  isSenderMode: true,
                  onOrderFocus: (orderId) {
                    setState(() => _selectedSenderOrderId = orderId);
                  },
                  onOrderTap: (order) {
                    final color = senderOrderColors[order.id] ??
                        OrderColorHelper.colorForOrderId(
                          order.id,
                          colorIndex: order.colorIndex,
                        );
                    _openOrderDetails(
                      order,
                      assignedColor: color,
                      isRider: false,
                    );
                  },
                ),
                SizedBox(height: 14.h),
              ],

              // KPI Summary Cards
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: l10n.activeOrders,
                      value: '${summary?.activeOrdersCount ?? 0}',
                      icon: Icons.local_shipping_outlined,
                      accentColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SummaryCard(
                      title: l10n.completedOrders,
                      value: '${summary?.completedOrdersCount ?? 0}',
                      icon: Icons.check_circle_outline_rounded,
                      accentColor: AppColors.success,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Active Orders Section
              Text(
                '${l10n.activeOrders} (${activeOrders.length})',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              if (activeOrders.isNotEmpty)
                Text(
                  l10n.tapOrderForDetails,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              SizedBox(height: 10.h),

              if (state.isLoading && summary == null)
                const LoadingIndicator()
              else if (activeOrders.isEmpty)
                EmptyStateView(
                  icon: Icons.inventory_2_outlined,
                  title: l10n.noActiveOrders,
                  message: l10n.noActiveOrdersSenderHint,
                )
              else
                ...activeOrders.map((order) {
                  final color = senderOrderColors[order.id] ??
                      OrderColorHelper.colorForOrderId(
                        order.id,
                        colorIndex: order.colorIndex,
                      );
                  return SenderOrderTile(
                    order: order,
                    orderColor: color,
                    isHighlighted: _selectedSenderOrderId == order.id,
                    onTap: () => _openOrderDetails(
                      order,
                      assignedColor: color,
                      isRider: false,
                    ),
                    onTrackTap: () => context.pushNamed(
                      RouteNames.trackOrder,
                      queryParameters: {'orderId': order.id},
                    ),
                  );
                }),

              if (summary != null && summary.recentOrders.isNotEmpty) ...[
                SizedBox(height: 14.h),
                Text(
                  l10n.recentOrders,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                ...summary.recentOrders
                    .where((o) => o.status.isTerminal)
                    .map(
                      (order) => SenderOrderTile(
                        order: order,
                        onTap: () => _openOrderDetails(order, isRider: false),
                      ),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ==================== RIDER VIEW (MULTI-ORDER COLORED REAL-TIME MAP + LIST) ====================
  Widget _buildRiderBody(
    BuildContext context,
    UserEntity user,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<RiderOrdersBloc, RiderOrdersState>(
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
              // Online / Offline Pill + Background GPS Status Banner
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: state.isOnline
                      ? AppColors.charcoal
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: state.isOnline
                        ? AppColors.charcoal
                        : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: state.isOnline
                            ? AppColors.successLight
                            : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.isOnline
                                ? l10n.riderOnline
                                : l10n.riderOffline,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: state.isOnline
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            state.isBackgroundTrackingActive
                                ? l10n.backgroundTrackingActive
                                : l10n.backgroundTrackingPaused,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: state.isOnline
                                  ? Colors.white.withAlpha(200)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: state.isOnline,
                      activeThumbColor: AppColors.successLight,
                      onChanged: (val) {
                        context
                            .read<RiderOrdersBloc>()
                            .add(ToggleRiderOnlineShiftEvent(val));
                        context
                            .read<AuthBloc>()
                            .add(ToggleRiderOnlineInAuthEvent(val));
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Cash in Hand Bar
              CashInHandBar(
                cashInHandPkr: state.earnings?.cashInHandPkr ?? 0,
                limitPkr: state.earnings?.cashLimitPkr ??
                    AppConstants.riderCashInHandLimitPkr,
              ),
              SizedBox(height: 14.h),

              if (_riderTabIndex == 0) ...[
                // REAL-TIME MULTI-ORDER COLORED MAP
                RiderMultiOrderMap(
                  activeOrders: state.activeOrders,
                  orderColors: state.orderColors,
                  riderLatitude: state.riderLatitude,
                  riderLongitude: state.riderLongitude,
                  selectedOrderId: state.selectedOrderId,
                  isLiveTracking: state.isBackgroundTrackingActive,
                  onOrderFocus: (orderId) {
                    context
                        .read<RiderOrdersBloc>()
                        .add(SelectRiderOrderOnMapEvent(orderId));
                  },
                  onOrderTap: (order) {
                    final color = state.orderColors[order.id] ??
                        OrderColorHelper.colorForOrderId(
                          order.id,
                          colorIndex: order.colorIndex,
                        );
                    _openOrderDetails(
                      order,
                      assignedColor: color,
                      isRider: true,
                      riderOnline: state.isOnline,
                    );
                  },
                ),
                SizedBox(height: 14.h),

                // List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.activeOrders} (${state.activeOrders.length})',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.tapOrderForDetails,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),

                if (state.isLoading && state.allOrders.isEmpty)
                  const LoadingIndicator()
                else if (state.activeOrders.isEmpty)
                  EmptyStateView(
                    icon: Icons.two_wheeler_outlined,
                    title: l10n.noActiveOrders,
                    message: l10n.noActiveOrdersRiderHint,
                  )
                else
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
                      onTap: () => _openOrderDetails(
                        order,
                        assignedColor: color,
                        isRider: true,
                        riderOnline: state.isOnline,
                      ),
                    );
                  }),
              ] else if (_riderTabIndex == 1) ...[
                RiderDeliveryLogView(
                  orders: state.filteredLogOrders,
                  orderColors: state.orderColors,
                  activeFilter: state.activeFilter,
                  onFilterChanged: (filter) {
                    context
                        .read<RiderOrdersBloc>()
                        .add(ChangeRiderOrderFilterEvent(filter));
                  },
                  onOrderTap: (order) {
                    final color = state.orderColors[order.id] ??
                        OrderColorHelper.colorForOrderId(
                          order.id,
                          colorIndex: order.colorIndex,
                        );
                    _openOrderDetails(
                      order,
                      assignedColor: color,
                      isRider: true,
                      riderOnline: state.isOnline,
                    );
                  },
                ),
              ] else ...[
                RiderEarningsView(
                  earnings: state.earnings,
                  completedOrders: state.completedOrders,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
