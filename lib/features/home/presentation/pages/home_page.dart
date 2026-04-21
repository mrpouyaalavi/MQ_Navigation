import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mq_navigation/app/router/route_names.dart';
import 'package:mq_navigation/app/l10n/generated/app_localizations.dart';
import 'package:mq_navigation/app/theme/mq_colors.dart';
import 'package:mq_navigation/app/theme/mq_spacing.dart';
import 'package:mq_navigation/features/map/presentation/controllers/map_controller.dart';
import 'package:mq_navigation/shared/widgets/mq_app_bar.dart';

/// Navigation-focused home screen for the Open Day app.
///
/// Provides quick access to the campus map and key campus categories.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final subtitleColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: MqAppBar(title: l10n.appName),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(MqSpacing.space4),
          child: Column(
            children: [
              const SizedBox(height: MqSpacing.space6),

              // Logo area
              Container(
                width: 2 * MqSpacing.space12,
                height: 2 * MqSpacing.space12,
                decoration: BoxDecoration(
                  color: MqColors.red,
                  borderRadius: BorderRadius.circular(MqSpacing.radiusFull),
                ),
                child: Icon(
                  Icons.school,
                  size: MqSpacing.iconHero,
                  color: Colors.white,
                  semanticLabel: l10n.appName,
                ),
              ),
              const SizedBox(height: MqSpacing.space4),
              Text(
                l10n.welcomeTo(l10n.appName),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: MqSpacing.space2),
              Text(
                'Find buildings, parking, food, and services across Macquarie University campus.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: subtitleColor,
                ),
              ),

              const SizedBox(height: MqSpacing.space8),

              // Primary CTA — Explore Campus
              SizedBox(
                width: double.infinity,
                height: MqSpacing.minTapTarget + MqSpacing.space2,
                child: FilledButton.icon(
                  icon: Icon(
                    Icons.map,
                    size: MqSpacing.iconDefault,
                    semanticLabel: l10n.exploreMap,
                  ),
                  label: Text(
                    l10n.exploreMap,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => context.goNamed(RouteNames.map),
                ),
              ),

              const SizedBox(height: MqSpacing.space6),

              // Map modes explainer
              Container(
                padding: const EdgeInsets.all(MqSpacing.space3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(MqSpacing.radiusMd),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          size: 16,
                          color: MqColors.vividRed,
                        ),
                        const SizedBox(width: MqSpacing.space2),
                        Text(
                          'Two ways to find your way',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: MqSpacing.space2),
                    Text(
                      '• Campus map — a visual leaflet of MQ. Your '
                      'destination is highlighted and you find your way there.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: MqSpacing.space1),
                    Text(
                      '• Google Maps — for turn-by-turn directions and '
                      'live routing.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: MqSpacing.space6),

              // Quick access grid
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Quick Access',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: MqSpacing.space1),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Tap a category to filter the map. Switch between campus and '
                  'Google Maps from the toggle at the top.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                  ),
                ),
              ),
              const SizedBox(height: MqSpacing.space3),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: MqSpacing.space3,
                crossAxisSpacing: MqSpacing.space3,
                childAspectRatio: 1.2,
                children: [
                  _QuickAccessCard(
                    icon: Icons.restaurant,
                    label: l10n.food,
                    color: MqColors.warning,
                    searchQuery: 'food',
                  ),
                  _QuickAccessCard(
                    icon: Icons.local_parking,
                    label: l10n.parking,
                    color: MqColors.purple,
                    searchQuery: 'parking',
                  ),
                  const _QuickAccessCard(
                    icon: Icons.menu_book,
                    label: 'Library',
                    color: MqColors.info,
                    searchQuery: 'library',
                  ),
                  const _QuickAccessCard(
                    icon: Icons.school,
                    label: 'Student Centre',
                    color: MqColors.red,
                    searchQuery: 'student centre',
                  ),
                  const _QuickAccessCard(
                    icon: Icons.directions_bus,
                    label: 'Transport',
                    color: MqColors.success,
                    searchQuery: 'bus',
                  ),
                  _QuickAccessCard(
                    icon: Icons.support_agent,
                    label: l10n.services,
                    color: MqColors.info,
                    searchQuery: 'services',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessCard extends ConsumerWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.searchQuery,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: label,
      child: Card(
        child: InkWell(
          onTap: () {
            // Update the map controller state directly before switching tabs.
            // This works because Riverpod state is shared globally across the
            // widget tree. Since StatefulShellRoute preserves the MapPage
            // widget (its initState only fires once), we must update the state
            // imperatively rather than relying on route parameters.
            ref
                .read(mapControllerProvider.notifier)
                .updateSearchQuery(searchQuery);
            context.goNamed(RouteNames.map);
          },
          borderRadius: BorderRadius.circular(MqSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(MqSpacing.space3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: MqSpacing.iconLg, color: color),
                const SizedBox(height: MqSpacing.space2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
