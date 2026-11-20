import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String? profileImageUrl;

  // Sender-specific fields (Pickup Address & coordinates)
  final String? restaurantName;
  final String? restaurantAddress;
  final String? pickupAddress;
  final double? latitude;
  final double? longitude;

  // Rider-specific fields (KYC documents & online shift)
  final String? cnicNumber;
  final String? drivingLicenseImagePath;
  final String? bikePapersImagePath;
  final bool documentsVerified;
  final bool isOnline;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.profileImageUrl,
    this.restaurantName,
    this.restaurantAddress,
    this.pickupAddress,
    this.latitude,
    this.longitude,
    this.cnicNumber,
    this.drivingLicenseImagePath,
    this.bikePapersImagePath,
    this.documentsVerified = false,
    this.isOnline = false,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? profileImageUrl,
    String? restaurantName,
    String? restaurantAddress,
    String? pickupAddress,
    double? latitude,
    double? longitude,
    String? cnicNumber,
    String? drivingLicenseImagePath,
    String? bikePapersImagePath,
    bool? documentsVerified,
    bool? isOnline,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cnicNumber: cnicNumber ?? this.cnicNumber,
      drivingLicenseImagePath:
          drivingLicenseImagePath ?? this.drivingLicenseImagePath,
      bikePapersImagePath: bikePapersImagePath ?? this.bikePapersImagePath,
      documentsVerified: documentsVerified ?? this.documentsVerified,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        role,
        profileImageUrl,
        restaurantName,
        restaurantAddress,
        pickupAddress,
        latitude,
        longitude,
        cnicNumber,
        drivingLicenseImagePath,
        bikePapersImagePath,
        documentsVerified,
        isOnline,
      ];
}
