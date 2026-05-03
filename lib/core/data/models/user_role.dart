enum UserRole {
  user,
  admin;

  String get value => name;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  static const UserRole defaultRole = UserRole.user;
}
