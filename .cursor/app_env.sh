#!/usr/bin/env bash
# Shared helpers for the Cloud Agent environment.
#
# The runnable application lives in the `emergency-preparedness` repository
# (declared as a repositoryDependency), under `disaster/`. This repo
# (`disaster`) is the markdown reference library and hosts the environment
# config. These helpers locate the app directory regardless of the current
# working directory so install/run scripts work from any cwd.
set -euo pipefail

_this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_primary_repo="$(cd "$_this_dir/.." && pwd)"

find_app_dir() {
  local candidates=(
    "$_primary_repo/../emergency-preparedness/disaster"
    "$HOME/emergency-preparedness/disaster"
    "/agent/repos/emergency-preparedness/disaster"
  )
  local c
  for c in "${candidates[@]}"; do
    if [ -f "$c/requirements.txt" ]; then
      (cd "$c" && pwd)
      return 0
    fi
  done
  echo "ERROR: could not locate emergency-preparedness/disaster app dir" >&2
  return 1
}

# Absolute path to the app's venv python.
venv_python() {
  echo "$(find_app_dir)/.venv/bin/python"
}
