import 'package:equatable/equatable.dart';

class LocationPointEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String contactName;
  final String contactPhone;
  final String addressText;

  const LocationPointEntity({
    required this.latitude,
    required this.longitude,
    required this.contactName,
    required this.contactPhone,
    required this.addressText,
  });

  LocationPointEntity copyWith({
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactPhone,
    String? addressText,
  }) {
    return LocationPointEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      addressText: addressText ?? this.addressText,
    );
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        contactName,
        contactPhone,
        addressText,
      ];
}
