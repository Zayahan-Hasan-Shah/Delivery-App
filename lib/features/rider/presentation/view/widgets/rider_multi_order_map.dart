import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/order_color_helper.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/l10n/app_localizations.dart';

class RiderMultiOrderMap extends StatefulWidget {
  final List<OrderEntity> activeOrders;
  final Map<String, Color> orderColors;
  final double? riderLatitude;
  final double? riderLongitude;
  final String? selectedOrderId;
  final bool isLiveTracking;
  final bool isSenderMode;
  final void Function(OrderEntity order) onOrderTap;
  final void Function(String? orderId) onOrderFocus;

  const RiderMultiOrderMap({
    super.key,
    required this.activeOrders,
    required this.orderColors,
    this.riderLatitude,
    this.riderLongitude,
    required this.selectedOrderId,
    required this.isLiveTracking,
    this.isSenderMode = false,
    required this.onOrderTap,
    required this.onOrderFocus,
  });

  @override
  State<RiderMultiOrderMap> createState() => _RiderMultiOrderMapState();
}

class _RiderMultiOrderMapState extends State<RiderMultiOrderMap> {
  late final MapController _mapController;
  bool _hasFittedInitially = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.activeOrders.isNotEmpty && !_hasFittedInitially) {
        _hasFittedInitially = true;
        _fitOrdersToCamera(widget.activeOrders);
      }
    });
  }

  @override
  void didUpdateWidget(covariant RiderMultiOrderMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasFittedInitially && widget.activeOrders.isNotEmpty) {
      _hasFittedInitially = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fitOrdersToCamera(widget.activeOrders);
      });
    }
  }

  LatLng get _initialCenter {
    if (widget.activeOrders.isNotEmpty) {
      final first = widget.activeOrders.first;
      return LatLng(
        (first.pickup.latitude + first.dropoff.latitude) / 2,
        (first.pickup.longitude + first.dropoff.longitude) / 2,
      );
    }
    if (widget.riderLatitude != null && widget.riderLongitude != null) {
      return LatLng(widget.riderLatitude!, widget.riderLongitude!);
    }
    return const LatLng(
      AppConstants.defaultLatitude,
      AppConstants.defaultLongitude,
    );
  }

  double _approxDistanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = (b.latitude - a.latitude) * (pi / 180.0);
    final dLng = (b.longitude - a.longitude) * (pi / 180.0);
    final s1 = sin(dLat / 2);
    final s2 = sin(dLng / 2);
    final h = s1 * s1 +
        cos(a.latitude * pi / 180.0) *
            cos(b.latitude * pi / 180.0) *
            s2 *
            s2;
    return 2 * r * atan2(sqrt(h), sqrt(1 - h));
  }

  void _fitOrdersToCamera(List<OrderEntity> orders) {
    final points = <LatLng>[
      for (final o in orders) ...[
        LatLng(o.pickup.latitude, o.pickup.longitude),
        LatLng(o.dropoff.latitude, o.dropoff.longitude),
      ],
    ];

    // Include rider GPS in bounds ONLY if within 100km of the orders
    // (prevents zooming out to world view when testing on an emulator in another country)
    if (!widget.isSenderMode &&
        widget.riderLatitude != null &&
        widget.riderLongitude != null &&
        points.isNotEmpty) {
      final riderPt = LatLng(widget.riderLatitude!, widget.riderLongitude!);
      if (_approxDistanceKm(riderPt, points.first) < 100.0) {
        points.add(riderPt);
      }
    }

    if (points.length >= 2) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: EdgeInsets.fromLTRB(36.w, 56.h, 36.w, 60.h),
        ),
      );
    } else if (points.length == 1) {
      _mapController.move(points.first, 14.5);
    } else {
      _mapController.move(_initialCenter, 13.5);
    }
  }

  void _selectSingleOrder(OrderEntity order) {
    if (widget.selectedOrderId == order.id) {
      // Tapping an already-filtered order chip resets back to All
      _showAllOrders();
      return;
    }
    widget.onOrderFocus(order.id);
    _fitOrdersToCamera([order]);
  }

  void _showAllOrders() {
    widget.onOrderFocus(null);
    _fitOrdersToCamera(widget.activeOrders);
  }

  void _centerOnRiderGps() {
    if (widget.riderLatitude != null && widget.riderLongitude != null) {
      _mapController.move(
        LatLng(widget.riderLatitude!, widget.riderLongitude!),
        15.0,
      );
    }
  }

  Color _colorFor(OrderEntity order) {
    return widget.orderColors[order.id] ??
        OrderColorHelper.colorForOrderId(
          order.id,
          colorIndex: order.colorIndex,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasRiderLoc =
        !widget.isSenderMode &&
        widget.riderLatitude != null &&
        widget.riderLongitude != null;
    final riderPoint = hasRiderLoc
        ? LatLng(widget.riderLatitude!, widget.riderLongitude!)
        : null;

    // When a specific order chip is selected, filter the map to show that order cleanly;
    // when "All" is selected (selectedOrderId == null), render ALL active orders!
    final visibleOrders = widget.selectedOrderId == null
        ? widget.activeOrders
        : widget.activeOrders
            .where((o) => o.id == widget.selectedOrderId)
            .toList();

    final polylines = <Polyline>[];
    final markers = <Marker>[];

    for (final order in visibleOrders) {
      final color = _colorFor(order);
      final isSelected = widget.selectedOrderId == order.id;
      final pickupPoint = LatLng(order.pickup.latitude, order.pickup.longitude);
      final dropoffPoint =
          LatLng(order.dropoff.latitude, order.dropoff.longitude);

      // 1. Primary Pickup -> Dropoff route polyline in the order's unique color
      polylines.add(
        Polyline(
          points: [pickupPoint, dropoffPoint],
          color: color,
          strokeWidth: isSelected ? 5.2 : 3.8,
        ),
      );

      // 2. For Rider: draw live connector line from Rider -> next stop (only if nearby)
      if (riderPoint != null && _approxDistanceKm(riderPoint, pickupPoint) < 100.0) {
        final nextStop = (order.status == OrderStatus.pickedUp ||
                order.status == OrderStatus.onTheWay)
            ? dropoffPoint
            : pickupPoint;
        polylines.add(
          Polyline(
            points: [riderPoint, nextStop],
            color: color.withAlpha(140),
            strokeWidth: isSelected ? 3.2 : 2.2,
          ),
        );
      }

      // 3. For Sender: show assigned rider live indicator along each active route
      if (widget.isSenderMode && order.riderId != null) {
        final progress = switch (order.status) {
          OrderStatus.assigned => 0.15,
          OrderStatus.pickedUp => 0.45,
          OrderStatus.onTheWay => 0.72,
          _ => 0.05,
        };
        final liveOrderRiderPt = LatLng(
          pickupPoint.latitude +
              (dropoffPoint.latitude - pickupPoint.latitude) * progress,
          pickupPoint.longitude +
              (dropoffPoint.longitude - pickupPoint.longitude) * progress,
        );
        markers.add(
          Marker(
            point: liveOrderRiderPt,
            width: 32.w,
            height: 32.w,
            child: GestureDetector(
              onTap: () => widget.onOrderTap(order),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(110),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.two_wheeler_rounded,
                  size: 15.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }

      // 4. Pickup Marker (White center + Order-Colored Ring + Order Tag)
      markers.add(
        Marker(
          point: pickupPoint,
          width: 84.w,
          height: 54.h,
          child: GestureDetector(
            onTap: () => widget.onOrderTap(order),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: color, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '${order.orderNumber} • P',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  width: isSelected ? 30.w : 26.w,
                  height: isSelected ? 30.w : 26.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2.5),
                    boxShadow: [
                      BoxShadow(color: color.withAlpha(90), blurRadius: 6),
                    ],
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 14.sp,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 5. Drop-off Marker (Solid Order-Colored Pin + White Flag + Order Tag)
      markers.add(
        Marker(
          point: dropoffPoint,
          width: 84.w,
          height: 54.h,
          child: GestureDetector(
            onTap: () => widget.onOrderTap(order),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(35),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '${order.orderNumber} • D',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  width: isSelected ? 30.w : 26.w,
                  height: isSelected ? 30.w : 26.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: color.withAlpha(110), blurRadius: 8),
                    ],
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 6. Rider's Live Current GPS Location Marker
    if (riderPoint != null) {
      markers.add(
        Marker(
          point: riderPoint,
          width: 44.w,
          height: 44.w,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.charcoal.withAlpha(45),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(5.w),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.charcoal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(70),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.two_wheeler_rounded,
                color: Colors.white,
                size: 17.sp,
              ),
            ),
          ),
        ),
      );
    }

    final isAllSelected = widget.selectedOrderId == null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        height: 295.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCenter,
                initialZoom: 12.6,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.shefscloud.delivery',
                ),
                PolylineLayer(polylines: polylines),
                MarkerLayer(markers: markers),
              ],
            ),

            // Top Live Status Pill
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.charcoal.withAlpha(225),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: widget.isLiveTracking
                            ? AppColors.successLight
                            : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      l10n.ordersOnMapCount(visibleOrders.length),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top-Right Controls: Fit All Orders + My Location (for Rider)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Column(
                children: [
                  Material(
                    color: Colors.white.withAlpha(242),
                    borderRadius: BorderRadius.circular(10.r),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.r),
                      onTap: _showAllOrders,
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.fit_screen_rounded,
                          size: 19.sp,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                  ),
                  if (hasRiderLoc) ...[
                    SizedBox(height: 8.h),
                    Material(
                      color: Colors.white.withAlpha(242),
                      borderRadius: BorderRadius.circular(10.r),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        onTap: _centerOnRiderGps,
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.my_location_rounded,
                            size: 19.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom Floating Filter Strip: "All" Chip + Unique Color-Coded Order Chips
            if (widget.activeOrders.isNotEmpty)
              Positioned(
                bottom: 10.h,
                left: 10.w,
                right: 10.w,
                child: SizedBox(
                  height: 36.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.activeOrders.length + 1,
                    separatorBuilder: (_, _) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      // Index 0: Explicit "All" chip to show every order on map
                      if (index == 0) {
                        return GestureDetector(
                          onTap: _showAllOrders,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isAllSelected
                                  ? AppColors.charcoal
                                  : Colors.white.withAlpha(245),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppColors.charcoal,
                                width: 1.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(28),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.layers_rounded,
                                  size: 14.sp,
                                  color: isAllSelected
                                      ? Colors.white
                                      : AppColors.charcoal,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  '${l10n.filterAll} (${widget.activeOrders.length})',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    color: isAllSelected
                                        ? Colors.white
                                        : AppColors.charcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final order = widget.activeOrders[index - 1];
                      final color = _colorFor(order);
                      final selected = widget.selectedOrderId == order.id;

                      return GestureDetector(
                        onTap: () => _selectSingleOrder(order),
                        onDoubleTap: () => widget.onOrderTap(order),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? color
                                : Colors.white.withAlpha(245),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: color, width: 1.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(28),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 9.w,
                                height: 9.w,
                                decoration: BoxDecoration(
                                  color: selected ? Colors.white : color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                order.orderNumber,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
