import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';

/// Visible to staff only. The server also enforces this in Firestore rules.
class StatusUpdatePanel extends StatelessWidget {
  const StatusUpdatePanel({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AuthProvider>().isStaff) return const SizedBox.shrink();
    final provider = context.read<IncidentProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Update status (staff)',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final s in IncidentStatus.values)
              ChoiceChip(
                label: Text(s.label),
                selected: incident.status == s,
                onSelected: (_) async {
                  if (incident.status == s) return;
                  final ok = await provider.updateStatus(incident.id, s);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok
                        ? 'Status changed to ${s.label}'
                        : 'Update failed. Check your connection.'),
                  ));
                },
              ),
          ],
        ),
      ],
    );
  }
}