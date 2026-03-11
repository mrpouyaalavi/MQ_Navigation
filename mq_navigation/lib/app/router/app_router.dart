import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mq_navigation/app/router/app_shell.dart';
import 'package:mq_navigation/app/router/route_names.dart';
import 'package:mq_navigation/core/config/env_config.dart';
import 'package:mq_navigation/features/calendar/presentation/pages/calendar_page.dart';
import 'package:mq_navigation/features/calendar/presentation/pages/academic_item_detail_page.dart';
import 'package:mq_navigation/features/feed/presentation/pages/feed_page.dart';
import 'package:mq_navigation/features/home/presentation/pages/home_page.dart';
import 'package:mq_navigation/features/map/presentation/pages/map_page.dart';
import 'package:mq_navigation/features/notifications/presentation/pages/notifications_page.dart';
import 'package:mq_navigation/features/settings/presentation/pages/settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: EnvConfig.isDevelopment,
    routes: [
      GoRoute(
        path: '/notifications',
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/detail/deadline/:deadlineId',
        name: RouteNames.deadlineDetail,
        builder: (context, state) => AcademicItemDetailPage(
          itemId: state.pathParameters['deadlineId']!,
          detailType: AcademicItemDetailType.deadline,
        ),
      ),
      GoRoute(
        path: '/detail/exam/:examId',
        name: RouteNames.examDetail,
        builder: (context, state) => AcademicItemDetailPage(
          itemId: state.pathParameters['examId']!,
          detailType: AcademicItemDetailType.exam,
        ),
      ),
      GoRoute(
        path: '/detail/event/:eventId',
        name: RouteNames.eventDetail,
        builder: (context, state) => AcademicItemDetailPage(
          itemId: state.pathParameters['eventId']!,
          detailType: AcademicItemDetailType.event,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: RouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                name: RouteNames.calendar,
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                name: RouteNames.map,
                builder: (context, state) => const MapPage(),
                routes: [
                  GoRoute(
                    path: 'building/:buildingId',
                    name: RouteNames.buildingDetail,
                    builder: (context, state) => MapPage(
                      initialBuildingId: state.pathParameters['buildingId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                name: RouteNames.feed,
                builder: (context, state) => const FeedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: RouteNames.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
