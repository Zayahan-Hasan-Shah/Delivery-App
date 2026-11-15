import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';
import 'package:delivery_app/features/tracking/model/rider_location.dart';
import 'package:delivery_app/core/theme/app_colors.dart';

class DeliveryMapWidget extends StatefulWidget {
  final OrderModel order;
  final RiderLocation? liveRiderLocation;

  const DeliveryMapWidget({
    super.key,
    required this.order,
    this.liveRiderLocation,
  });

  @override
  State<DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<DeliveryMapWidget> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant DeliveryMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Smoothly follow rider if updated
    if (widget.liveRiderLocation != null &&
        (oldWidget.liveRiderLocation?.latitude !=
                widget.liveRiderLocation?.latitude ||
            oldWidget.liveRiderLocation?.longitude !=
                widget.liveRiderLocation?.longitude)) {
      // Optional camera tracking
    }
  }

  void _fitBounds() {
    final points = [
      LatLng(widget.order.pickup.latitude, widget.order.pickup.longitude),
      LatLng(widget.order.dropoff.latitude, widget.order.dropoff.longitude),
      if (widget.liveRiderLocation != null)
        LatLng(
          widget.liveRiderLocation!.latitude,
          widget.liveRiderLocation!.longitude,
        ),
    ];

    if (points.length >= 2) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickupPoint = LatLng(
      widget.order.pickup.latitude,
      widget.order.pickup.longitude,
    );
    final dropoffPoint = LatLng(
      widget.order.dropoff.latitude,
      widget.order.dropoff.longitude,
    );

    final riderPoint = widget.liveRiderLocation != null
        ? LatLng(
            widget.liveRiderLocation!.latitude,
            widget.liveRiderLocation!.longitude,
          )
        : null;

    final markers = <Marker>[
      // Pickup Marker
      Marker(
        point: pickupPoint,
        width: 44,
        height: 44,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withAlpha(102),
                blurRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.trip_origin, color: Colors.white, size: 20),
        ),
      ),

      // Drop-off Marker
      Marker(
        point: dropoffPoint,
        width: 44,
        height: 44,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withAlpha(102),
                blurRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.flag, color: Colors.white, size: 20),
        ),
      ),

      // Rider Marker (Live Position)
      if (riderPoint != null)
        Marker(
          point: riderPoint,
          width: 52,
          height: 52,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withAlpha(153),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.two_wheeler, color: Colors.white, size: 24),
          ),
        ),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: riderPoint ?? pickupPoint,
            initialZoom: 13.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.deliveryapp.logiflow',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    pickupPoint,
                    if (riderPoint != null) riderPoint,
                    dropoffPoint,
                  ],
                  color: AppColors.primaryLight.withAlpha(178),
                  strokeWidth: 4.0,
                  pattern: const StrokePattern.dotted(),
                ),
              ],
            ),
            MarkerLayer(markers: markers),
          ],
        ),

        // Fit Bounds Button
        Positioned(
          top: 12,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'fit_bounds_tag',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            onPressed: _fitBounds,
            child: const Icon(Icons.center_focus_strong),
          ),
        ),
      ],
    );
  }
}
