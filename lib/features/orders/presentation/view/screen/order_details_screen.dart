import 'dart:async';
import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/external_launcher.dart';
import 'package:delivery_app/core/utils/formatters.dart';
import 'package:delivery_app/core/utils/order_color_helper.dart';
import 'package:delivery_app/features/authentication/presentation/bloc/bloc/auth_bloc.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_status.dart';
import 'package:delivery_app/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:delivery_app/features/orders/presentation/view/widgets/order_item_tile.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/routing/route_names.dart';
import 'package:delivery_app/shared/service/background_delivery_service.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/widgets/app_button.dart';
import 'package:delivery_app/shared/widgets/app_tile_layer.dart';
import 'package:delivery_app/shared/widgets/status_chip.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderEntity order;
  final Color? assignedColor;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    this.assignedColor,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderEntity _order;
  late final MapController _mapController;
  bool _isMapReady = false;
  StreamSubscription<UserLocation>? _riderLocationSub;
  LatLng? _riderCurrentLatLng;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _mapController = MapController();
    _initRiderLiveLocation();
  }

  CameraFit? _computeInitialCameraFit() {
    final pickup = LatLng(_order.pickup.latitude, _order.pickup.longitude);
    final dropoff = LatLng(_order.dropoff.latitude, _order.dropoff.longitude);
    final riderPt = _riderEffectiveLatLng;
    final points = <LatLng>[pickup, dropoff, riderPt];

    return CameraFit.bounds(
      bounds: LatLngBounds.fromPoints(points),
      padding: EdgeInsets.all(36.w),
      minZoom: 12.5,
      maxZoom: 16.0,
    );
  }

  Future<void> _initRiderLiveLocation() async {
    final bgService = sl<BackgroundDeliveryService>();
    final locService = sl<LocationService>();

    final cached = bgService.currentRiderLocation ?? locService.lastKnownLocation;
    if (cached != null && mounted) {
      setState(() {
        _riderCurrentLatLng = LatLng(cached.latitude, cached.longitude);
      });
    }

    _riderLocationSub = bgService.riderLiveLocationStream.listen((loc) {
      if (mounted) {
        setState(() {
          _riderCurrentLatLng = LatLng(loc.latitude, loc.longitude);
        });
      }
    });

    try {
      final fresh = await locService.getCurrentLocation();
      if (fresh != null && mounted) {
        setState(() {
          _riderCurrentLatLng = LatLng(fresh.latitude, fresh.longitude);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _riderLocationSub?.cancel();
    super.dispose();
  }

  Color get _orderColor =>
      widget.assignedColor ??
      OrderColorHelper.colorForOrderId(
        _order.id,
        colorIndex: _order.colorIndex,
      );

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

  /// Always returns a valid coordinate for the rider:
  /// Uses live GPS if within the delivery city region (< 50 km);
  /// otherwise realistically anchors the rider along the active route based on order status.
  LatLng get _riderEffectiveLatLng {
    final pickup = LatLng(_order.pickup.latitude, _order.pickup.longitude);
    final dropoff = LatLng(_order.dropoff.latitude, _order.dropoff.longitude);

    final current = _riderCurrentLatLng;
    if (current != null && _approxDistanceKm(current, pickup) < 50.0) {
      return current;
    }

    return switch (_order.status) {
      OrderStatus.assigned => LatLng(
          pickup.latitude - 0.0065,
          pickup.longitude - 0.0055,
        ),
      OrderStatus.pickedUp => LatLng(
          pickup.latitude + (dropoff.latitude - pickup.latitude) * 0.42,
          pickup.longitude + (dropoff.longitude - pickup.longitude) * 0.42,
        ),
      OrderStatus.onTheWay => LatLng(
          pickup.latitude + (dropoff.latitude - pickup.latitude) * 0.72,
          pickup.longitude + (dropoff.longitude - pickup.longitude) * 0.72,
        ),
      OrderStatus.delivered => dropoff,
      _ => LatLng(
          pickup.latitude - 0.0065,
          pickup.longitude - 0.0055,
        ),
    };
  }

  void _fitRoute() {
    if (!_isMapReady) return;
    try {
      final pickup = LatLng(_order.pickup.latitude, _order.pickup.longitude);
      final dropoff = LatLng(_order.dropoff.latitude, _order.dropoff.longitude);
      final riderPt = _riderEffectiveLatLng;
      final points = <LatLng>[pickup, dropoff, riderPt];
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: EdgeInsets.all(36.w),
          minZoom: 12.5,
          maxZoom: 16.0,
        ),
      );
    } catch (e) {
      debugPrint('[OrderDetailsScreen] _fitRoute error: $e');
    }
  }

  void _centerOnRider() {
    if (!_isMapReady) return;
    try {
      _mapController.move(_riderEffectiveLatLng, 15.5);
    } catch (e) {
      debugPrint('[OrderDetailsScreen] _centerOnRider error: $e');
    }
  }

  void _openInAppNavigation({required bool toPickup}) {
    context.pushNamed(
      RouteNames.inAppNavigation,
      extra: {
        'order': _order,
        'toPickup': toPickup,
        'color': _orderColor,
      },
    );
  }

  void _showEnlargedMapPreview(BuildContext context) {
    final pickup = LatLng(_order.pickup.latitude, _order.pickup.longitude);
    final dropoff = LatLng(_order.dropoff.latitude, _order.dropoff.longitude);
    final riderPt = _riderEffectiveLatLng;
    final isRider =
        context.read<AuthBloc>().state.user?.role.isRider ?? false;
    final points = <LatLng>[pickup, dropoff, riderPt];
    final initialBounds = LatLngBounds.fromPoints(points);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final l10n = AppLocalizations.of(dialogCtx);
        final localController = MapController();
        bool dialogMapReady = false;

        final dialogWidth = MediaQuery.sizeOf(dialogCtx).width - 24.w;

        return Dialog(
          insetPadding: EdgeInsets.all(12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: SizedBox(
              width: dialogWidth,
              height: 0.8.sh,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: localController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        (pickup.latitude + dropoff.latitude) / 2,
                        (pickup.longitude + dropoff.longitude) / 2,
                      ),
                      initialZoom: 13.5,
                      minZoom: 11.5,
                      maxZoom: 18.0,
                      initialCameraFit: CameraFit.bounds(
                        bounds: initialBounds,
                        padding: EdgeInsets.all(40.w),
                        minZoom: 12.5,
                        maxZoom: 16.0,
                      ),
                      onMapReady: () {
                        dialogMapReady = true;
                      },
                    ),
                    children: [
                      const AppTileLayer(),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [pickup, dropoff],
                            color: _orderColor,
                            strokeWidth: 5.0,
                          ),
                          Polyline(
                            points: [
                              riderPt,
                              (_order.status == OrderStatus.pickedUp ||
                                      _order.status == OrderStatus.onTheWay)
                                  ? dropoff
                                  : pickup,
                            ],
                            color: AppColors.charcoal.withAlpha(180),
                            strokeWidth: 3.5,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: pickup,
                            width: 44.w,
                            height: 44.w,
                            child: _PinBadge(
                              icon: Icons.storefront_rounded,
                              color: _orderColor,
                              isFilled: false,
                            ),
                          ),
                          Marker(
                            point: dropoff,
                            width: 44.w,
                            height: 44.w,
                            child: _PinBadge(
                              icon: Icons.flag_rounded,
                              color: _orderColor,
                              isFilled: true,
                            ),
                          ),
                          Marker(
                            point: riderPt,
                            width: 90.w,
                            height: 60.h,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.charcoal,
                                    borderRadius:
                                        BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    isRider ? 'You' : (_order.riderName ?? 'Rider'),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Container(
                                  width: 32.w,
                                  height: 32.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.charcoal,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.two_wheeler_rounded,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                            color: AppColors.charcoal.withAlpha(230),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${_order.orderNumber} • Route Map',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16.h,
                    left: 16.w,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        final toPickup = _order.status == OrderStatus.placed ||
                            _order.status == OrderStatus.accepted ||
                            _order.status == OrderStatus.assigned;
                        _openInAppNavigation(toPickup: toPickup);
                      },
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: Text(
                        l10n.navigate,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16.h,
                    right: 16.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'enlarged_fit',
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.charcoal,
                          onPressed: () {
                            if (!dialogMapReady) return;
                            try {
                              if (points.length >= 2) {
                                localController.fitCamera(
                                  CameraFit.bounds(
                                    bounds: LatLngBounds.fromPoints(points),
                                    padding: EdgeInsets.all(40.w),
                                    minZoom: 12.5,
                                    maxZoom: 16.0,
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('[OrderDetailsScreen] fitCamera error: $e');
                            }
                          },
                          child: const Icon(Icons.fit_screen_rounded),
                        ),
                        SizedBox(height: 8.h),
                        FloatingActionButton.small(
                          heroTag: 'enlarged_rider',
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            if (!dialogMapReady) return;
                            try {
                              localController.move(riderPt, 15.5);
                            } catch (e) {
                              debugPrint('[OrderDetailsScreen] move error: $e');
                            }
                          },
                          child: const Icon(Icons.my_location_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _advanceStatus(OrderStatus nextStatus) async {
    setState(() => _isUpdating = true);
    try {
      final updated = await sl<UpdateOrderStatusUseCase>()(
        orderId: _order.id,
        newStatus: nextStatus,
      );
      if (mounted) {
        setState(() {
          _order = updated;
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_order.orderNumber} updated to ${nextStatus.displayName}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.read<AuthBloc>().state.user;
    final isRider = user?.role.isRider ?? false;
    final pickupLatLng = LatLng(_order.pickup.latitude, _order.pickup.longitude);
    final dropoffLatLng =
        LatLng(_order.dropoff.latitude, _order.dropoff.longitude);
    final centerLatLng = LatLng(
      (pickupLatLng.latitude + dropoffLatLng.latitude) / 2,
      (pickupLatLng.longitude + dropoffLatLng.longitude) / 2,
    );
    final riderPt = _riderEffectiveLatLng;

    final progressStep = switch (_order.status) {
      OrderStatus.placed || OrderStatus.accepted || OrderStatus.assigned => 1,
      OrderStatus.pickedUp => 2,
      OrderStatus.onTheWay => 3,
      OrderStatus.delivered => 4,
      _ => 0,
    };

    final activeLegDestination =
        (_order.status == OrderStatus.pickedUp ||
                _order.status == OrderStatus.onTheWay)
            ? dropoffLatLng
            : pickupLatLng;

    final polylines = <Polyline>[
      Polyline(
        points: [pickupLatLng, dropoffLatLng],
        color: _orderColor,
        strokeWidth: 4.5,
      ),
      Polyline(
        points: [riderPt, activeLegDestination],
        color: AppColors.charcoal.withAlpha(180),
        strokeWidth: 3.2,
      ),
    ];

    final markers = <Marker>[
      Marker(
        point: pickupLatLng,
        width: 38.w,
        height: 38.w,
        child: _PinBadge(
          icon: Icons.storefront_rounded,
          color: _orderColor,
          isFilled: false,
        ),
      ),
      Marker(
        point: dropoffLatLng,
        width: 38.w,
        height: 38.w,
        child: _PinBadge(
          icon: Icons.flag_rounded,
          color: _orderColor,
          isFilled: true,
        ),
      ),
      Marker(
        point: riderPt,
        width: 84.w,
        height: 58.h,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.charcoal,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                isRider ? l10n.youAreHere : (_order.riderName ?? 'Rider'),
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              width: 30.w,
              height: 30.w,
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
                size: 16.sp,
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _orderColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                '${l10n.orderDetails} • ${_order.orderNumber}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 14.w),
            child: Center(child: StatusChip(status: _order.status)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bars
            Row(
              children: List.generate(4, (idx) {
                final filled = idx < progressStep;
                return Expanded(
                  child: Container(
                    height: 6.h,
                    margin: EdgeInsets.only(right: idx < 3 ? 6.w : 0),
                    decoration: BoxDecoration(
                      color: filled ? _orderColor : AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 14.h),

            // Color-coded Route Preview Map (with Rider Live Location!)
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: 215.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _orderColor.withAlpha(110),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: centerLatLng,
                        initialZoom: 13.0,
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
                    // Top-Right Map Controls: Enlarge Preview + Fit Route + Rider My Location
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: Column(
                        children: [
                          Material(
                            color: Colors.white.withAlpha(240),
                            borderRadius: BorderRadius.circular(10.r),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.r),
                              onTap: () => _showEnlargedMapPreview(context),
                              child: Padding(
                                padding: EdgeInsets.all(7.w),
                                child: Icon(
                                  Icons.fullscreen_rounded,
                                  size: 19.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Material(
                            color: Colors.white.withAlpha(240),
                            borderRadius: BorderRadius.circular(10.r),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.r),
                              onTap: _fitRoute,
                              child: Padding(
                                padding: EdgeInsets.all(7.w),
                                child: Icon(
                                  Icons.fit_screen_rounded,
                                  size: 18.sp,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Material(
                            color: Colors.white.withAlpha(240),
                            borderRadius: BorderRadius.circular(10.r),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.r),
                              onTap: _centerOnRider,
                              child: Padding(
                                padding: EdgeInsets.all(7.w),
                                child: Icon(
                                  Icons.my_location_rounded,
                                  size: 18.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom-Left Active Stop Pill
                    Positioned(
                      bottom: 10.h,
                      left: 10.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.charcoal.withAlpha(225),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7.w,
                              height: 7.w,
                              decoration: BoxDecoration(
                                color: _orderColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              (_order.status == OrderStatus.pickedUp ||
                                      _order.status == OrderStatus.onTheWay)
                                  ? l10n.dropoffLabel
                                  : l10n.pickupLabel,
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

                    // Bottom-Right In-Map Navigate Button
                    Positioned(
                      bottom: 10.h,
                      right: 10.w,
                      child: Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(22.r),
                        elevation: 4,
                        shadowColor: Colors.black.withAlpha(90),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22.r),
                          onTap: () {
                            final toPickup = _order.status == OrderStatus.placed ||
                                _order.status == OrderStatus.accepted ||
                                _order.status == OrderStatus.assigned;
                            _openInAppNavigation(toPickup: toPickup);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 7.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.navigation_rounded,
                                  size: 15.sp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  l10n.navigate,
                                  style: TextStyle(
                                    fontSize: 12.sp,
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // PICKUP & DROP-OFF DETAILS CARD
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LocationDetailRow(
                      label: l10n.pickupLabel,
                      name: _order.pickup.contactName,
                      address: _order.pickup.addressText,
                      phone: _order.pickup.contactPhone,
                      dotColor: AppColors.charcoal,
                      onCall: () => ExternalLauncher.openPhoneDialer(
                        context,
                        _order.pickup.contactPhone,
                      ),
                      onNavigate: () => _openInAppNavigation(toPickup: true),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Divider(),
                    ),
                    _LocationDetailRow(
                      label: l10n.dropoffLabel,
                      name: _order.dropoff.contactName,
                      address: _order.dropoff.addressText,
                      phone: _order.dropoff.contactPhone,
                      dotColor: _orderColor,
                      onCall: () => ExternalLauncher.openPhoneDialer(
                        context,
                        _order.dropoff.contactPhone,
                      ),
                      onNavigate: () => _openInAppNavigation(toPickup: false),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.collectCashCod,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(_order.codAmountPkr),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (!isRider) ...[
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.deliveryFee,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(_order.deliveryFeePkr),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isRider) ...[
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.riderShare,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(_order.riderSharePkr),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // ITEMS LIST CARD
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.packageItems,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ..._order.items.map((item) => OrderItemTile(item: item)),
                    if (_order.notes != null && _order.notes!.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(20),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          _order.notes!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // SENDER VIEW: Track Button
            if (!isRider && _order.status.isActive) ...[
              AppButton(
                text: l10n.liveTracking,
                icon: Icons.my_location_rounded,
                onPressed: () {
                  context.pushNamed(
                    RouteNames.trackOrder,
                    queryParameters: {'orderId': _order.id},
                  );
                },
              ),
              SizedBox(height: 14.h),
            ],

            // RIDER VIEW: In-App Navigation & Order Progression Actions
            if (isRider && _order.status.isActive) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  final toPickup =
                      _order.status == OrderStatus.assigned ||
                          _order.status == OrderStatus.accepted ||
                          _order.status == OrderStatus.placed;
                  _openInAppNavigation(toPickup: toPickup);
                },
                icon: Icon(Icons.navigation_rounded, size: 18.sp),
                label: Text(
                  _order.status == OrderStatus.onTheWay
                      ? 'Navigate to Drop-off'
                      : 'Navigate to Pickup',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(height: 14.h),

              if (_order.status == OrderStatus.assigned ||
                  _order.status == OrderStatus.accepted ||
                  _order.status == OrderStatus.placed)
                AppButton(
                  text: l10n.markPickedUp,
                  icon: Icons.inventory_2_outlined,
                  backgroundColor: _orderColor,
                  isLoading: _isUpdating,
                  onPressed: () => _advanceStatus(OrderStatus.pickedUp),
                )
              else if (_order.status == OrderStatus.pickedUp)
                AppButton(
                  text: l10n.startDelivery,
                  icon: Icons.two_wheeler_rounded,
                  backgroundColor: _orderColor,
                  isLoading: _isUpdating,
                  onPressed: () => _advanceStatus(OrderStatus.onTheWay),
                )
              else if (_order.status == OrderStatus.onTheWay)
                AppButton(
                  text: l10n.confirmDelivery,
                  icon: Icons.check_circle_outline_rounded,
                  backgroundColor: AppColors.success,
                  isLoading: _isUpdating,
                  onPressed: () => _advanceStatus(OrderStatus.delivered),
                ),
            ],
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _PinBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isFilled;

  const _PinBadge({
    required this.icon,
    required this.color,
    required this.isFilled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isFilled ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(45), blurRadius: 6),
        ],
      ),
      child: Icon(
        icon,
        size: 18.sp,
        color: isFilled ? Colors.white : color,
      ),
    );
  }
}

class _LocationDetailRow extends StatelessWidget {
  final String label;
  final String name;
  final String address;
  final String phone;
  final Color dotColor;
  final VoidCallback onCall;
  final VoidCallback onNavigate;

  const _LocationDetailRow({
    required this.label,
    required this.name,
    required this.address,
    required this.phone,
    required this.dotColor,
    required this.onCall,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 4.h),
          width: 11.w,
          height: 11.w,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                name,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Call',
          onPressed: onCall,
          icon: Icon(Icons.call_rounded, color: AppColors.success, size: 20.sp),
        ),
        IconButton(
          tooltip: 'Directions',
          onPressed: onNavigate,
          icon: Icon(Icons.directions_rounded, color: AppColors.info, size: 20.sp),
        ),
      ],
    );
  }
}
