import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/core/di/injection_container.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/core/utils/external_launcher.dart';
import 'package:delivery_app/core/utils/order_color_helper.dart';
import 'package:delivery_app/features/orders/domain/entities/location_point_entity.dart';
import 'package:delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:delivery_app/l10n/app_localizations.dart';
import 'package:delivery_app/shared/service/background_delivery_service.dart';
import 'package:delivery_app/shared/service/location_service.dart';
import 'package:delivery_app/shared/service/route_navigation_service.dart';

class InAppNavigationScreen extends StatefulWidget {
  final OrderEntity order;
  final bool navigateToPickup;
  final Color? orderColor;

  const InAppNavigationScreen({
    super.key,
    required this.order,
    required this.navigateToPickup,
    this.orderColor,
  });

  @override
  State<InAppNavigationScreen> createState() => _InAppNavigationScreenState();
}

class _InAppNavigationScreenState extends State<InAppNavigationScreen> {
  late final MapController _mapController;
  late bool _isTargetingPickup;
  StreamSubscription<UserLocation>? _locationSub;

  LatLng? _riderLatLng;
  NavigationRouteResult? _route;
  bool _isLoadingRoute = true;
  bool _followRider = true;
  bool _showAllSteps = false;

  Color get _accentColor =>
      widget.orderColor ??
      OrderColorHelper.colorForOrderId(
        widget.order.id,
        colorIndex: widget.order.colorIndex,
      );

  LocationPointEntity get _targetPoint =>
      _isTargetingPickup ? widget.order.pickup : widget.order.dropoff;

  LatLng get _targetLatLng =>
      LatLng(_targetPoint.latitude, _targetPoint.longitude);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _isTargetingPickup = widget.navigateToPickup;
    _initLocationAndRoute();
  }

  Future<void> _initLocationAndRoute() async {
    final bgService = sl<BackgroundDeliveryService>();
    final locService = sl<LocationService>();

    final initial = bgService.currentRiderLocation ??
        locService.lastKnownLocation ??
        await locService.getCurrentLocation();

    if (!mounted) return;

    final startPoint = _resolveUsableOrigin(
      initial != null ? LatLng(initial.latitude, initial.longitude) : null,
    );

    setState(() => _riderLatLng = startPoint);

    await _loadRoute();

    _locationSub = bgService.riderLiveLocationStream.listen((loc) {
      if (!mounted) return;
      final livePt = LatLng(loc.latitude, loc.longitude);
      // Only update marker to device GPS if within 100 km of the delivery city
      if (_approxDistanceKm(livePt, _targetLatLng) < 100.0) {
        setState(() => _riderLatLng = livePt);
        if (_followRider) {
          _mapController.move(livePt, _mapController.camera.zoom);
        }
      }
    });
  }

  /// Uses real device GPS when near the city (< 100 km); if testing on an emulator
  /// whose mock GPS is in another country, starts from a nearby city coordinate
  /// so the rider gets a full road-snapped in-app route immediately.
  LatLng _resolveUsableOrigin(LatLng? gpsPoint) {
    if (gpsPoint != null && _approxDistanceKm(gpsPoint, _targetLatLng) < 100.0) {
      return gpsPoint;
    }
    if (!_isTargetingPickup) {
      return LatLng(
        widget.order.pickup.latitude,
        widget.order.pickup.longitude,
      );
    }
    // Slight realistic offset (~1.1 km) from pickup when emulator GPS is overseas
    return LatLng(
      widget.order.pickup.latitude - 0.0085,
      widget.order.pickup.longitude - 0.0065,
    );
  }

  Future<void> _loadRoute() async {
    final origin = _riderLatLng ?? _resolveUsableOrigin(null);
    setState(() => _isLoadingRoute = true);

    final route = await sl<RouteNavigationService>().fetchRoute(
      origin: origin,
      destination: _targetLatLng,
      destinationName: _targetPoint.contactName,
    );

    if (!mounted) return;
    setState(() {
      _route = route;
      _isLoadingRoute = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fitFullRoute();
    });
  }

  void _fitFullRoute() {
    final points = <LatLng>[
      if (_riderLatLng != null) _riderLatLng!,
      _targetLatLng,
      ...?_route?.polylinePoints,
    ];
    if (points.length >= 2) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: EdgeInsets.fromLTRB(44.w, 150.h, 44.w, 220.h),
        ),
      );
    }
  }

  void _switchTarget({required bool toPickup}) {
    if (_isTargetingPickup == toPickup) return;
    setState(() {
      _isTargetingPickup = toPickup;
      _showAllSteps = false;
    });
    _loadRoute();
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

  IconData _maneuverIcon(NavigationStep? step) {
    if (step == null) return Icons.navigation_rounded;
    final mod = (step.modifier ?? '').toLowerCase();
    if (step.maneuverType == 'arrive') return Icons.flag_rounded;
    if (step.maneuverType == 'roundabout' || step.maneuverType == 'rotary') {
      return Icons.roundabout_right_rounded;
    }
    if (mod.contains('left')) return Icons.turn_left_rounded;
    if (mod.contains('right')) return Icons.turn_right_rounded;
    if (mod.contains('uturn')) return Icons.u_turn_left_rounded;
    return Icons.straight_rounded;
  }

  String _formatStepDist(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentStep = (_route?.steps.isNotEmpty ?? false)
        ? _route!.steps.first
        : null;
    final routePoints = _route?.polylinePoints ??
        [if (_riderLatLng != null) _riderLatLng!, _targetLatLng];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ==================== FULL-SCREEN IN-APP MAP ====================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _riderLatLng ?? _targetLatLng,
              initialZoom: 14.5,
              onPositionChanged: (_, hasGesture) {
                if (hasGesture && _followRider) {
                  setState(() => _followRider = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.shefscloud.delivery',
              ),
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    // White outer road casing for crisp visibility
                    Polyline(
                      points: routePoints,
                      color: Colors.white,
                      strokeWidth: 9.0,
                    ),
                    // Order-colored live navigation route
                    Polyline(
                      points: routePoints,
                      color: _accentColor,
                      strokeWidth: 5.5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Destination Marker (Pickup or Drop-off)
                  Marker(
                    point: _targetLatLng,
                    width: 96.w,
                    height: 62.h,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(45),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Text(
                            _isTargetingPickup
                                ? l10n.pickupLabel
                                : l10n.dropoffLabel,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: _accentColor.withAlpha(120),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isTargetingPickup
                                ? Icons.storefront_rounded
                                : Icons.flag_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Live Rider Current Location Beacon
                  if (_riderLatLng != null)
                    Marker(
                      point: _riderLatLng!,
                      width: 50.w,
                      height: 50.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(6.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.charcoal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(80),
                                blurRadius: 8,
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
                ],
              ),
            ],
          ),

          // ==================== TOP TURN-BY-TURN BANNER ====================
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(65),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: _isLoadingRoute
                              ? Padding(
                                  padding: EdgeInsets.all(10.w),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  _maneuverIcon(currentStep),
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLoadingRoute
                                    ? 'Calculating route...'
                                    : (currentStep?.instruction ??
                                        'Head to ${_targetPoint.contactName}'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              if (!_isLoadingRoute && currentStep != null) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  '${_formatStepDist(currentStep.distanceMeters)} • ${widget.order.orderNumber}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white.withAlpha(195),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if ((_route?.steps.length ?? 0) > 1)
                          IconButton(
                            onPressed: () =>
                                setState(() => _showAllSteps = !_showAllSteps),
                            icon: Icon(
                              _showAllSteps
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.list_rounded,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Expandable Turn-by-Turn Steps List
                  if (_showAllSteps && _route != null)
                    Container(
                      margin: EdgeInsets.only(top: 8.h),
                      constraints: BoxConstraints(maxHeight: 200.h),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withAlpha(245),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        itemCount: _route!.steps.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final step = _route!.steps[idx];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              _maneuverIcon(step),
                              color: _accentColor,
                              size: 20.sp,
                            ),
                            title: Text(
                              step.instruction,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Text(
                              _formatStepDist(step.distanceMeters),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ==================== RIGHT-SIDE MAP CONTROLS ====================
          Positioned(
            right: 14.w,
            bottom: 225.h,
            child: Column(
              children: [
                _MapActionButton(
                  icon: Icons.my_location_rounded,
                  color: _followRider ? _accentColor : AppColors.charcoal,
                  onTap: () {
                    setState(() => _followRider = true);
                    if (_riderLatLng != null) {
                      _mapController.move(_riderLatLng!, 15.8);
                    }
                  },
                ),
                SizedBox(height: 8.h),
                _MapActionButton(
                  icon: Icons.fit_screen_rounded,
                  color: AppColors.charcoal,
                  onTap: () {
                    setState(() => _followRider = false);
                    _fitFullRoute();
                  },
                ),
                SizedBox(height: 8.h),
                _MapActionButton(
                  icon: Icons.refresh_rounded,
                  color: AppColors.charcoal,
                  onTap: _loadRoute,
                ),
              ],
            ),
          ),

          // ==================== BOTTOM NAVIGATION SUMMARY PANEL ====================
          Positioned(
            left: 14.w,
            right: 14.w,
            bottom: 16.h,
            child: SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Switch between Pickup & Drop-off right inside navigation
                    Row(
                      children: [
                        Expanded(
                          child: _TargetPill(
                            label: l10n.pickupLabel,
                            icon: Icons.storefront_rounded,
                            selected: _isTargetingPickup,
                            accentColor: _accentColor,
                            onTap: () => _switchTarget(toPickup: true),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _TargetPill(
                            label: l10n.dropoffLabel,
                            icon: Icons.flag_rounded,
                            selected: !_isTargetingPickup,
                            accentColor: _accentColor,
                            onTap: () => _switchTarget(toPickup: false),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // ETA + Distance + Call Action Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _route?.formattedEta ?? '-- min',
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                      color: _accentColor,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '(${_route?.formattedDistance ?? '-- km'})',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                _targetPoint.contactName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _targetPoint.addressText,
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
                        SizedBox(width: 10.w),
                        IconButton.filled(
                          tooltip: l10n.call,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            minimumSize: Size(46.w, 46.w),
                          ),
                          icon: Icon(Icons.call_rounded, size: 22.sp),
                          onPressed: () => ExternalLauncher.openPhoneDialer(
                            context,
                            _targetPoint.contactPhone,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MapActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(242),
      borderRadius: BorderRadius.circular(12.r),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(icon, size: 21.sp, color: color),
        ),
      ),
    );
  }
}

class _TargetPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _TargetPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: selected ? accentColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? accentColor : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15.sp,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
