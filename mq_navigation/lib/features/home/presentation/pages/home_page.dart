import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_navigation/app/l10n/generated/app_localizations.dart';
import 'package:mq_navigation/app/theme/mq_spacing.dart';
import 'package:mq_navigation/shared/widgets/mq_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.home)),
      body: ListView(
        padding: const EdgeInsets.all(MqSpacing.space4),
        children: [
          MqCard(
            child: Padding(
              padding: const EdgeInsets.all(MqSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.welcome}, Student',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: MqSpacing.space2),
                  Text(
                    'Your campus navigation hub for Macquarie University.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
