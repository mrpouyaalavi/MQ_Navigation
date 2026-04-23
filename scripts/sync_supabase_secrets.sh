#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

ENV_FILE=".env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: $ENV_FILE not found."
  exit 1
fi

if ! command -v supabase >/dev/null 2>&1; then
  echo "Error: supabase CLI not found."
  exit 1
fi

extract_env() {
  local key="$1"
  local value
  value="$(rg "^${key}=" "$ENV_FILE" -N -m 1 | sed "s/^${key}=//" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")" || true
  printf "%s" "$value"
}

set_secret_if_present() {
  local secret_name="$1"
  local env_key="$2"
  local value
  value="$(extract_env "$env_key")"
  if [[ -z "$value" ]]; then
    echo "  - Skipping ${secret_name} (${env_key} missing)"
    return
  fi

  supabase secrets set "${secret_name}=${value}" >/dev/null
  echo "  - Set ${secret_name}"
}

set_google_routes_secret() {
  local value
  value="$(extract_env "GOOGLE_ROUTES_API_KEY")"
  if [[ -n "$value" ]]; then
    supabase secrets set "GOOGLE_ROUTES_API_KEY=${value}" >/dev/null
    echo "  - Set GOOGLE_ROUTES_API_KEY (from GOOGLE_ROUTES_API_KEY)"
    return
  fi

  value="$(extract_env "GOOGLE_MAPS_API_KEY")"
  if [[ -n "$value" ]]; then
    supabase secrets set "GOOGLE_ROUTES_API_KEY=${value}" >/dev/null
    echo "  - Set GOOGLE_ROUTES_API_KEY (from GOOGLE_MAPS_API_KEY fallback)"
    return
  fi

  echo "  - Skipping GOOGLE_ROUTES_API_KEY (both GOOGLE_ROUTES_API_KEY and GOOGLE_MAPS_API_KEY missing)"
}

echo "Syncing Supabase secrets from .env..."
set_google_routes_secret
set_secret_if_present "ORS_API_KEY" "ORS_API_KEY"
set_secret_if_present "TFNSW_API_KEY" "TFNSW_API_KEY"
set_secret_if_present "TFNSW_STOP_ID" "TFNSW_STOP_ID"
set_secret_if_present "ALLOWED_WEB_ORIGINS" "ALLOWED_WEB_ORIGINS"

echo "Secret sync complete."
