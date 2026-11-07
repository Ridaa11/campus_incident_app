import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'report_screen.dart';
import 'reports_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final IncidentProvider _incidents;
  int _dest = 0; // 0 home, 1 reports, 3 profile (2 is the Report button)

  @override
  void initState() {
    super.initState();
    _incidents = context.read<IncidentProvider>();
    _incidents.start(context.read<AuthProvider>().profile!.uid);
  }

  @override
  void dispose() {
    _incidents.stop();
    super.dispose();
  }

  void _openReport() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ReportScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pages = [
      HomeScreen(onSeeAll: () => setState(() => _dest = 1)),
      const ReportsScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _dest == 3 ? 2 : _dest, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _dest,
        onDestinationSelected: (i) {
          if (i == 2) {
            _openReport();
          } else {
            setState(() => _dest = i);
          }
        },
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          const NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description),
              label: 'Reports'),
          NavigationDestination(
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: cs.primary,
              child: Icon(Icons.add, color: cs.onPrimary),
            ),
            label: 'Report',
          ),
          const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}