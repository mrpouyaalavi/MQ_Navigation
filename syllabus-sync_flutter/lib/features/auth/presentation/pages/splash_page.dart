import 'package:flutter/material.dart';
import 'package:syllabus_sync/app/theme/mq_colors.dart';

/// Shown on launch while the session is being resolved.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MqColors.alabaster,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_rounded,
              size: 80,
              color: MqColors.red,
              semanticLabel: 'Syllabus Sync logo',
            ),
            const SizedBox(height: 24),
            Text(
              'Syllabus Sync',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: MqColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: MqColors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
