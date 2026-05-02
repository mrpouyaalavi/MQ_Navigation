import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mq_navigation/app/router/route_names.dart';
import 'package:mq_navigation/app/theme/mq_colors.dart';
import 'package:mq_navigation/app/theme/mq_spacing.dart';
import 'package:mq_navigation/core/logging/app_logger.dart';
import 'package:mq_navigation/features/map/data/datasources/building_registry_source.dart';
import 'package:mq_navigation/features/map/domain/entities/building.dart';
import 'package:mq_navigation/features/map/domain/entities/map_renderer_type.dart';
import 'package:mq_navigation/features/map/presentation/controllers/map_controller.dart';
import 'package:mq_navigation/features/open_day/domain/entities/open_day_data.dart';
import 'package:mq_navigation/shared/extensions/context_extensions.dart';
import 'package:mq_navigation/shared/widgets/mq_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom sheet shown when the user taps the direction icon on an event.
///
/// Two actions, deliberately distinct:
///   1. **View in Campus Map** — switches the in-app renderer to
///      `MapRendererType.campus`, focuses the venue, then navigates to
///      the building-detail route. Single-marker focused state, user
///      stays inside MQ Navigation.
///   2. **Navigate with Google Maps** — opens the **native** Google
///      Maps app on the device with turn-by-turn directions to the
///      venue. Uses platform-specific URL schemes; falls back to the
///      universal https URL only when the native app isn't installed.
class EventActionsSheet extends ConsumerWidget {
  const EventActionsSheet({super.key, required this.event});

  final OpenDayEvent event;

  static Future<void> show(BuildContext context, OpenDayEvent event) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EventActionsSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = context.isDarkMode;
    final buildingsAsync = ref.watch(buildingRegistryProvider);
    final building = _resolveBuilding(buildingsAsync.value, event.buildingCode);

    return MqBottomSheet(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: MqSpacing.space2,
          vertical: MqSpacing.space2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: MqSpacing.space2,
                vertical: MqSpacing.space1,
              ),
              child: Text(
                event.venueName,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: dark
                      ? MqColors.contentPrimaryDark
                      : MqColors.contentPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                MqSpacing.space2,
                0,
                MqSpacing.space2,
                MqSpacing.space2,
              ),
              child: Text(
                event.title,
                style: context.textTheme.bodySmall?.copyWith(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.72)
                      : MqColors.contentSecondary,
                ),
              ),
            ),
            // Primary: View in Campus Map. Hidden gracefully if the
            // building isn't in the registry — the sheet never offers
            // a broken action.
            if (event.buildingCode != null && building != null)
              Semantics(
                button: true,
                label: 'View ${event.venueName} in Campus Map',
                child: ListTile(
                  leading: const Icon(
                    Icons.location_on_rounded,
                    color: MqColors.vividRed,
                  ),
                  title: Text(
                    'View in Campus Map',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text('Open inside MQ Navigation'),
                  onTap: () => _openInCampusMap(context, ref),
                ),
              ),
            Semantics(
              button: true,
              label: 'Navigate to ${event.venueName} with Google Maps',
              child: ListTile(
                leading: Icon(
                  Icons.navigation_rounded,
                  color: dark
                      ? Colors.white.withValues(alpha: 0.85)
                      : MqColors.contentPrimary,
                ),
                title: Text(
                  'Navigate with Google Maps',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Open external turn-by-turn directions'),
                onTap: () => _navigateWithGoogleMaps(context, building),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Switches the in-app map to the campus renderer, focuses the venue,
  /// and routes to the building-detail page so the user lands in
  /// single-marker focused state automatically.
  void _openInCampusMap(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    // Force the campus renderer regardless of the user's default —
    // "View in Campus Map" is an explicit user choice for that mode.
    ref
        .read(mapControllerProvider.notifier)
        .setRenderer(MapRendererType.campus);
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!context.mounted) return;
      context.goNamed(
        RouteNames.buildingDetail,
        pathParameters: {'buildingId': event.buildingCode!},
      );
    });
  }

  /// Launches the **native** Google Maps app with turn-by-turn directions.
  ///
  /// Per-platform strategy:
  ///   * **Android** — `google.navigation:` intent starts navigation in
  ///     the Google Maps app immediately. Walking mode is requested
  ///     because campus is pedestrian-first.
  ///   * **iOS** — `comgooglemaps://?daddr=...&directionsmode=walking`
  ///     opens the Google Maps app if installed.
  ///   * **Fallback** — when neither native scheme can be launched (Maps
  ///     not installed, web/desktop), falls back to the universal
  ///     `https://www.google.com/maps/dir/?api=1&destination=...&travelmode=walking`
  ///     URL which the OS routes to whichever maps handler is present.
  Future<void> _navigateWithGoogleMaps(
    BuildContext context,
    Building? building,
  ) async {
    Navigator.pop(context);

    final lat = building?.latitude;
    final lng = building?.longitude;
    final hasCoords = lat != null && lng != null;

    // Build candidate URIs in launch-priority order.
    final candidates = <Uri>[];
    if (!kIsWeb) {
      if (Platform.isAndroid && hasCoords) {
        // Native Android intent — opens directly in turn-by-turn mode.
        candidates.add(Uri.parse('google.navigation:q=$lat,$lng&mode=w'));
      } else if (Platform.isIOS && hasCoords) {
        // iOS scheme for the Google Maps app.
        candidates.add(
          Uri.parse(
            'comgooglemaps://?daddr=$lat,$lng&directionsmode=walking',
          ),
        );
      }
    }
    // Universal fallback — works in browser and on devices without the
    // Google Maps app, and when coords are missing falls back to a
    // text query for the venue.
    if (hasCoords) {
      candidates.add(
        Uri.parse(
          'https://www.google.com/maps/dir/?api=1'
          '&destination=$lat,$lng'
          '&travelmode=walking',
        ),
      );
    } else {
      final q = Uri.encodeQueryComponent(
        '${event.venueName} Macquarie University',
      );
      candidates.add(
        Uri.parse(
          'https://www.google.com/maps/dir/?api=1'
          '&destination=$q'
          '&travelmode=walking',
        ),
      );
    }

    // Try each candidate in order; the first one that opens wins.
    for (final uri in candidates) {
      try {
        final ok = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (ok) return;
      } catch (error, stackTrace) {
        AppLogger.warning(
          'Google Maps launch attempt failed: $uri',
          error,
          stackTrace,
        );
      }
    }
  }

  Building? _resolveBuilding(List<Building>? buildings, String? code) {
    if (buildings == null || code == null) return null;
    final upper = code.toUpperCase();
    for (final b in buildings) {
      if (b.code.toUpperCase() == upper || b.id.toUpperCase() == upper) {
        return b;
      }
    }
    return null;
  }
}
