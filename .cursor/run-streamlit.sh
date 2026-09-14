#!/usr/bin/env bash
# Launch the Streamlit GUI for the emergency-preparedness system.
set -euo pipefail

_this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=app_env.sh
source "$_this_dir/app_env.sh"

APP_DIR="$(find_app_dir)"
cd "$APP_DIR"

export STREAMLIT_BROWSER_GATHER_USAGE_STATS="${STREAMLIT_BROWSER_GATHER_USAGE_STATS:-false}"

exec .venv/bin/python -m streamlit run streamlit_gui.py \
  --server.address 0.0.0.0 --server.port 8501 --server.headless true
