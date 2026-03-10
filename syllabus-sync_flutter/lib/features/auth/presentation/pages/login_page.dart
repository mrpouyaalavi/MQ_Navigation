import 'package:flutter/material.dart';
import 'package:syllabus_sync/app/theme/mq_colors.dart';
import 'package:syllabus_sync/app/theme/mq_spacing.dart';

/// Placeholder login page — full implementation in Phase 2.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MqSpacing.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.school_rounded,
                size: 64,
                color: MqColors.red,
                semanticLabel: 'Syllabus Sync logo',
              ),
              const SizedBox(height: MqSpacing.space4),
              Text(
                'Welcome to Syllabus Sync',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MqSpacing.space2),
              Text(
                'Sign in to manage your Macquarie University experience',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MqColors.contentTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MqSpacing.space8),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                autofillHints: [AutofillHints.email],
              ),
              const SizedBox(height: MqSpacing.space4),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                autofillHints: [AutofillHints.password],
              ),
              const SizedBox(height: MqSpacing.space6),
              FilledButton(
                onPressed: () {
                  // TODO(phase2): Wire up Supabase auth
                },
                child: const Text('Sign In'),
              ),
              const SizedBox(height: MqSpacing.space4),
              OutlinedButton(
                onPressed: () {
                  // TODO(phase2): Navigate to signup
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
