import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/core/theme/app_colors.dart';

class LocationPickerMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double? customerLatitude;
  final double? customerLongitude;
  final bool isLocating;
  final bool isPickup;
  final void Function(double lat, double lng) onLocationChanged;
  final VoidCallback? onGpsPressed;

  const LocationPickerMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.customerLatitude,
    this.customerLongitude,
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
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _currentPosition = LatLng(widget.latitude, widget.longitude);
      _mapController.move(_currentPosition, _mapController.camera.zoom);
    } else if (oldWidget.customerLatitude != widget.customerLatitude && widget.customerLatitude != null) {
      // Re-center on customer's location when first discovered
      if (widget.isPickup) {
        _currentPosition = LatLng(widget.customerLatitude!, widget.customerLongitude!);
        _mapController.move(_currentPosition, 15.5);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final markerColor = widget.isPickup ? AppColors.primaryLight : AppColors.success;
    final markerLabel = widget.isPickup ? 'Pickup Location' : 'Drop-off Destination';

    final hasCustomerLocation = widget.customerLatitude != null && widget.customerLongitude != null;
    final customerLatLng = hasCustomerLocation
        ? LatLng(widget.customerLatitude!, widget.customerLongitude!)
        : null;

    final markers = <Marker>[
      // 1. CUSTOMER'S ACTUAL DEVICE LOCATION BEACON
      if (customerLatLng != null)
        Marker(
          point: customerLatLng,
          width: 80,
          height: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Text(
                  'You Are Here',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withAlpha(120),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

      // 2. SELECTED PINPOINT MARKER (PICKUP / DROP-OFF)
      Marker(
        point: _currentPosition,
        width: 50,
        height: 50,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
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
                size: 20,
              ),
            ),
            Container(
              width: 4,
              height: 6,
              color: markerColor,
            ),
          ],
        ),
      ),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: customerLatLng ?? _currentPosition,
            initialZoom: 15.0,
            onTap: (tapPosition, point) {
              setState(() {
                _currentPosition = point;
              });
              widget.onLocationChanged(point.latitude, point.longitude);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.deliveryapp.logiflow',
            ),
            MarkerLayer(markers: markers),
          ],
        ),

        // TOP HINT BANNER
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(240),
              borderRadius: BorderRadius.circular(10),
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
                  size: 16,
                  color: markerColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tap map to set $markerLabel: (${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // "USE MY CURRENT LOCATION" SHORTCUT BUTTON (For Pickup Pin)
        if (widget.isPickup && widget.onGpsPressed != null)
          Positioned(
            bottom: 12,
            left: 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLocating ? null : widget.onGpsPressed,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryLight.withAlpha(100)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isLocating)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                          ),
                        )
                      else
                        const Icon(Icons.gps_fixed, size: 16, color: AppColors.primaryLight),
                      const SizedBox(width: 6),
                      Text(
                        widget.isLocating ? 'Locating GPS...' : 'Use My Location',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // CENTER ON PIN RE-CENTER BUTTON
        Positioned(
          bottom: 12,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'recenter_btn_${widget.isPickup}',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            onPressed: () {
              _mapController.move(_currentPosition, 15.5);
            },
            child: const Icon(Icons.center_focus_strong, size: 20),
          ),
        ),
      ],
    );
  }
}
