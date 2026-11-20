import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/features/tracking/domain/entities/tracking_data_entity.dart';
import 'package:delivery_app/shared/widgets/app_tile_layer.dart';

class DeliveryMapWidget extends StatelessWidget {
  final TrackingDataEntity trackingData;

  const DeliveryMapWidget({super.key, required this.trackingData});

  @override
  Widget build(BuildContext context) {
    final pickup = LatLng(
      trackingData.order.pickup.latitude,
      trackingData.order.pickup.longitude,
    );
    final dropoff = LatLng(
      trackingData.order.dropoff.latitude,
      trackingData.order.dropoff.longitude,
    );
    final rider = trackingData.riderLocation != null
        ? LatLng(
            trackingData.riderLocation!.latitude,
            trackingData.riderLocation!.longitude,
          )
        : LatLng(
            pickup.latitude + (dropoff.latitude - pickup.latitude) * 0.45,
            pickup.longitude + (dropoff.longitude - pickup.longitude) * 0.45,
          );

    final bounds = LatLngBounds.fromPoints([pickup, dropoff, rider]);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        height: 250.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: rider,
            initialZoom: 13.5,
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: EdgeInsets.all(28.w),
              minZoom: 12.0,
              maxZoom: 16.0,
            ),
          ),
          children: [
            const AppTileLayer(),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [pickup, rider, dropoff],
                  color: AppColors.primary,
                  strokeWidth: 4.0,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: pickup,
                  width: 34.w,
                  height: 34.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
                Marker(
                  point: dropoff,
                  width: 34.w,
                  height: 34.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
                Marker(
                  point: rider,
                  width: 42.w,
                  height: 42.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(110),
                          blurRadius: 10,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
