enum UserRole {
  sender,
  rider;

  static UserRole fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'rider':
        return UserRole.rider;
      case 'sender':
      case 'customer': // Graceful backward-compatibility for stored tokens
      default:
        return UserRole.sender;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.sender:
        return 'Sender';
      case UserRole.rider:
        return 'Rider';
    }
  }

  bool get isSender => this == UserRole.sender;
  bool get isRider => this == UserRole.rider;
}
