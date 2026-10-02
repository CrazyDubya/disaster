#!/usr/bin/env bash
# Idempotent Cloud Agent install step.
# Prepares the Python virtualenv, dependencies, and a stable set of
# development API keys for the emergency-preparedness application.
set -euo pipefail

_this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=app_env.sh
source "$_this_dir/app_env.sh"

APP_DIR="$(find_app_dir)"
cd "$APP_DIR"
echo "==> App directory: $APP_DIR"

# Ensure venv/pip tooling exists (missing on the stock image). Idempotent.
if ! python3 -c 'import venv, ensurepip' >/dev/null 2>&1; then
  echo "==> Installing python3-venv / python3-pip"
  sudo apt-get update -qq
  sudo apt-get install -y -qq python3-venv python3-pip
fi

# Create the virtualenv if absent.
if [ ! -x .venv/bin/python ]; then
  echo "==> Creating virtualenv (.venv)"
  python3 -m venv .venv
fi

echo "==> Installing Python dependencies"
.venv/bin/python -m pip install --upgrade pip >/dev/null
.venv/bin/pip install -r requirements.txt

# Provision stable development API keys so the Streamlit GUI (which uses the
# embedded key "gui_key") can authenticate against the API. These map to the
# documented dev keys: admin_key / user_key / gui_key. Dev-only, never for prod.
if [ ! -f dev_api_keys.json ]; then
  echo "==> Generating dev_api_keys.json (admin_key / user_key / gui_key)"
  .venv/bin/python - <<'PY'
import hashlib, json
from datetime import datetime
def h(k): return hashlib.sha256(k.encode()).hexdigest()
now = datetime.now().isoformat()
data = {"api_keys": {
  "admin": {"key_hash": h("admin_key"), "user_id": "admin", "role": "admin",
            "profile": "default", "rate_limit": 1000, "created_at": now,
            "expires_at": None, "enabled": True, "permissions": ["*"]},
  "user":  {"key_hash": h("user_key"), "user_id": "user", "role": "user",
            "profile": "default", "rate_limit": 100, "created_at": now,
            "expires_at": None, "enabled": True,
            "permissions": ["read", "drill", "supply"]},
  "gui":   {"key_hash": h("gui_key"), "user_id": "gui", "role": "user",
            "profile": "default", "rate_limit": 500, "created_at": now,
            "expires_at": None, "enabled": True,
            "permissions": ["read", "drill", "supply", "alert"]},
}, "updated_at": now}
with open("dev_api_keys.json", "w") as f:
    json.dump(data, f, indent=2)
print("wrote dev_api_keys.json")
PY
fi

echo "==> Verifying imports and running the fast system test"
.venv/bin/python system_test.py >/dev/null
echo "==> Install complete."
