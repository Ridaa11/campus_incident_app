import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      context.read<AuthProvider>().checkVerified();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 72),
              const SizedBox(height: 16),
              Text('Verify your email',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to ${auth.email ?? 'your email'}. '
                'Open it, then come back here. Check your spam folder too.',
                textAlign: TextAlign.center,
              ),
              if (auth.info != null) ...[
                const SizedBox(height: 12),
                Text(auth.info!),
              ],
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => auth.checkVerified(),
                child: const Text("I've verified my email"),
              ),
              TextButton(
                onPressed: auth.isBusy ? null : auth.resendVerification,
                child: const Text('Resend email'),
              ),
              TextButton(
                onPressed: auth.logout,
                child: const Text('Use a different account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}