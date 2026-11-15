enum UserRole {
  customer,
  client,
  rider;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase().trim()) {
      case 'customer':
        return UserRole.customer;
      case 'client':
        return UserRole.client;
      case 'rider':
        return UserRole.rider;
      default:
        return UserRole.customer;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.client:
        return 'Client';
      case UserRole.rider:
        return 'Rider';
    }
  }

  bool get isCustomer => this == UserRole.customer;
  bool get isClient => this == UserRole.client;
  bool get isRider => this == UserRole.rider;
}
