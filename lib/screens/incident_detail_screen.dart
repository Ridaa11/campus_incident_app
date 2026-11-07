import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/incident.dart';
import '../widgets/status_chip.dart';
import '../widgets/status_update_panel.dart';

import 'package:provider/provider.dart';
import '../providers/incident_provider.dart';
import '../widgets/status_update_panel.dart';

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
        final incident = context.select<IncidentProvider, Incident>((p) =>
        p.allIncidents.firstWhere((i) => i.id == this.incident.id,
            orElse: () => this.incident));
    final fmt = DateFormat('d MMM yyyy, HH:mm');
    final small = TextStyle(color: Colors.grey.shade600, fontSize: 13);
    final heading = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(incident.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      StatusChip(incident.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(incident.category.icon, size: 16),
                    const SizedBox(width: 6),
                    Text(incident.category.label, style: small),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.place_outlined, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(incident.location, style: small)),
                  ]),
                  const SizedBox(height: 4),
                  if (incident.createdAt != null)
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Submitted ${fmt.format(incident.createdAt!)}',
                          style: small),
                    ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 6),
                    Text('Reported by ${incident.reporterName}', style: small),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Status Timeline', style: heading),
            const SizedBox(height: 12),
            _Timeline(
              status: incident.status,
              created: incident.createdAt,
              updated: incident.updatedAt,
            ),
            const SizedBox(height: 20),
            StatusUpdatePanel(incident: incident),
            Text('Description', style: heading),
            const SizedBox(height: 6),
            Text(incident.description),
            if (incident.photoUrl != null) ...[
              const SizedBox(height: 20),
              Text('Attached Photo', style: heading),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  incident.photoUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (c, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          height: 220,
                          child: Center(child: CircularProgressIndicator())),
                  errorBuilder: (c, e, s) => const SizedBox(
                      height: 220,
                      child: Center(child: Icon(Icons.broken_image, size: 48))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.status,
    required this.created,
    required this.updated,
  });

  final IncidentStatus status;
  final DateTime? created;
  final DateTime? updated;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final steps = IncidentStatus.values;
    final current = status.index;
    final dateFmt = DateFormat('d MMM, HH:mm');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 0
                            ? Colors.transparent
                            : (i <= current ? cs.primary : Colors.grey.shade300),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i <= current ? cs.primary : Colors.grey.shade300,
                      ),
                      child: Icon(
                        i < current || (i == current && i == steps.length - 1)
                            ? Icons.check
                            : (i == current ? Icons.circle : null),
                        size: i == current && i != steps.length - 1 ? 8 : 14,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == steps.length - 1
                            ? Colors.transparent
                            : (i < current ? cs.primary : Colors.grey.shade300),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(steps[i].label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            i == current ? FontWeight.bold : FontWeight.normal)),
                Text(
                  i == 0 && created != null
                      ? dateFmt.format(created!)
                      : (i == current && i != 0 && updated != null
                          ? dateFmt.format(updated!)
                          : ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
