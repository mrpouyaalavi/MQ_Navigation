#!/usr/bin/env bash
# Launch the app with --dart-define vars loaded from .env
# Usage: ./scripts/run.sh [device-id] [extra flutter args...]
#
# Examples:
#   ./scripts/run.sh                            # pick device interactively
#   ./scripts/run.sh 00008150-000E7C6A1EF0401C  # specific device
#   ./scripts/run.sh chrome
#   ./scripts/run.sh macos

set -euo pipefail
cd "$(dirname "$0")/.."

# ── .env check ───────────────────────────────────────────────────────────────
ENV_FILE=".env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: $ENV_FILE not found."
  echo "  cp .env.example .env   # then fill in your keys"
  exit 1
fi

# ── Read Google Maps API key from .env (if present) ─────────────────────────
GOOGLE_MAPS_API_KEY_VALUE=""
if grep -q '^GOOGLE_MAPS_API_KEY=' "$ENV_FILE"; then
  GOOGLE_MAPS_API_KEY_VALUE="$(grep '^GOOGLE_MAPS_API_KEY=' "$ENV_FILE" | head -1 | cut -d= -f2-)"
fi

# ── Platform config paths ───────────────────────────────────────────────────
ANDROID_PROPS="android/gradle.properties"
IOS_DEBUG_XCCONFIG="ios/Flutter/Debug.xcconfig"
IOS_RELEASE_XCCONFIG="ios/Flutter/Release.xcconfig"
WEB_MAPS_CONFIG="web/google_maps_config.js"

# ── Helper: set GOOGLE_MAPS_API_KEY= line in a file ────────────────────────
# Usage: set_maps_key <file> <value>
set_maps_key() {
  local file="$1" value="$2"
  if [[ ! -f "$file" ]]; then
    return
  fi
  if grep -q '^GOOGLE_MAPS_API_KEY=' "$file"; then
    # Replace existing line (works on both macOS sed and GNU sed)
    sed -i.bak "s|^GOOGLE_MAPS_API_KEY=.*|GOOGLE_MAPS_API_KEY=${value}|" "$file"
    rm -f "${file}.bak"
  fi
}

# ── Cleanup: restore empty keys & remove temp files on exit ─────────────────
cleanup() {
  set_maps_key "$ANDROID_PROPS"       ""
  set_maps_key "$IOS_DEBUG_XCCONFIG"  ""
  set_maps_key "$IOS_RELEASE_XCCONFIG" ""
  rm -f "$WEB_MAPS_CONFIG"
}
trap cleanup EXIT

# ── Inject key into platform configs ────────────────────────────────────────
if [[ -n "$GOOGLE_MAPS_API_KEY_VALUE" ]]; then
  # Android – gradle.properties → read by build.gradle.kts via findProperty()
  set_maps_key "$ANDROID_PROPS" "$GOOGLE_MAPS_API_KEY_VALUE"

  # iOS – xcconfig files → resolved as $(GOOGLE_MAPS_API_KEY) in Info.plist
  set_maps_key "$IOS_DEBUG_XCCONFIG"   "$GOOGLE_MAPS_API_KEY_VALUE"
  set_maps_key "$IOS_RELEASE_XCCONFIG" "$GOOGLE_MAPS_API_KEY_VALUE"

  # Web – runtime JS config loaded by flutter_bootstrap.js
  cat > "$WEB_MAPS_CONFIG" <<EOF
window.GOOGLE_MAPS_API_KEY = "${GOOGLE_MAPS_API_KEY_VALUE}";
EOF
fi

# ── Parse device argument ───────────────────────────────────────────────────
DEVICE_ARG=""
if [[ -n "${1:-}" ]]; then
  DEVICE_ARG="-d $1"
  shift
fi

echo "Launching with dart-defines from .env..."
export MACOSX_DEPLOYMENT_TARGET=11.0
flutter run $DEVICE_ARG --dart-define-from-file="$ENV_FILE" "$@"
