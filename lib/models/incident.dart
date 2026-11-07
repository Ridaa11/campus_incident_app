import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum IncidentCategory {
  facilities,
  water,
  electricity,
  furniture,
  sanitation,
  safety,
  other
}

extension IncidentCategoryX on IncidentCategory {
  String get label => switch (this) {
        IncidentCategory.facilities => 'Broken facilities',
        IncidentCategory.water => 'Water shortage',
        IncidentCategory.electricity => 'Electricity outage',
        IncidentCategory.furniture => 'Damaged furniture',
        IncidentCategory.sanitation => 'Sanitation',
        IncidentCategory.safety => 'Safety concern',
        IncidentCategory.other => 'Other',
      };

  IconData get icon => switch (this) {
        IncidentCategory.facilities => Icons.construction,
        IncidentCategory.water => Icons.water_drop_outlined,
        IncidentCategory.electricity => Icons.bolt,
        IncidentCategory.furniture => Icons.chair_alt_outlined,
        IncidentCategory.sanitation => Icons.clean_hands_outlined,
        IncidentCategory.safety => Icons.health_and_safety_outlined,
        IncidentCategory.other => Icons.more_horiz,
      };
}

enum IncidentStatus { submitted, inReview, inProgress, resolved }

extension IncidentStatusX on IncidentStatus {
  String get label => switch (this) {
        IncidentStatus.submitted => 'Submitted',
        IncidentStatus.inReview => 'In review',
        IncidentStatus.inProgress => 'In progress',
        IncidentStatus.resolved => 'Resolved',
      };

  Color get color => switch (this) {
        IncidentStatus.submitted => Colors.grey,
        IncidentStatus.inReview => Colors.orange,
        IncidentStatus.inProgress => Colors.blue,
        IncidentStatus.resolved => Colors.green,
      };
}

T _parse<T extends Enum>(List<T> values, String? name, T fallback) =>
    values.firstWhere((v) => v.name == name, orElse: () => fallback);

class Incident {
  final String id;
  final String title;
  final String description;
  final String location;
  final IncidentCategory category;
  final IncidentStatus status;
  final String? photoUrl;
  final String reporterId;
  final String reporterName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Incident(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      location: d['location'] ?? '',
      category: _parse(IncidentCategory.values, d['category'],
          IncidentCategory.other),
      status:
          _parse(IncidentStatus.values, d['status'], IncidentStatus.submitted),
      photoUrl: d['photoUrl'],
      reporterId: d['reporterId'] ?? '',
      reporterName: d['reporterName'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}