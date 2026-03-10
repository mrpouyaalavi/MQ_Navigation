# Changelog

All notable changes to the Syllabus Sync Flutter app.

## [Unreleased]

### Raouf: 2026-03-10 (AEDT) — Phase 0+1 Completion Pass

**Scope:** Close all Phase 0+1 gaps — inventories, full l10n, building registry, deep links.

**Summary:**
Audit revealed missing Phase 0 documentation and incomplete Phase 1 deliverables. Created all 8 required inventory documents from web app source data. Built JSON→ARB conversion script and converted all 35 locales (1995 keys each) with Handlebars→ICU interpolation fix and Dart reserved word handling. Wired l10n delegates into SyllabusSyncApp. Created Building entity model and cached data source. Configured deep link intent filters for Android and iOS (URL scheme + App Links).

**Files created/changed:**
- `entity_inventory.md` — 22 Supabase tables, 4 views, 20+ RPC functions
- `endpoint_inventory.md` — 58 API routes mapped to SDK/Edge Function
- `env_inventory.md` — Client/server/web-only env var catalogue
- `auth_matrix.md` — Auth state machine, route guards, deep link callbacks
- `notification_matrix.md` — Push/local flows, FCM lifecycle, channels, tap routing
- `route_matrix.md` — All web→Flutter route mappings
- `map_inventory.md` — Map APIs, keys, building registry schema, migration steps
- `key_inventory.md` — 35-locale translation key inventory
- `tools/convert_i18n.dart` — JSON→ARB converter (handles {{var}}→{var}, reserved words)
- `lib/app/l10n/app_*.arb` — 35 ARB locale files (1995 keys each)
- `lib/app/l10n/generated/*` — 36 generated Dart l10n classes
- `lib/app/syllabus_sync_app.dart` — Wired localizationsDelegates + supportedLocales
- `lib/features/map/domain/entities/building.dart` — Building entity model
- `lib/features/map/data/datasources/building_registry_source.dart` — Cache data source
- `android/app/src/main/AndroidManifest.xml` — Deep link intent filters
- `ios/Runner/Info.plist` — URL scheme + permission descriptions

**Verification:**
- `flutter analyze` → No issues found
- `flutter test` → 4/4 tests passed
- `dart tools/convert_i18n.dart` → 35 locales converted successfully

---

### Raouf: 2026-03-10 (AEDT) — Phase 0 + Phase 1 Foundation Sprint

**Scope:** Full project scaffold, core architecture, MQ theme, routing shell, l10n setup, CI/CD pipeline, shared widgets, security services.

**Summary:**
Implemented Phase 0 (Foundation Sprint) and Phase 1 (App Shell) of the Flutter Migration Blueprint v3.0. Created the feature-first project structure, wired Supabase bootstrap with --dart-define env config, built the MQ design system (colors, typography, spacing from web tokens), set up go_router with StatefulShellRoute bottom navigation, implemented auth guard + splash resolver, and created core infrastructure services.

**Files created/changed:**
- `pubspec.yaml` — Core dependencies (supabase_flutter, flutter_riverpod, go_router, etc.)
- `l10n.yaml` — Localisation configuration
- `lib/main.dart` — App entry point
- `lib/app/bootstrap/bootstrap.dart` — Supabase init, ProviderScope, error handling
- `lib/app/syllabus_sync_app.dart` — Root MaterialApp.router widget
- `lib/app/router/app_router.dart` — go_router with auth guards + shell
- `lib/app/router/app_shell.dart` — Bottom NavigationBar shell (5 tabs)
- `lib/app/router/route_names.dart` — Named route constants
- `lib/app/theme/mq_colors.dart` — MQ brand palette (red, alabaster, charcoal, etc.)
- `lib/app/theme/mq_typography.dart` — Work Sans / Source Serif Pro type scale
- `lib/app/theme/mq_spacing.dart` — Spacing & radius tokens
- `lib/app/theme/mq_theme.dart` — Light + dark ThemeData
- `lib/app/l10n/app_en.arb` — English ARB template (70+ keys)
- `lib/core/config/env_config.dart` — --dart-define environment config
- `lib/core/error/app_exception.dart` — Sealed exception hierarchy
- `lib/core/error/error_boundary.dart` — Widget error boundary + global handlers
- `lib/core/logging/app_logger.dart` — Structured logger wrapper
- `lib/core/network/connectivity_service.dart` — Connectivity monitor + Riverpod providers
- `lib/core/security/secure_storage_service.dart` — Encrypted key-value storage
- `lib/core/security/biometric_service.dart` — Biometric auth gate
- `lib/core/utils/result.dart` — Result<T> type (Success/Failure)
- `lib/shared/widgets/mq_button.dart` — MQ button (filled/outlined/text variants)
- `lib/shared/widgets/mq_card.dart` — MQ card with tap support
- `lib/shared/widgets/mq_input.dart` — MQ text input
- `lib/shared/widgets/mq_bottom_sheet.dart` — MQ modal bottom sheet
- `lib/shared/widgets/mq_app_bar.dart` — MQ app bar
- `lib/shared/providers/auth_provider.dart` — Auth state notifier (Supabase)
- `lib/shared/extensions/context_extensions.dart` — BuildContext convenience extensions
- `lib/features/auth/presentation/pages/splash_page.dart` — Splash screen
- `lib/features/auth/presentation/pages/login_page.dart` — Login placeholder
- `lib/features/home/presentation/pages/home_page.dart` — Dashboard placeholder
- `lib/features/calendar/presentation/pages/calendar_page.dart` — Calendar placeholder
- `lib/features/map/presentation/pages/map_page.dart` — Map placeholder
- `lib/features/feed/presentation/pages/feed_page.dart` — Feed placeholder
- `lib/features/settings/presentation/pages/settings_page.dart` — Settings shell
- `.github/workflows/ci.yml` — GitHub Actions CI (analyze, test, build Android/iOS)
- `test/widget_test.dart` — Theme token unit tests

**Verification:**
- `flutter analyze` → No issues found
- `flutter test` → 4/4 tests passed
- `flutter pub get` → 158 dependencies resolved

**Follow-ups:**
- Phase 2: Auth screens (login/signup wired to Supabase), profile, MFA, OAuth
- Convert all 35 locale JSON files to ARB format
- Configure Fastlane for store distribution
- Deploy AASA + assetlinks.json for deep links
- Add Supabase mobile redirect URLs
