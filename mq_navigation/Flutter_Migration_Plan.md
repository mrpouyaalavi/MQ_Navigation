# Flutter Migration Plan — MQ Navigation

## Current State

The Flutter mobile app has been migrated from the original Next.js web application and streamlined to focus on **campus navigation**. Auth, calendar, event feed, profile management, and gamification features were removed to match the project scope.

### What's Implemented

| Feature | Status | Description |
|---------|--------|-------------|
| Home | ✅ Done | Welcome hub with campus navigation info |
| Campus Map | ✅ Done | Interactive Google Maps, 153 buildings, search, routing |
| Settings | ✅ Done | Theme, locale, notification preferences (local storage) |
| Notifications | ✅ Done | FCM push + local study prompt scheduling |
| i18n | ✅ Done | 35 locales with RTL support |
| Design System | ✅ Done | MQ brand tokens (colors, typography, spacing) |
| CI/CD | ✅ Done | GitHub Actions (analyze, test, build) |

### What Was Removed

| Feature | Reason |
|---------|--------|
| Auth (login, signup, MFA, biometric) | Not required for navigation-only scope |
| Calendar (agenda, week view, CRUD) | Not required for navigation-only scope |
| Event Feed (public events, pagination) | Not required for navigation-only scope |
| Profile Management | Not required without auth |
| Gamification (XP, streaks) | Not required for navigation-only scope |
| Dashboard (deadlines, schedule) | Replaced with simple welcome card |

## Tech Stack

| Layer | Package | Version |
|-------|---------|---------|
| Framework | Flutter | ^3.11.0 |
| State Management | flutter_riverpod | ^3.2.1 |
| Routing | go_router | ^17.1.0 |
| Backend | supabase_flutter | ^2.12.0 |
| Maps | google_maps_flutter | ^2.14.2 |
| Location | geolocator | ^13.0.0 |
| Permissions | permission_handler | ^12.0.1 |
| Security | flutter_secure_storage | ^10.0.0 |
| Push | firebase_core + firebase_messaging | ^4.2.0 / ^16.1.2 |
| Local Notifications | flutter_local_notifications | ^18.0.0 |
| i18n | intl | ^0.20.2 |
| Connectivity | connectivity_plus | ^6.1.4 |
| Logging | logger | ^2.5.0 |

## Project Structure

```
lib/
  main.dart
  app/
    bootstrap/bootstrap.dart        # Supabase + Firebase init
    mq_navigation_app.dart          # MaterialApp.router
    router/
      app_router.dart               # GoRouter (3-tab shell)
      app_shell.dart                # Bottom nav (Home, Map, Settings)
      route_names.dart              # Named route constants
    theme/                          # MQ design tokens
    l10n/                           # 35 ARB locale files + generated
  core/
    config/env_config.dart          # --dart-define env vars
    error/                          # Sealed exceptions, error boundary
    logging/                        # Structured logger
    network/                        # Connectivity service
    security/                       # Secure storage
    utils/                          # Result type, validators
  shared/
    widgets/                        # MQ design system (button, card, input, etc.)
    models/                         # UserPreferences
    extensions/                     # BuildContext extensions
  features/
    home/presentation/pages/        # Welcome hub
    map/                            # Full map feature (data/domain/presentation)
    notifications/                  # FCM + local notifications
    settings/                       # Theme, locale, notification prefs
```

## Routes

| Route | Name | Description |
|-------|------|-------------|
| `/home` | `home` | Welcome hub (tab 0) |
| `/map` | `map` | Campus map (tab 1) |
| `/map/building/:buildingId` | `building-detail` | Building deep link |
| `/settings` | `settings` | Preferences (tab 2) |
| `/notifications` | `notifications` | Notification inbox |

## Edge Functions (Server-Side)

| Function | Used by Flutter | Purpose |
|----------|-----------------|---------|
| `maps-routes` | Yes | Google Routes API proxy with rate limiting |
| `notify` | Yes | FCM push notification dispatcher |
| `cleanup-cron` | Yes (indirect) | Rate-limit cleanup |

## Environment Variables

### Client (--dart-define)
- `SUPABASE_URL` (required)
- `SUPABASE_ANON_KEY` (required)
- `GOOGLE_MAPS_API_KEY` (optional, needed for map)
- `APP_ENV` (optional, default: development)

### Server (Edge Functions)
- `SUPABASE_SERVICE_ROLE_KEY`
- `GOOGLE_ROUTES_API_KEY`
- `FIREBASE_SERVICE_ACCOUNT_JSON`

## Testing

83 tests covering:
- Core utilities (env config, exceptions, Result type)
- Routing (route names)
- Map (building entity, route parsing, registry asset)
- Notifications (scheduler)
- Shared widgets (MqButton, MqCard, MqInput)
- Theme tokens

## How to Run

```bash
cd MQ_Navigation
flutter pub get
flutter gen-l10n
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=GOOGLE_MAPS_API_KEY=your-maps-key
```

## Authors

- **Raouf Abedini** (47990805) — COMP3130, Macquarie University
- **Pouya Alavi** (48160202) — COMP3130, Macquarie University
