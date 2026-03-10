import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syllabus_sync/app/router/app_shell.dart';
import 'package:syllabus_sync/app/router/route_names.dart';
import 'package:syllabus_sync/features/auth/presentation/pages/login_page.dart';
import 'package:syllabus_sync/features/auth/presentation/pages/splash_page.dart';
import 'package:syllabus_sync/features/calendar/presentation/pages/calendar_page.dart';
import 'package:syllabus_sync/features/feed/presentation/pages/feed_page.dart';
import 'package:syllabus_sync/features/home/presentation/pages/home_page.dart';
import 'package:syllabus_sync/features/map/presentation/pages/map_page.dart';
import 'package:syllabus_sync/features/settings/presentation/pages/settings_page.dart';
import 'package:syllabus_sync/shared/providers/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Application router with auth guards and shell-based navigation.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final session = authState.value;
      final isLoggedIn = session != null;
      final currentPath = state.matchedLocation;

      // While loading, stay on splash.
      if (isLoading) {
        return currentPath == '/splash' ? null : '/splash';
      }

      // Auth-gated routes.
      final isAuthRoute =
          currentPath == '/login' ||
          currentPath == '/signup' ||
          currentPath == '/reset-password' ||
          currentPath == '/verify-email';

      if (!isLoggedIn) {
        // Not logged in → allow auth routes, redirect everything else to login.
        return isAuthRoute || currentPath == '/splash' ? null : '/login';
      }

      // Logged in but on auth route or splash → go home.
      if (isAuthRoute || currentPath == '/splash') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),

      // ── Main Shell (bottom nav) ──────────────────────────
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
