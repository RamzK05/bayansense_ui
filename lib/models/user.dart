enum UserRole {
  resident('resident', 'Resident'),
  personnel('personnel', 'Barangay Personnel'),
  admin('admin', 'Administrator');

  final String value;
  final String label;
  const UserRole(this.value, this.label);

  static UserRole fromString(String val) {
    return UserRole.values.firstWhere(
      (r) => r.value.toLowerCase() == val.toLowerCase(),
      orElse: () => UserRole.resident,
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? token; // JWT bearer token

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
  });
}