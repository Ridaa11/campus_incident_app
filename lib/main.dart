import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/incident_repository.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(ctx.read<AuthRepository>()),
        ),
        Provider<IncidentRepository>(create: (_) => IncidentRepository()),
        ChangeNotifierProvider<IncidentProvider>(
          create: (ctx) => IncidentProvider(ctx.read<IncidentRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Campus Incident Reporter',
        debugShowCheckedModeBanner: false,
        
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
