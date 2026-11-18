import 'package:delivery_app/features/tracking/domain/entities/rider_location_entity.dart';

class RiderLocationModel extends RiderLocationEntity {
  const RiderLocationModel({
    required super.latitude,
    required super.longitude,
    super.heading,
    super.speed,
    required super.timestamp,
  });

  factory RiderLocationModel.fromJson(Map<String, dynamic> json) {
    return RiderLocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 33.6844,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 73.0479,
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
