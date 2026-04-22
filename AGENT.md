# MQ Navigation Flutter — Agent Rules

## Project Overview
Flutter mobile client for MQ Navigation (Macquarie University campus navigation platform).
Two frontends, one backend architecture: Flutter + Next.js sharing a Supabase backend.

## Architecture
- **Pattern**: Feature-first with data/domain/presentation layers per feature
- **State management**: Riverpod (flutter_riverpod ^3.2.1)
- **Routing**: go_router with StatefulShellRoute for 3-tab bottom nav (Home, Map, Settings)
- **Backend**: Supabase (Postgres, RLS, Realtime, Edge Functions)
- **Theme**: MQ design tokens (MqColors, MqTypography, MqSpacing) mapped from web app
- **i18n**: Flutter ARB files with 35 locales, RTL support for ar/fa/he/ur
- **No auth**: App starts directly at `/home` — no login, signup, or profile management

## Non-Negotiable Constraints
1. Supabase is the system of record — no parallel backend
2. Web app stays alive — no feature freeze on the web product
3. Flutter is a presentation layer only — no server logic in app binary
4. No server secrets in Flutter — API keys stay in Edge Functions
5. Security is non-negotiable — encrypted storage, RLS enforcement
6. Accessibility from day one — 48x48dp tap targets, semantic labels, RTL

## Directory Structure
```
lib/
  app/bootstrap/    → App init, Supabase + Firebase setup
  app/router/       → go_router config, route names
  app/theme/        → MQ design tokens (colors, typography, spacing)
  app/l10n/         → ARB files + generated localisations
  core/config/      → Env vars via --dart-define
  core/error/       → App exceptions, error boundary
  core/logging/     → Structured logger
  core/network/     → Connectivity service
  core/security/    → Secure storage
  core/utils/       → Result type, validators
  shared/widgets/   → MQ button, card, input, bottom sheet, app bar
  shared/models/    → UserPreferences
  shared/extensions/→ BuildContext extensions
  features/home/    → Welcome hub
  features/map/     → Campus map (153 buildings, search, routing)
  features/notifications/ → FCM push + local study prompts
  features/settings/ → Theme, locale, notification preferences (local storage)
```

## Key Environment Variables (--dart-define)
- SUPABASE_URL, SUPABASE_ANON_KEY, GOOGLE_MAPS_API_KEY, APP_ENV
- DEV_SUPABASE_URL, DEV_SUPABASE_ANON_KEY, DEV_GOOGLE_MAPS_API_KEY (debug-only fallbacks)
- All keys loaded via `--dart-define-from-file=.env` — never hardcoded in source
- Use `scripts/run.sh` to launch with native key injection for Maps SDKs

### Raouf: 2026-04-22 (AEST) — Environment setup
**Scope:** `.env` creation.
**Summary:** Created a `.env` file from `.env.example` template with placeholders for Supabase and Google Maps credentials. This enables usage of `scripts/run.sh` and proper environment configuration.
**Files Changed:** `.env` (new, gitignored)
**Verification:** File exists and matches `.env.example` structure.

### Raouf: 2026-04-22 (AEST) — Zero-data features & settings implementation
**Scope:** Architecture & UI improvement.
**Summary:** Implemented the "zero-data" features blueprint. Updated `UserPreferences` and `SettingsRepository` to support default renderer, travel mode, low data mode, and reduced motion. Implemented "Low Data Guard" in building search and "Reduced Motion Guard" in animations. Added a "Nuclear Reset" (wipe data) feature. Built the corresponding UI in `SettingsPage`.
**Files Changed:** `lib/shared/models/user_preferences.dart`, `lib/features/settings/data/repositories/settings_repository.dart`, `lib/features/settings/presentation/controllers/settings_controller.dart`, `lib/features/map/presentation/controllers/map_controller.dart`, `lib/app/theme/mq_animations.dart`, `lib/features/map/presentation/widgets/building_search_sheet.dart`, `lib/features/settings/presentation/pages/settings_page.dart`
**Verification:** Manual logic verification for guards and repository methods.

## Coding Conventions
- Use Riverpod providers (not setState or Bloc)
- Use go_router named routes (RouteNames constants)
- Use MqSpacing/MqColors/MqTypography for all styling — no magic numbers
- Minimum tap target: 48dp
- All interactive elements must have semantic labels
- Use EdgeInsetsDirectional for RTL support

## Inventory Documents
Located in project root:
- `entity_inventory.md` — Shared Supabase schema (Flutter uses subset only)
- `endpoint_inventory.md` — API routes → Edge Functions / SDK mapping
- `env_inventory.md` — Environment variables (client vs server)
- `notification_matrix.md` — Push/local notification flows
- `route_matrix.md` — Flutter route map
- `key_inventory.md` — Translation key inventory (35 locales)
- `map_inventory.md` — Map dependencies, APIs, building registry

## i18n Convention
- Web uses `{{variable}}` (Handlebars). ARB uses `{variable}` (ICU).
- Dart reserved words are prefixed with `k` (e.g. `class` → `kClass`, `continue` → `kContinue`)
- Run `dart tools/convert_i18n.dart` to regenerate ARB files from web JSON

## Change History

See `CHANGELOG.md` for full development history.

### Summary

The project was built through phases 0–5, originally including auth, calendar, event feed, profile management, and gamification features. These were subsequently removed to focus the Flutter app on campus navigation: 3-tab nav (Home/Map/Settings), local-only settings, FCM push + study prompt notifications, and dual-renderer campus map with building search and routing via Edge Function proxy.

### Raouf: 2026-04-22 (AEST) — Project-wide verification & build fixes
**Scope:** Quality assurance & build stability.
**Summary:** Executed `scripts/check.sh` and resolved all issues. Added missing localization keys to `app_en.arb`. Fixed a Kotlin compilation error in `android/app/build.gradle.kts` by adding missing imports. Updated `MapController` tests to correctly mock the new `SettingsController` dependency, eliminating binding and storage errors during testing. Verified that all checks (format, analyze, test, build) now pass cleanly.
**Files Changed:** `lib/app/l10n/app_en.arb`, `android/app/build.gradle.kts`, `test/features/map/map_controller_test.dart`
**Verification:** `./scripts/check.sh` passed with 6/6 steps successful.

### Raouf: 2026-04-22 (AEST) — macOS deployment target synchronization
**Scope:** macOS build configuration.
**Summary:** Updated MACOSX_DEPLOYMENT_TARGET from 11.0 to 13.0 in `macos/Runner.xcodeproj/project.pbxproj` (both build settings and shell script phases) to align with Podfile and resolve plugin compilation errors (specifically for `app_links`).
**Files Changed:** `macos/Runner.xcodeproj/project.pbxproj`
**Verification:** Synchronized with Podfile and run.sh; ready for build retry.

### Raouf: 2026-04-22 (AEST) — Environment setup
**Scope:** `.env` creation.
**Summary:** Created a `.env` file from `.env.example` template with placeholders for Supabase and Google Maps credentials. This enables usage of `scripts/run.sh` and proper environment configuration.
**Files Changed:** `.env` (new, gitignored)
**Verification:** File exists and matches `.env.example` structure.

### Raouf: 2026-04-22 (AEST) — Run script robustness & parsing fix
**Scope:** `scripts/run.sh` logic improvement.
**Summary:** Refined argument parsing to distinguish between device targets and Flutter flags. Added quote stripping for API keys from `.env` to prevent JS/native syntax errors. Optimized `gradle.properties` modification to be idempotent. Added early `flutter` command check and switched `echo` to `printf` for safe variable handling.
**Files Changed:** `scripts/run.sh`
**Verification:** `bash -n scripts/run.sh` passed.
