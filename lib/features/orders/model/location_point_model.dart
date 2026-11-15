import 'package:equatable/equatable.dart';

class LocationPointModel extends Equatable {
  final String contactName;
  final String contactPhone;
  final String address;
  final double latitude;
  final double longitude;

  const LocationPointModel({
    required this.contactName,
    required this.contactPhone,
    this.address = '',
    required this.latitude,
    required this.longitude,
  });

  LocationPointModel copyWith({
    String? contactName,
    String? contactPhone,
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return LocationPointModel(
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory LocationPointModel.fromJson(Map<String, dynamic> json) {
    return LocationPointModel(
      contactName: json['contactName'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactName': contactName,
      'contactPhone': contactPhone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [contactName, contactPhone, address, latitude, longitude];
}
