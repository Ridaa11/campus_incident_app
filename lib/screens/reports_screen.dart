import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/incident_provider.dart';
import '../widgets/incident_card.dart';
import 'incident_detail_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final list = p.incidents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: TextField(
              onChanged: p.setQuery,
              decoration: InputDecoration(
                hintText: 'Search title, description or location',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('All', p.statusFilter == null, () => p.setStatus(null)),
                for (final s in IncidentStatus.values)
                  _chip(s.label, p.statusFilter == s, () => p.setStatus(s)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<IncidentCategory?>(
                    value: p.categoryFilter,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All categories')),
                      for (final c in IncidentCategory.values)
                        DropdownMenuItem(value: c, child: Text(c.label)),
                    ],
                    onChanged: p.setCategory,
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('My reports'),
                  selected: p.mineOnly,
                  onSelected: p.setMineOnly,
                ),
              ],
            ),
          ),
          Expanded(child: _body(context, p, list)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );

  Widget _body(BuildContext context, IncidentProvider p, List<Incident> list) {
    if (p.isLoading) return const Center(child: CircularProgressIndicator());
    if (p.error != null) {
      return Center(child: Text(p.error!, textAlign: TextAlign.center));
    }
    if (list.isEmpty) {
      return Center(
        child: Text(
          p.totalCount == 0 ? 'No reports yet.' : 'No reports match your filters.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) => IncidentCard(
        incident: list[i],
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => IncidentDetailScreen(incident: list[i]))),
      ),
    );
  }
}