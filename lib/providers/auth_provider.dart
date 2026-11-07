import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unknown, unauthenticated, unverified, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo) {
    _sub = _repo.userChanges.listen(_onUserChanged);
  }

  final AuthRepository _repo;
  StreamSubscription<User?>? _sub;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _profile;
  bool _busy = false;
  String? _error;
  String? _info;

  AuthStatus get status => _status;
  AppUser? get profile => _profile;
  bool get isBusy => _busy;
  bool get isStaff => _profile?.isStaff ?? false;
  String? get error => _error;
  String? get info => _info;
  String? get email => _repo.currentUser?.email;

  Future<void> _onUserChanged(User? user) async {
    if (user == null) {
      _profile = null;
      _status = AuthStatus.unauthenticated;
    } else if (!user.emailVerified) {
      _status = AuthStatus.unverified;
    } else {
      try {
        if (_profile?.uid != user.uid) {
          _profile = await _repo.fetchProfile(user.uid);
        }
        _profile ??= AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          role: UserRole.student,
        );
        _status = AuthStatus.authenticated;
      } catch (e) {
        _error = 'Could not load your profile. Please try again.';
        _status = AuthStatus.unauthenticated;
      }
    }
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    _info = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _message(e);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Check your connection and retry.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) =>
      _run(() => _repo.register(name: name, email: email, password: password));

  Future<bool> login(String email, String password) =>
      _run(() => _repo.login(email, password));

  Future<void> logout() => _repo.logout();

  Future<bool> resendVerification() async {
    final ok = await _run(_repo.resendVerification);
    if (ok) {
      _info = 'Verification email sent.';
      notifyListeners();
    }
    return ok;
  }

  Future<void> checkVerified() async {
    await _repo.reloadUser();
    await _onUserChanged(_repo.currentUser);
  }

  void clearMessages() {
    _error = null;
    _info = null;
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email-domain':
        return 'Please use your ALU email address.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}