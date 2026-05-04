enum UserRole {
  member,
  admin;

  String get value => name;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.value == role.toLowerCase(),
      orElse: () => UserRole.member,
    );
  }
}
