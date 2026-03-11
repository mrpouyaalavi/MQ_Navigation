# Map Dependency Inventory

All map-related APIs, services, keys, and data sources used by the campus map subsystem.

## API Keys

| Key | Location | Usage | Flutter Approach |
|-----|----------|-------|-----------------|
| `GOOGLE_MAPS_API_KEY` (client) | --dart-define | Maps SDK rendering | Restricted to app bundle ID |
| `GOOGLE_ROUTES_API_KEY` (server) | Edge Functions env | Google Routes API | Never in client code |

## External Services

| Service | Web Usage | Flutter Usage |
|---------|-----------|---------------|
| Google Maps JavaScript API | Leaflet + GM JS API | google_maps_flutter (native SDK) |
| Google Routes API | Via Next.js API proxy | Via `maps-routes` Edge Function proxy |

## Building Registry

- **Source**: `features/map/lib/buildings.ts` in web app (153 buildings in the current Flutter asset snapshot)
- **Fields per building**: id, name, position, description, tags, aliases, translationKey, descriptionKey, gridRef, address, category, location (lat/lng), entranceLocation, accessibilityEntranceLocation, googlePlaceId, levels, wheelchair
- **Categories**: academic, services, health, food, sports, venue, research, residential, other
- **Flutter storage**: Bundled JSON asset at `assets/data/buildings.json`

## Map Configuration

| Config | Value | Notes |
|--------|-------|-------|
| Campus bounds (north) | -33.769571 | |
| Campus bounds (south) | -33.778124 | |
| Campus bounds (east) | 151.122172 | |
| Campus bounds (west) | 151.103934 | |
| Campus center lat | -33.7738 | Default camera target |
| Campus center lng | 151.1130 | Default camera target |
| Default zoom | 16.5 | |

## Flutter Map Packages

| Package | Version | Role |
|---------|---------|------|
| google_maps_flutter | ^2.14.2 | Primary map engine |
| geolocator | ^13.0.0 | GPS location tracking |
| permission_handler | ^12.0.1 | Location permission flow |

## Map Features (Implemented)

| Feature | Package |
|---------|---------|
| Building registry data source + bundled JSON asset | flutter assets |
| Current location tracking | geolocator + permission_handler |
| Google Map widget + camera bounds | google_maps_flutter |
| Building markers + info windows | google_maps_flutter |
| Building search bottom sheet | custom widget |
| Route request via Edge Function | maps-routes EF |
| Route polyline rendering | google_maps_flutter |
| Travel mode switching (walk/drive/bike/transit) | maps-routes EF |

## Edge Functions for Maps

| Function | Purpose |
|----------|---------|
| `maps-routes` | Authenticated Google Routes API proxy with rate limiting |
