import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../repositories/incident_repository.dart';

class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._repo);

  final IncidentRepository _repo;
  StreamSubscription<List<Incident>>? _sub;

  List<Incident> _all = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  // Filters
  String _query = '';
  IncidentStatus? _status;
  IncidentCategory? _category;
  bool _mineOnly = false;
  String _uid = '';

  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  String? get error => _error;
  String get query => _query;
  IncidentStatus? get statusFilter => _status;
  IncidentCategory? get categoryFilter => _category;
  bool get mineOnly => _mineOnly;
  int get totalCount => _all.length;
    List<Incident> get allIncidents => _all;


  List<Incident> get incidents {
    final q = _query.toLowerCase();
    return _all.where((i) {
      if (_status != null && i.status != _status) return false;
      if (_category != null && i.category != _category) return false;
      if (_mineOnly && i.reporterId != _uid) return false;
      if (q.isNotEmpty &&
          !(i.title.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q) ||
              i.location.toLowerCase().contains(q))) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Start listening to Firestore. Called when the home screen opens.
  void start(String uid) {
    _uid = uid;
    _sub?.cancel();
    _loading = true;
    _error = null;
    _sub = _repo.watchIncidents().listen(
      (list) {
        _all = list;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        _error = 'Could not load reports. Check your connection.';
        notifyListeners();
      },
    );
  }

  /// Stop listening (on logout). Does not notify, so it is safe in dispose().
  void stop() {
    _sub?.cancel();
    _sub = null;
    _all = [];
    _loading = true;
    _status = null;
    _category = null;
    _mineOnly = false;
    _query = '';
  }

  void setQuery(String v) {
    _query = v.trim();
    notifyListeners();
  }

  void setStatus(IncidentStatus? v) {
    _status = v;
    notifyListeners();
  }

  void setCategory(IncidentCategory? v) {
    _category = v;
    notifyListeners();
  }

  void setMineOnly(bool v) {
    _mineOnly = v;
    notifyListeners();
  }

  Future<bool> submit({
    required AppUser user,
    required String title,
    required String description,
    required String location,
    required IncidentCategory category,
    File? image,
  }) async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.create(
        user: user,
        title: title,
        description: description,
        location: location,
        category: category,
        image: image,
      );
      return true;
    } catch (_) {
      _error = image != null
          ? 'Could not submit. The photo upload may have failed. Try again or remove the photo.'
          : 'Could not submit the report. Check your connection.';
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void clearError() => _error = null;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
    Future<bool> updateStatus(String id, IncidentStatus status) async {
    try {
      await _repo.updateStatus(id, status);
      return true;
    } catch (_) {
      _error = 'Could not update the status.';
      notifyListeners();
      return false;
    }
  }
}