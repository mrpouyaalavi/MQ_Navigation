import 'package:flutter/material.dart';
import 'package:syllabus_sync/app/theme/mq_spacing.dart';

/// Dashboard home page — placeholder cards, full implementation in Phase 3.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(MqSpacing.space4),
        children: [
          _PlaceholderCard(
            title: 'Upcoming Deadlines',
            icon: Icons.assignment_outlined,
          ),
          _PlaceholderCard(
            title: 'Today\'s Schedule',
            icon: Icons.schedule_outlined,
          ),
          _PlaceholderCard(title: 'Recent Events', icon: Icons.event_outlined),
          _PlaceholderCard(
            title: 'Study Streak',
            icon: Icons.local_fire_department_outlined,
          ),
        ],
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MqSpacing.space4),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: MqSpacing.space4),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
