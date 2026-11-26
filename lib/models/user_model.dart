enum UserRole { resident, admin }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.resident:
        return 'Resident';
    }
  }

  static UserRole fromString(String? val) {
    if (val?.toLowerCase() == 'admin') return UserRole.admin;
    return UserRole.resident;
  }
}

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isResident => role == UserRole.resident;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'User',
      role: UserRoleExtension.fromString(map['role']),
    );
  }
}
