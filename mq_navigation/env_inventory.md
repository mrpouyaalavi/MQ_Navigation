# Environment Variable Inventory

All environment variables used by MQ Navigation, categorised by client/server exposure.

## Client-Side (--dart-define in Flutter)

| Variable | Required | Default | Notes |
|----------|----------|---------|-------|
| `SUPABASE_URL` | Release only | Hardcoded dev fallback | Supabase project URL |
| `SUPABASE_ANON_KEY` | Release only | Hardcoded dev fallback | Public anon key (RLS enforced) |
| `GOOGLE_MAPS_API_KEY` | No | Hardcoded dev fallback | Client-side Maps SDK + Directions API key |
| `APP_ENV` | No | `development` | development / staging / production |

> In **debug mode** a bare `flutter run` works without `--dart-define-from-file=.env`
> because `env_config.dart` falls back to hardcoded development defaults.
> In **release mode** you must supply at least `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

## Server-Only (Edge Functions env / Supabase dashboard)

| Variable | Service | Notes |
|----------|---------|-------|
| `SUPABASE_SERVICE_ROLE_KEY` | Edge Functions | Bypasses RLS — never in client code |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | `notify` EF | Firebase service account JSON for FCM HTTP v1 |
| `CRON_SECRET` | `cleanup-cron` EF | Protects cron endpoints |

> **Note:** `GOOGLE_ROUTES_API_KEY` is no longer used by the `maps-routes` edge function.
> Routing is now handled client-side via the Google Directions API using
> the same `GOOGLE_MAPS_API_KEY`.

## Firebase (Flutter-specific, not in web app)

| Variable | Location | Notes |
|----------|----------|-------|
| `google-services.json` | `android/app/` | Firebase Android config |
| `GoogleService-Info.plist` | `ios/Runner/` | Firebase iOS config |
| APNs auth key / certificate | Apple Developer + Firebase | Required for iOS push delivery |

