import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<IncidentProvider>();
    final cs = Theme.of(context).colorScheme;
    final user = auth.profile!;
    final mine = p.allIncidents.where((i) => i.reporterId == user.uid).toList();
    int count(IncidentStatus s) => mine.where((i) => i.status == s).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: cs.primaryContainer,
              child: Text(
                user.displayName.isEmpty ? '?' : user.displayName[0].toUpperCase(),
                style: TextStyle(
                    fontSize: 32,
                    color: cs.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(user.displayName,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Center(child: Text(user.email)),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              label: Text(user.isStaff ? 'Staff' : 'Student'),
              backgroundColor: cs.primaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _tile('Total reports', mine.length, cs.primary),
              _tile('In progress', count(IncidentStatus.inProgress), Colors.blue),
              _tile('Resolved', count(IncidentStatus.resolved), Colors.green),
            ],
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: auth.logout,
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  Widget _tile(String label, int value, Color color) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text('$value',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
}