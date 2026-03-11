# Environment Variable Inventory

All environment variables used by MQ Navigation, categorised by client/server exposure.

## Client-Side (--dart-define in Flutter)

| Variable | Required | Default | Notes |
|----------|----------|---------|-------|
| `SUPABASE_URL` | Yes | — | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | — | Public anon key (RLS enforced) |
| `GOOGLE_MAPS_API_KEY` | No | — | Client-side Maps SDK key (restricted to app bundle ID; required only for the embedded map) |
| `APP_ENV` | No | `development` | development / staging / production |

## Server-Only (Edge Functions env / Supabase dashboard)

| Variable | Service | Notes |
|----------|---------|-------|
| `SUPABASE_SERVICE_ROLE_KEY` | Edge Functions | Bypasses RLS — never in client code |
| `GOOGLE_ROUTES_API_KEY` | `maps-routes` EF | Google Routes API billing key |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | `notify` EF | Preferred Firebase service account JSON for FCM HTTP v1 |
| `FCM_SERVER_KEY` | `notify` EF | Legacy FCM push delivery fallback |
| `CRON_SECRET` | `cleanup-cron` EF | Protects cron endpoints |

## Firebase (Flutter-specific, not in web app)

| Variable | Location | Notes |
|----------|----------|-------|
| `google-services.json` | `android/app/` | Firebase Android config |
| `GoogleService-Info.plist` | `ios/Runner/` | Firebase iOS config |
| APNs auth key / certificate | Apple Developer + Firebase | Required for iOS push delivery |

## Web-Only (Not Needed in Flutter)

| Variable | Reason |
|----------|--------|
| `NEXT_PUBLIC_APP_URL` | Vercel deployment URL |
| `NEXT_PUBLIC_GOOGLE_MAP_ID` | Maps JS API vector maps |
| `RESEND_API_KEY` | Email delivery (web auth flow) |
| `VERIFICATION_EMAIL_FROM` | Verification emails (web auth) |
| `VERIFICATION_EMAIL_NAME` | Verification emails (web auth) |
| `WEBAUTHN_RP_ID` | WebAuthn (web-only) |
| `WEBAUTHN_ORIGIN` | WebAuthn (web-only) |
| `CSRF_VALIDATION_ENABLED` | Browser CSRF (not applicable on mobile) |
| `NEXT_PUBLIC_SENTRY_DSN` | Web Sentry — Flutter will use its own |
| `CORS_ALLOWED_ORIGINS` | Browser CORS only |
| `NODE_ENV` / `PORT` / `NEXT_TURBOPACK` | Next.js dev server |
