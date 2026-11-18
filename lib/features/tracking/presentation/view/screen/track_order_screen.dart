import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/external_launcher.dart';
import 'package:delivery_app/core/utils/formatters.dart';
import 'package:delivery_app/features/tracking/presentation/bloc/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/tracking/presentation/bloc/event/tracking_event.dart';
import 'package:delivery_app/features/tracking/presentation/bloc/state/tracking_state.dart';
import 'package:delivery_app/features/tracking/presentation/view/widgets/delivery_map_widget.dart';
import 'package:delivery_app/features/tracking/presentation/view/widgets/status_timeline_widget.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/widgets/empty_state_view.dart';
import 'package:delivery_app/shared/widgets/loading_indicator.dart';

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
    context.read<TrackingBloc>().add(
          LoadTrackingOrdersEvent(initialOrderId: widget.initialOrderId),
        );
  }

  Future<void> _callRider(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    await ExternalLauncher.openPhoneDialer(context, phone);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.liveTracking,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          if (state.isLoading && state.trackingData == null) {
            return const LoadingIndicator();
          }

          if (state.activeOrders.isEmpty || state.trackingData == null) {
            return EmptyStateView(
              icon: Icons.location_off_outlined,
              title: l10n.noActiveOrders,
              message: l10n.noActiveOrdersSenderHint,
            );
          }

          final data = state.trackingData!;
          final order = data.order;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order selector bar when multiple active orders exist
                if (state.activeOrders.length > 1) ...[
                  SizedBox(
                    height: 38.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.activeOrders.length,
                      separatorBuilder: (_, _) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final o = state.activeOrders[index];
                        final selected = o.id == order.id;
                        return ChoiceChip(
                          label: Text(o.orderNumber),
                          selected: selected,
                          selectedColor: AppColors.charcoal,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                          onSelected: (_) {
                            context
                                .read<TrackingBloc>()
                                .add(SelectTrackingOrderEvent(o.id));
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                Text(
                  l10n.orderOnTheWay,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${order.orderNumber} • ETA ${data.etaMinutes}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 14.h),

                DeliveryMapWidget(trackingData: data),
                SizedBox(height: 16.h),

                StatusTimelineWidget(currentStatus: order.status),
                SizedBox(height: 16.h),

                // Delivery OTP Code Card (Reference Design)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.yourDeliveryCode,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                l10n.tellOtpToRider,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          order.deliveryOtp,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // COD Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.collectCashCod,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(order.codAmountPkr),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Assigned Rider Card
                if (order.riderName != null)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withAlpha(24),
                        child: const Icon(
                          Icons.two_wheeler_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        order.riderName!,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${l10n.assignedRider} • ${order.riderPhone ?? ''}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.call_rounded),
                        onPressed: () => _callRider(order.riderPhone),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
