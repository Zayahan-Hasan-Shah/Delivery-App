import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String? profileImageUrl;

  // Sender-specific fields (Restaurant / Business info)
  final String? restaurantName;
  final String? restaurantAddress;

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
        cnicNumber,
        drivingLicenseImagePath,
        bikePapersImagePath,
        documentsVerified,
        isOnline,
      ];
}
