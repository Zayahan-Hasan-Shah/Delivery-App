import 'dart:async';
import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/order_color_helper.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/routing/route_names.dart';
import 'package:delivery_app/shared/service/background_delivery_service.dart';
import 'package:delivery_app/shared/widgets/app_tile_layer.dart';
import 'package:go_router/go_router.dart';

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
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant RiderMultiOrderMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isMapReady &&
        (widget.activeOrders.length != oldWidget.activeOrders.length ||
            widget.selectedOrderId != oldWidget.selectedOrderId)) {
      if (widget.selectedOrderId != null) {
        final selected = widget.activeOrders
            .where((o) => o.id == widget.selectedOrderId)
            .toList();
        _fitOrdersToCamera(selected);
      } else {
        _fitOrdersToCamera(widget.activeOrders);
      }
    }
  }

  CameraFit? _computeInitialCameraFit([List<OrderEntity>? orders]) {
    final list = orders ?? widget.activeOrders;
    final points = <LatLng>[
      for (final o in list) ...[
        LatLng(o.pickup.latitude, o.pickup.longitude),
        LatLng(o.dropoff.latitude, o.dropoff.longitude),
      ],
    ];
    final riderPt = _effectiveRiderPoint;
    if (riderPt != null && points.isNotEmpty) {
      points.add(riderPt);
    }
    if (points.length >= 2) {
      return CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: EdgeInsets.fromLTRB(36.w, 56.h, 36.w, 60.h),
        minZoom: 12.5,
        maxZoom: 16.0,
      );
    }
    return null;
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

  LatLng? get _effectiveRiderPoint {
    if (widget.isSenderMode) return null;
    if (widget.riderLatitude == null || widget.riderLongitude == null) {
      if (widget.activeOrders.isNotEmpty) {
        final first = widget.activeOrders.first;
        return LatLng(first.pickup.latitude - 0.007, first.pickup.longitude - 0.007);
      }
      return const LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude);
    }
    final raw = LatLng(widget.riderLatitude!, widget.riderLongitude!);
    if (widget.activeOrders.isEmpty) return raw;

    final firstPickup = LatLng(
      widget.activeOrders.first.pickup.latitude,
      widget.activeOrders.first.pickup.longitude,
    );
    if (_approxDistanceKm(raw, firstPickup) < 50.0) {
      return raw;
    }
    // Emulator location fallback: anchor rider realistically within 0.8km of first pickup
    return LatLng(firstPickup.latitude - 0.007, firstPickup.longitude - 0.007);
  }

  void _fitOrdersToCamera(List<OrderEntity> orders) {
    if (!_isMapReady) return;
    try {
      final points = <LatLng>[
        for (final o in orders) ...[
          LatLng(o.pickup.latitude, o.pickup.longitude),
          LatLng(o.dropoff.latitude, o.dropoff.longitude),
        ],
      ];

      final riderPt = _effectiveRiderPoint;
      if (riderPt != null && points.isNotEmpty) {
        points.add(riderPt);
      }

      if (points.length >= 2) {
        final bounds = LatLngBounds.fromPoints(points);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: EdgeInsets.fromLTRB(36.w, 56.h, 36.w, 60.h),
            minZoom: 12.5,
            maxZoom: 16.0,
          ),
        );
      } else if (points.length == 1) {
        _mapController.move(points.first, 14.5);
      } else {
        _mapController.move(_initialCenter, 13.5);
      }
    } catch (e) {
      debugPrint('[RiderMultiOrderMap] _fitOrdersToCamera error: $e');
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
    if (!_isMapReady) return;
    try {
      final riderPt = _effectiveRiderPoint;
      if (riderPt != null) {
        _mapController.move(riderPt, 15.2);
      }
    } catch (e) {
      debugPrint('[RiderMultiOrderMap] _centerOnRiderGps error: $e');
    }
  }

  Color _colorFor(OrderEntity order) {
    return widget.orderColors[order.id] ??
        OrderColorHelper.colorForOrderId(
          order.id,
          colorIndex: order.colorIndex,
        );
  }

  void _openInAppNavigationForOrder(BuildContext context, OrderEntity order) {
    final toPickup = order.status == OrderStatus.placed ||
        order.status == OrderStatus.accepted ||
        order.status == OrderStatus.assigned;
    final color = _colorFor(order);
    context.pushNamed(
      RouteNames.inAppNavigation,
      extra: {
        'order': order,
        'toPickup': toPickup,
        'color': color,
      },
    );
  }

  void _showEnlargedMultiOrderMapPreview(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return _EnlargedMultiOrderMapDialog(
          activeOrders: widget.activeOrders,
          orderColors: widget.orderColors,
          initialRiderPt: _effectiveRiderPoint,
          initialSelectedOrderId: widget.selectedOrderId,
          isSenderMode: widget.isSenderMode,
          onOrderTap: widget.onOrderTap,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final riderPoint = _effectiveRiderPoint;
    final hasRiderLoc = riderPoint != null;

    final selectedOrder = widget.selectedOrderId == null
        ? null
        : widget.activeOrders
            .where((o) => o.id == widget.selectedOrderId)
            .firstOrNull;

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
                initialCameraFit: _computeInitialCameraFit(),
                onMapReady: () {
                  _isMapReady = true;
                },
              ),
              children: [
                const AppTileLayer(),
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

            // Top-Right Controls: Enlarge Preview + Fit All Orders + My Location (for Rider)
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
                      onTap: () => _showEnlargedMultiOrderMapPreview(context),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.fullscreen_rounded,
                          size: 20.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
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
                    SizedBox(height: 6.h),
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

            // In-Map Active Leg Indicator Pill (when an order is focused)
            if (selectedOrder != null)
              Positioned(
                bottom: 52.h,
                left: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.charcoal.withAlpha(225),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (selectedOrder.status == OrderStatus.pickedUp ||
                                selectedOrder.status == OrderStatus.onTheWay)
                            ? Icons.flag_rounded
                            : Icons.storefront_rounded,
                        size: 13.sp,
                        color: _colorFor(selectedOrder),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        (selectedOrder.status == OrderStatus.pickedUp ||
                                selectedOrder.status == OrderStatus.onTheWay)
                            ? l10n.dropoffLabel
                            : l10n.pickupLabel,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // In-Map Quick Navigate Button (when an order is focused)
            if (selectedOrder != null)
              Positioned(
                bottom: 52.h,
                right: 10.w,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22.r),
                  elevation: 4,
                  shadowColor: Colors.black.withAlpha(90),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22.r),
                    onTap: () => _openInAppNavigationForOrder(context, selectedOrder),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.navigation_rounded,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '${l10n.navigate} • ${selectedOrder.orderNumber}',
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

class _EnlargedMultiOrderMapDialog extends StatefulWidget {
  final List<OrderEntity> activeOrders;
  final Map<String, Color> orderColors;
  final LatLng? initialRiderPt;
  final String? initialSelectedOrderId;
  final bool isSenderMode;
  final void Function(OrderEntity order) onOrderTap;

  const _EnlargedMultiOrderMapDialog({
    required this.activeOrders,
    required this.orderColors,
    this.initialRiderPt,
    this.initialSelectedOrderId,
    this.isSenderMode = false,
    required this.onOrderTap,
  });

  @override
  State<_EnlargedMultiOrderMapDialog> createState() =>
      _EnlargedMultiOrderMapDialogState();
}

class _EnlargedMultiOrderMapDialogState
    extends State<_EnlargedMultiOrderMapDialog> {
  final MapController _mapController = MapController();
  bool _isMapReady = false;
  bool _autoFollowRider = false;
  String? _selectedOrderId;
  LatLng? _riderPt;
  StreamSubscription<UserLocation>? _riderSub;

  @override
  void initState() {
    super.initState();
    _selectedOrderId = widget.initialSelectedOrderId;
    _riderPt = widget.initialRiderPt;

    if (!widget.isSenderMode) {
      try {
        final bg = sl<BackgroundDeliveryService>();
        _riderSub = bg.riderLiveLocationStream.listen((loc) {
          if (!mounted) return;
          final newPt = LatLng(loc.latitude, loc.longitude);
          if (widget.activeOrders.isNotEmpty) {
            final firstPickup = LatLng(
              widget.activeOrders.first.pickup.latitude,
              widget.activeOrders.first.pickup.longitude,
            );
            if (_approxDistanceKm(newPt, firstPickup) < 50.0) {
              setState(() => _riderPt = newPt);
            }
          } else {
            setState(() => _riderPt = newPt);
          }

          if (_autoFollowRider && _isMapReady && _riderPt != null) {
            try {
              _mapController.move(_riderPt!, 15.5);
            } catch (e) {
              debugPrint('[EnlargedMultiOrderMapDialog] auto-follow error: $e');
            }
          }
        });
      } catch (e) {
        debugPrint('[EnlargedMultiOrderMapDialog] stream error: $e');
      }
    }
  }

  @override
  void dispose() {
    _riderSub?.cancel();
    super.dispose();
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

  Color _colorFor(OrderEntity order) {
    return widget.orderColors[order.id] ??
        OrderColorHelper.colorForOrderId(
          order.id,
          colorIndex: order.colorIndex,
        );
  }

  void _fitCameraForSelection() {
    if (!_isMapReady) return;
    try {
      final points = <LatLng>[];
      final targetOrders = _selectedOrderId == null
          ? widget.activeOrders
          : widget.activeOrders.where((o) => o.id == _selectedOrderId).toList();

      for (final o in targetOrders) {
        points.add(LatLng(o.pickup.latitude, o.pickup.longitude));
        points.add(LatLng(o.dropoff.latitude, o.dropoff.longitude));
      }
      if (_riderPt != null && points.isNotEmpty) {
        points.add(_riderPt!);
      }

      if (points.length >= 2) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: EdgeInsets.fromLTRB(36.w, 80.h, 36.w, 150.h),
            minZoom: 12.0,
            maxZoom: 16.5,
          ),
        );
      } else if (points.length == 1) {
        _mapController.move(points.first, 15.0);
      }
    } catch (e) {
      debugPrint('[EnlargedMultiOrderMapDialog] fitCamera error: $e');
    }
  }

  void _centerOnRider() {
    if (!_isMapReady || _riderPt == null) return;
    try {
      _mapController.move(_riderPt!, 15.5);
      setState(() {
        _autoFollowRider = !_autoFollowRider;
      });
    } catch (e) {
      debugPrint('[EnlargedMultiOrderMapDialog] _centerOnRider error: $e');
    }
  }

  void _openNavigation(OrderEntity order) {
    Navigator.of(context).pop();
    final toPickup = order.status == OrderStatus.placed ||
        order.status == OrderStatus.accepted ||
        order.status == OrderStatus.assigned;
    final color = _colorFor(order);
    context.pushNamed(
      RouteNames.inAppNavigation,
      extra: {
        'order': order,
        'toPickup': toPickup,
        'color': color,
      },
    );
  }

  void _openDetails(OrderEntity order) {
    Navigator.of(context).pop();
    widget.onOrderTap(order);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedOrder = _selectedOrderId == null
        ? null
        : widget.activeOrders
            .where((o) => o.id == _selectedOrderId)
            .firstOrNull;

    final allPoints = <LatLng>[
      for (final o in widget.activeOrders) ...[
        LatLng(o.pickup.latitude, o.pickup.longitude),
        LatLng(o.dropoff.latitude, o.dropoff.longitude),
      ],
    ];
    if (_riderPt != null && allPoints.isNotEmpty) {
      allPoints.add(_riderPt!);
    }
    final initialBounds = allPoints.length >= 2
        ? LatLngBounds.fromPoints(allPoints)
        : null;

    final initialCenter = widget.activeOrders.isNotEmpty
        ? LatLng(
            (widget.activeOrders.first.pickup.latitude +
                    widget.activeOrders.first.dropoff.latitude) /
                2,
            (widget.activeOrders.first.pickup.longitude +
                    widget.activeOrders.first.dropoff.longitude) /
                2,
          )
        : (_riderPt ?? const LatLng(33.6844, 73.0479));

    final polylines = <Polyline>[];
    final markers = <Marker>[];

    for (final order in widget.activeOrders) {
      final color = _colorFor(order);
      final isSelected = order.id == _selectedOrderId;
      final isFilteredOut = _selectedOrderId != null && !isSelected;

      final pickupPt = LatLng(order.pickup.latitude, order.pickup.longitude);
      final dropoffPt = LatLng(order.dropoff.latitude, order.dropoff.longitude);

      // Route Polyline
      polylines.add(
        Polyline(
          points: [pickupPt, dropoffPt],
          color: isFilteredOut ? color.withAlpha(60) : color,
          strokeWidth: isSelected ? 5.5 : (isFilteredOut ? 2.5 : 4.0),
        ),
      );

      // Connector line from rider to next stop
      if (!isFilteredOut && _riderPt != null && _approxDistanceKm(_riderPt!, pickupPt) < 100.0) {
        final nextStop = (order.status == OrderStatus.pickedUp ||
                order.status == OrderStatus.onTheWay)
            ? dropoffPt
            : pickupPt;
        polylines.add(
          Polyline(
            points: [_riderPt!, nextStop],
            color: color.withAlpha(isSelected ? 200 : 130),
            strokeWidth: isSelected ? 3.8 : 2.4,
          ),
        );
      }

      // Pickup Marker
      markers.add(
        Marker(
          point: pickupPt,
          width: isSelected ? 92.w : 80.w,
          height: isSelected ? 58.h : 50.h,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedOrderId = (_selectedOrderId == order.id) ? null : order.id;
              });
              _fitCameraForSelection();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isFilteredOut ? color.withAlpha(120) : color,
                      width: isSelected ? 2.2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isSelected ? 50 : 25),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '${order.orderNumber} • P',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: isFilteredOut ? color.withAlpha(140) : color,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  width: isSelected ? 30.w : 24.w,
                  height: isSelected ? 30.w : 24.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFilteredOut ? color.withAlpha(120) : color,
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(isSelected ? 110 : 60),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    size: isSelected ? 16.sp : 13.sp,
                    color: isFilteredOut ? color.withAlpha(140) : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Dropoff Marker
      markers.add(
        Marker(
          point: dropoffPt,
          width: isSelected ? 92.w : 80.w,
          height: isSelected ? 58.h : 50.h,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedOrderId = (_selectedOrderId == order.id) ? null : order.id;
              });
              _fitCameraForSelection();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isFilteredOut ? color.withAlpha(120) : color,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isSelected ? 50 : 25),
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
                  width: isSelected ? 30.w : 24.w,
                  height: isSelected ? 30.w : 24.w,
                  decoration: BoxDecoration(
                    color: isFilteredOut ? color.withAlpha(120) : color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(isSelected ? 120 : 70),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    size: isSelected ? 16.sp : 13.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Rider Live Marker
    if (_riderPt != null) {
      markers.add(
        Marker(
          point: _riderPt!,
          width: 48.w,
          height: 48.w,
          child: GestureDetector(
            onTap: _centerOnRider,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.charcoal.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.two_wheeler_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final isAllSelected = _selectedOrderId == null;
    final dialogWidth = MediaQuery.sizeOf(context).width - 16.w;

    return Dialog(
      insetPadding: EdgeInsets.all(8.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: SizedBox(
          width: dialogWidth,
          height: 0.88.sh,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 13.0,
                  minZoom: 11.0,
                  maxZoom: 18.0,
                  initialCameraFit: initialBounds != null
                      ? CameraFit.bounds(
                          bounds: initialBounds,
                          padding: EdgeInsets.fromLTRB(36.w, 80.h, 36.w, 150.h),
                          minZoom: 12.0,
                          maxZoom: 16.0,
                        )
                      : null,
                  onMapReady: () {
                    _isMapReady = true;
                  },
                ),
                children: [
                  const AppTileLayer(),
                  PolylineLayer(polylines: polylines),
                  MarkerLayer(markers: markers),
                ],
              ),

              // Top Bar: Active Orders pill + Close button
              Positioned(
                top: 12.h,
                left: 12.w,
                right: 12.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal.withAlpha(235),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: AppColors.successLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${widget.activeOrders.length} Active Orders • Live Tracking',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.charcoal,
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),

              // Right-Side Controls: Fit + Center on Rider / Auto-follow
              Positioned(
                bottom: selectedOrder != null ? 142.h : 60.h,
                right: 14.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'multi_fit_enlarged',
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.charcoal,
                      elevation: 3,
                      onPressed: _fitCameraForSelection,
                      child: const Icon(Icons.fit_screen_rounded),
                    ),
                    if (_riderPt != null) ...[
                      SizedBox(height: 8.h),
                      FloatingActionButton.small(
                        heroTag: 'multi_rider_enlarged',
                        backgroundColor: _autoFollowRider
                            ? AppColors.primary
                            : Colors.white,
                        foregroundColor: _autoFollowRider
                            ? Colors.white
                            : AppColors.primary,
                        elevation: 3,
                        onPressed: _centerOnRider,
                        child: const Icon(Icons.my_location_rounded),
                      ),
                    ],
                  ],
                ),
              ),

              // Active Order Interactive Card (when an order is focused)
              if (selectedOrder != null)
                Positioned(
                  bottom: 54.h,
                  left: 10.w,
                  right: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: _colorFor(selectedOrder),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: _colorFor(selectedOrder),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              selectedOrder.orderNumber,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.charcoal,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: (selectedOrder.status ==
                                            OrderStatus.pickedUp ||
                                        selectedOrder.status ==
                                            OrderStatus.onTheWay)
                                    ? AppColors.primary.withAlpha(25)
                                    : AppColors.successLight.withAlpha(35),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                (selectedOrder.status == OrderStatus.pickedUp ||
                                        selectedOrder.status ==
                                            OrderStatus.onTheWay)
                                    ? 'DROP-OFF'
                                    : 'PICKUP',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: (selectedOrder.status ==
                                              OrderStatus.pickedUp ||
                                          selectedOrder.status ==
                                              OrderStatus.onTheWay)
                                      ? AppColors.primary
                                      : AppColors.charcoal,
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                setState(() => _selectedOrderId = null);
                                _fitCameraForSelection();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(4.w),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              (selectedOrder.status == OrderStatus.pickedUp ||
                                      selectedOrder.status ==
                                          OrderStatus.onTheWay)
                                  ? Icons.flag_rounded
                                  : Icons.storefront_rounded,
                              size: 15.sp,
                              color: _colorFor(selectedOrder),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                (selectedOrder.status == OrderStatus.pickedUp ||
                                        selectedOrder.status ==
                                            OrderStatus.onTheWay)
                                    ? selectedOrder.dropoff.addressText
                                    : selectedOrder.pickup.addressText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: () => _openNavigation(selectedOrder),
                                icon: const Icon(
                                  Icons.navigation_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  l10n.navigate,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.charcoal,
                                  side: BorderSide(
                                    color: AppColors.charcoal.withAlpha(120),
                                    width: 1.2,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                ),
                                onPressed: () => _openDetails(selectedOrder),
                                icon: const Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                        if (index == 0) {
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedOrderId = null);
                              _fitCameraForSelection();
                            },
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
                        final selected = _selectedOrderId == order.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedOrderId = selected ? null : order.id;
                            });
                            _fitCameraForSelection();
                          },
                          onDoubleTap: () => _openDetails(order),
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
      ),
    );
  }
}
