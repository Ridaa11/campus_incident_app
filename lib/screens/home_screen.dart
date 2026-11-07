import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../widgets/incident_card.dart';
import 'incident_detail_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<IncidentProvider>();
    final cs = Theme.of(context).colorScheme;
    final user = auth.profile!;

    final all = p.allIncidents;
    final scope =
        auth.isStaff ? all : all.where((i) => i.reporterId == user.uid).toList();
    int count(IncidentStatus s) => scope.where((i) => i.status == s).length;
    final recent = scope.take(5).toList();
    final firstName = user.displayName.trim().split(' ').first;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Hello, $firstName 👋',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: Text(
                    firstName.isEmpty ? '?' : firstName[0].toUpperCase(),
                    style: TextStyle(
                        color: cs.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Help make our campus safer.',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Text('Report issues and track their resolution.',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  cs.primary,
                  Color.alphaBlend(
                      Colors.white.withValues(alpha: 0.3), cs.primary),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('See an issue\non campus?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Report it and help improve\nour learning environment.',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReportScreen())),
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Report an Issue'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _header(context, 'Report Summary'),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(Icons.description_outlined,
                  auth.isStaff ? 'All reports' : 'My Reports',
                  scope.length, cs.primary),
              _Stat(Icons.schedule, 'In Progress',
                  count(IncidentStatus.inProgress), Colors.blue),
              _Stat(Icons.check_circle_outline, 'Resolved',
                  count(IncidentStatus.resolved), Colors.green),
              _Stat(Icons.send_outlined, 'Submitted',
                  count(IncidentStatus.submitted), Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          _header(context, 'Recent Reports'),
          const SizedBox(height: 4),
          if (p.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (p.error != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(p.error!, textAlign: TextAlign.center),
            )
          else if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No reports yet.\nTap "Report an Issue" to start.',
                  textAlign: TextAlign.center),
            )
          else
            for (final i in recent)
              IncidentCard(
                incident: i,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => IncidentDetailScreen(incident: i))),
              ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String title) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.label, this.value, this.color);

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text('$value',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}