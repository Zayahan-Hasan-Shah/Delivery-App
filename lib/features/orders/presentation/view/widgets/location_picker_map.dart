import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/l10n/app_localizations.dart';

class LocationPickerMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double? senderLatitude;
  final double? senderLongitude;
  final bool isLocating;
  final bool isPickup;
  final void Function(double lat, double lng) onLocationChanged;
  final VoidCallback? onGpsPressed;

  const LocationPickerMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.senderLatitude,
    this.senderLongitude,
    this.isLocating = false,
    required this.isPickup,
    required this.onLocationChanged,
    this.onGpsPressed,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  late final MapController _mapController;
  late LatLng _currentPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentPosition = LatLng(widget.latitude, widget.longitude);
  }

  @override
  void didUpdateWidget(covariant LocationPickerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _currentPosition = LatLng(widget.latitude, widget.longitude);
      _mapController.move(_currentPosition, _mapController.camera.zoom);
    } else if (oldWidget.senderLatitude != widget.senderLatitude &&
        widget.senderLatitude != null &&
        widget.isPickup) {
      _currentPosition = LatLng(widget.senderLatitude!, widget.senderLongitude!);
      _mapController.move(_currentPosition, 15.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final markerColor =
        widget.isPickup ? AppColors.charcoal : AppColors.primary;

    final hasSenderLoc =
        widget.senderLatitude != null && widget.senderLongitude != null;
    final senderLatLng = hasSenderLoc
        ? LatLng(widget.senderLatitude!, widget.senderLongitude!)
        : null;

    final markers = <Marker>[
      if (senderLatLng != null)
        Marker(
          point: senderLatLng,
          width: 90.w,
          height: 60.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  l10n.youAreHere,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.info,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(55),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 13.w,
                    height: 13.w,
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      Marker(
        point: _currentPosition,
        width: 46.w,
        height: 46.w,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: markerColor.withAlpha(102),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                widget.isPickup ? Icons.location_on : Icons.flag,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
            Container(width: 3.w, height: 6.h, color: markerColor),
          ],
        ),
      ),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: senderLatLng ?? _currentPosition,
            initialZoom: 15.0,
            onTap: (tapPosition, point) {
              setState(() => _currentPosition = point);
              widget.onLocationChanged(point.latitude, point.longitude);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.shefscloud.delivery',
            ),
            MarkerLayer(markers: markers),
          ],
        ),

        // Top coordinate hint pill
        Positioned(
          top: 10.h,
          left: 10.w,
          right: 10.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(240),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.isPickup ? Icons.my_location : Icons.pin_drop,
                  size: 15.sp,
                  color: markerColor,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '${l10n.tapMapToSetPin}: (${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)})',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Use My Location shortcut pill
        if (widget.isPickup && widget.onGpsPressed != null)
          Positioned(
            bottom: 12.h,
            left: 12.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLocating ? null : widget.onGpsPressed,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primary.withAlpha(110),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isLocating)
                        SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.gps_fixed,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                      SizedBox(width: 6.w),
                      Text(
                        widget.isLocating
                            ? l10n.locatingGps
                            : l10n.useMyLocation,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Re-center FAB
        Positioned(
          bottom: 12.h,
          right: 12.w,
          child: FloatingActionButton.small(
            heroTag: 'picker_recenter_${widget.isPickup}',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.charcoal,
            onPressed: () => _mapController.move(_currentPosition, 15.5),
            child: Icon(Icons.center_focus_strong, size: 19.sp),
          ),
        ),
      ],
    );
  }
}
