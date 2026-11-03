import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../utils/constants.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  /// Emits whenever the user signs in, signs out, or is reloaded.
  Stream<User?> get userChanges => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  static bool isAllowedEmail(String email) {
    final value = email.trim().toLowerCase();
    return AppConstants.allowedEmailDomains
        .any((domain) => value.endsWith('@$domain'));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!isAllowedEmail(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email-domain',
        message: 'Please use your ALU email address.',
      );
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());

    // Everyone registers as a student. Staff are promoted by an admin.
    final profile = AppUser(
      uid: user.uid,
      email: email.trim().toLowerCase(),
      displayName: name.trim(),
      role: UserRole.student,
    );
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(profile.toMap());

    await user.sendEmailVerification();
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> resendVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Re-fetches the user so emailVerified is up to date.
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> logout() => _auth.signOut();

  Future<AppUser?> fetchProfile(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }
}