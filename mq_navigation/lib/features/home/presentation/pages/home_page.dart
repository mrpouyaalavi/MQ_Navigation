import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mq_navigation/app/l10n/generated/app_localizations.dart';
import 'package:mq_navigation/app/router/route_names.dart';
import 'package:mq_navigation/app/theme/mq_colors.dart';
import 'package:mq_navigation/app/theme/mq_spacing.dart';
import 'package:mq_navigation/app/theme/mq_typography.dart';
import 'package:mq_navigation/features/map/domain/entities/building.dart';
import 'package:mq_navigation/features/map/presentation/controllers/map_controller.dart';
import 'package:mq_navigation/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:mq_navigation/features/notifications/presentation/widgets/notification_badge.dart';
import 'package:mq_navigation/shared/extensions/context_extensions.dart';
import 'package:mq_navigation/shared/widgets/mq_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final mapState = ref.watch(mapControllerProvider);
    final isDark = context.isDarkMode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero header with greeting + notification bell ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: MqSpacing.space2),
                child: IconButton(
                  onPressed: () => context.pushNamed(RouteNames.notifications),
                  icon: NotificationBadge(
                    count: unreadCount,
                    child: Icon(
                      unreadCount > 0
                          ? Icons.notifications
                          : Icons.notifications_outlined,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            MqColors.charcoal900,
                            MqColors.deepRed.withValues(alpha: 0.3),
                          ]
                        : [
                            MqColors.alabasterLight,
                            MqColors.red.withValues(alpha: 0.08),
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      MqSpacing.space6,
                      MqSpacing.space12,
                      MqSpacing.space6,
                      MqSpacing.space4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _greetingForTimeOfDay(),
                          style: MqTypography.serif(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? MqColors.sand400
                                : MqColors.contentTertiary,
                          ),
                        ),
                        const SizedBox(height: MqSpacing.space1),
                        Text(
                          l10n.welcome,
                          style: context.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: MqSpacing.space1),
                        Text(
                          'Macquarie University',
                          style: MqTypography.serif(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: MqColors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
          SliverPadding(
            padding: const EdgeInsets.all(MqSpacing.space4),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Search bar ──
                _SearchBar(
                  hint: l10n.searchBuildingsPlaceholder,
                  onTap: () {
                    context.goNamed(RouteNames.map);
                  },
                ),
                const SizedBox(height: MqSpacing.space6),

                // ── Quick stats ──
                mapState.when(
                  data: (state) => _CampusStatsRow(
                    buildingCount: state.buildings.length,
                    isDark: isDark,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: MqSpacing.space6),

                // ── Category grid ──
                Text(
                  'Explore Campus',
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: MqSpacing.space3),
                _CategoryGrid(
                  onCategoryTap: (category) {
                    context.goNamed(RouteNames.map);
                  },
                ),
                const SizedBox(height: MqSpacing.space6),

                // ── Popular destinations ──
                Text(
                  'Popular Destinations',
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: MqSpacing.space3),
                mapState.when(
                  data: (state) {
                    final popular = state.buildings
                        .where((b) => b.isHighTraffic)
                        .toList();
                    if (popular.isEmpty) return const SizedBox.shrink();
                    return _PopularDestinations(
                      buildings: popular,
                      onBuildingTap: (building) {
                        context.goNamed(
                          RouteNames.buildingDetail,
                          pathParameters: {'buildingId': building.id},
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(MqSpacing.space8),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: MqSpacing.space6),

                // ── Quick navigation card ──
                _QuickNavCard(
                  isDark: isDark,
                  onTap: () => context.goNamed(RouteNames.map),
                ),
                const SizedBox(height: MqSpacing.space8),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _greetingForTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ── Search bar ──────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MqSpacing.space4,
          vertical: MqSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: isDark ? MqColors.charcoal800 : Colors.white,
          borderRadius: BorderRadius.circular(MqSpacing.radiusXl),
          border: Border.all(
            color: isDark ? MqColors.charcoal700 : MqColors.sand300,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: MqColors.charcoal900.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: isDark ? MqColors.sand400 : MqColors.contentTertiary,
            ),
            const SizedBox(width: MqSpacing.space3),
            Expanded(
              child: Text(
                hint,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: isDark ? MqColors.charcoal600 : MqColors.sand500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MqSpacing.space2,
                vertical: MqSpacing.space1,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? MqColors.charcoal700
                    : MqColors.alabasterDark,
                borderRadius: BorderRadius.circular(MqSpacing.radiusMd),
              ),
              child: Icon(
                Icons.tune,
                size: 18,
                color: isDark ? MqColors.sand400 : MqColors.contentTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Campus stats row ────────────────────────────────────────────────

class _CampusStatsRow extends StatelessWidget {
  const _CampusStatsRow({required this.buildingCount, required this.isDark});

  final int buildingCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.apartment,
            value: '$buildingCount',
            label: 'Buildings',
            color: MqColors.red,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: MqSpacing.space3),
        Expanded(
          child: _StatChip(
            icon: Icons.category,
            value: '${BuildingCategory.values.length - 1}',
            label: 'Categories',
            color: MqColors.info,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: MqSpacing.space3),
        Expanded(
          child: _StatChip(
            icon: Icons.star,
            value: '6',
            label: 'Popular',
            color: MqColors.warning,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MqSpacing.space3,
        vertical: MqSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.12)
            : color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(MqSpacing.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: MqSpacing.space1),
          Text(
            value,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: isDark ? MqColors.sand400 : MqColors.contentTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category grid ───────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.onCategoryTap});

  final ValueChanged<BuildingCategory> onCategoryTap;

  static const _categories = [
    (BuildingCategory.academic, Icons.school, 'Academic', MqColors.red),
    (BuildingCategory.food, Icons.restaurant, 'Food & Cafe', MqColors.warning),
    (BuildingCategory.health, Icons.local_hospital, 'Health', MqColors.success),
    (BuildingCategory.services, Icons.support_agent, 'Services', MqColors.info),
    (BuildingCategory.sports, Icons.fitness_center, 'Sports', MqColors.magenta),
    (BuildingCategory.research, Icons.science, 'Research', MqColors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: MqSpacing.space3,
        crossAxisSpacing: MqSpacing.space3,
        childAspectRatio: 1.05,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final (category, icon, label, color) = _categories[index];

        return Material(
          color: isDark
              ? color.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(MqSpacing.radiusLg),
          child: InkWell(
            onTap: () => onCategoryTap(category),
            borderRadius: BorderRadius.circular(MqSpacing.radiusLg),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MqSpacing.radiusLg),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(MqSpacing.space2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: MqSpacing.space2),
                  Text(
                    label,
                    style: context.textTheme.labelMedium?.copyWith(
                      color:
                          isDark ? MqColors.contentPrimaryDark : color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Popular destinations horizontal scroll ──────────────────────────

class _PopularDestinations extends StatelessWidget {
  const _PopularDestinations({
    required this.buildings,
    required this.onBuildingTap,
  });

  final List<Building> buildings;
  final ValueChanged<Building> onBuildingTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: buildings.length,
        separatorBuilder: (_, _) => const SizedBox(width: MqSpacing.space3),
        itemBuilder: (context, index) {
          final building = buildings[index];
          final color = _colorForCategory(building.category);

          return GestureDetector(
            onTap: () => onBuildingTap(building),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(MqSpacing.space4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.05),
                        ]
                      : [
                          color.withValues(alpha: 0.08),
                          color.withValues(alpha: 0.02),
                        ],
                ),
                borderRadius: BorderRadius.circular(MqSpacing.radiusLg),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(MqSpacing.space2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.25 : 0.12),
                      borderRadius:
                          BorderRadius.circular(MqSpacing.radiusMd),
                    ),
                    child: Icon(
                      _iconForCategory(building.category),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    building.id,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: MqSpacing.space1),
                  Text(
                    building.name,
                    style: context.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Quick navigation card ───────────────────────────────────────────

class _QuickNavCard extends StatelessWidget {
  const _QuickNavCard({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MqCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isDark
                ? [
                    MqColors.deepRed.withValues(alpha: 0.35),
                    MqColors.charcoal800,
                  ]
                : [
                    MqColors.red.withValues(alpha: 0.08),
                    MqColors.alabasterLight,
                  ],
          ),
          borderRadius: BorderRadius.circular(MqSpacing.radiusMd),
        ),
        padding: const EdgeInsets.all(MqSpacing.space5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(MqSpacing.space3),
              decoration: BoxDecoration(
                color: MqColors.red.withValues(alpha: isDark ? 0.25 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map,
                color: MqColors.red,
                size: 28,
              ),
            ),
            const SizedBox(width: MqSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Open Campus Map',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: MqSpacing.space1),
                  Text(
                    'Find buildings, get directions & explore',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? MqColors.sand400
                          : MqColors.contentTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? MqColors.sand400 : MqColors.contentTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────

Color _colorForCategory(BuildingCategory category) {
  return switch (category) {
    BuildingCategory.academic => MqColors.red,
    BuildingCategory.food => MqColors.warning,
    BuildingCategory.health => MqColors.success,
    BuildingCategory.services => MqColors.info,
    BuildingCategory.sports => MqColors.magenta,
    BuildingCategory.research => MqColors.purple,
    BuildingCategory.venue => MqColors.mapSelectedBuilding,
    BuildingCategory.residential => MqColors.slate500,
    BuildingCategory.other => MqColors.sand500,
  };
}

IconData _iconForCategory(BuildingCategory category) {
  return switch (category) {
    BuildingCategory.academic => Icons.school,
    BuildingCategory.food => Icons.restaurant,
    BuildingCategory.health => Icons.local_hospital,
    BuildingCategory.services => Icons.support_agent,
    BuildingCategory.sports => Icons.fitness_center,
    BuildingCategory.research => Icons.science,
    BuildingCategory.venue => Icons.theater_comedy,
    BuildingCategory.residential => Icons.home,
    BuildingCategory.other => Icons.apartment,
  };
}
