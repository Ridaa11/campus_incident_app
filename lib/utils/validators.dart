import '../repositories/auth_repository.dart';

class Validators {
  static String? name(String? v) {
    if (v == null || v.trim().length < 2) return 'Enter your full name';
    return null;
  }

  static String? aluEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your email';
    if (!v.contains('@')) return 'Enter a valid email';
    if (!AuthRepository.isAllowedEmail(v)) {
      return 'Use your ALU email address';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.length < 8) return 'At least 8 characters';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (v) => v != original() ? 'Passwords do not match' : null;
  }
}