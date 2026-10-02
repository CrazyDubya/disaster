#!/usr/bin/env bash
# Launch the FastAPI backend for the emergency-preparedness system.
set -euo pipefail

_this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=app_env.sh
source "$_this_dir/app_env.sh"

APP_DIR="$(find_app_dir)"
cd "$APP_DIR"

# Stable dev secret so JWTs survive restarts; dev keys file enables the
# documented admin_key/user_key/gui_key; debug mode exposes /docs.
export EMERGENCY_API_SECRET_KEY="${EMERGENCY_API_SECRET_KEY:-dev-secret-key-not-for-prod}"
export EMERGENCY_API_KEYS_FILE="${EMERGENCY_API_KEYS_FILE:-$APP_DIR/dev_api_keys.json}"
export EMERGENCY_DEBUG_MODE="${EMERGENCY_DEBUG_MODE:-true}"

exec .venv/bin/python -m uvicorn api_server:app \
  --host 0.0.0.0 --port 8000
