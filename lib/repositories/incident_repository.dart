import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../utils/constants.dart';

class IncidentRepository {
  IncidentRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.incidentsCollection);

  /// Live list of all incidents, newest first.
  Stream<List<Incident>> watchIncidents() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Incident.fromDoc).toList());
  }
    Future<void> updateStatus(String id, IncidentStatus status) async {
    await _col.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> create({
    required AppUser user,
    required String title,
    required String description,
    required String location,
    required IncidentCategory category,
    File? image,
  }) async {
    final ref = _col.doc();
    String? photoUrl;

    if (image != null) {
      final storageRef =
          _storage.ref('incident_images/${user.uid}/${ref.id}.jpg');
      await storageRef.putFile(
        image,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      photoUrl = await storageRef.getDownloadURL();
    }

    await ref.set({
      'title': title.trim(),
      'description': description.trim(),
      'location': location.trim(),
      'category': category.name,
      'status': IncidentStatus.submitted.name,
      'photoUrl': photoUrl,
      'reporterId': user.uid,
      'reporterName': user.displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}