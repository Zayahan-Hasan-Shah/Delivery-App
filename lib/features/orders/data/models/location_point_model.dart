import 'package:delivery_app/features/orders/domain/entities/location_point_entity.dart';

class LocationPointModel extends LocationPointEntity {
  const LocationPointModel({
    required super.latitude,
    required super.longitude,
    required super.contactName,
    required super.contactPhone,
    required super.addressText,
  });

  factory LocationPointModel.fromEntity(LocationPointEntity entity) {
    return LocationPointModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      contactName: entity.contactName,
      contactPhone: entity.contactPhone,
      addressText: entity.addressText,
    );
  }

  factory LocationPointModel.fromJson(Map<String, dynamic> json) {
    return LocationPointModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 33.6844,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 73.0479,
      contactName: json['contact_name']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString() ?? '',
      addressText: json['address_text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'address_text': addressText,
      };
}
