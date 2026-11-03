import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, staff }

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.createdAt,
  });

  bool get isStaff => role == UserRole.staff;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] == 'staff' ? UserRole.staff : UserRole.student,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
}