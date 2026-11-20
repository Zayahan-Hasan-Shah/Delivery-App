import 'package:delivery_app/features/authentication/domain/entities/user_entity.dart';
import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.role,
    super.profileImageUrl,
    super.restaurantName,
    super.restaurantAddress,
    super.pickupAddress,
    super.latitude,
    super.longitude,
    super.cnicNumber,
    super.drivingLicenseImagePath,
    super.bikePapersImagePath,
    super.documentsVerified,
    super.isOnline,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      role: entity.role,
      profileImageUrl: entity.profileImageUrl,
      restaurantName: entity.restaurantName,
      restaurantAddress: entity.restaurantAddress,
      pickupAddress: entity.pickupAddress ?? entity.restaurantAddress,
      latitude: entity.latitude,
      longitude: entity.longitude,
      cnicNumber: entity.cnicNumber,
      drivingLicenseImagePath: entity.drivingLicenseImagePath,
      bikePapersImagePath: entity.bikePapersImagePath,
      documentsVerified: entity.documentsVerified,
      isOnline: entity.isOnline,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final addr = json['pickup_address']?.toString() ??
        json['restaurant_address']?.toString();
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: UserRole.fromString(json['role']?.toString() ?? 'sender'),
      profileImageUrl: json['profile_image_url']?.toString(),
      restaurantName: json['restaurant_name']?.toString(),
      restaurantAddress: addr,
      pickupAddress: addr,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      cnicNumber: json['cnic_number']?.toString(),
      drivingLicenseImagePath: json['driving_license_image_path']?.toString(),
      bikePapersImagePath: json['bike_papers_image_path']?.toString(),
      documentsVerified: json['documents_verified'] == true,
      isOnline: json['is_online'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.name,
      'profile_image_url': profileImageUrl,
      'restaurant_name': restaurantName,
      'restaurant_address': restaurantAddress,
      'pickup_address': pickupAddress ?? restaurantAddress,
      'latitude': latitude,
      'longitude': longitude,
      'cnic_number': cnicNumber,
      'driving_license_image_path': drivingLicenseImagePath,
      'bike_papers_image_path': bikePapersImagePath,
      'documents_verified': documentsVerified,
      'is_online': isOnline,
    };
  }
}
