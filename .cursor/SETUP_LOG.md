# Cloud Agent Environment Setup Log

Working log kept between git commits while building the Cloud Agent dev
environment for the Emergency Preparedness System.

## Layout

- Primary repo `disaster` (this repo): markdown reference library + hosts the
  Cloud Agent environment config under `.cursor/`.
- `emergency-preparedness` (repositoryDependency): the runnable software, under
  `disaster/` (FastAPI backend, Streamlit GUI, CLI, 16+ modules, test suites).

## 2026-09-14

### System
- OS: Ubuntu 24.04 (linux 6.12), x86_64
- Python 3.12.3 (`/usr/bin/python3`)
- Installed `python3-venv` + `python3-pip` via apt (missing on stock image)
- venv at `emergency-preparedness/disaster/.venv` (gitignored)

### Dependency install
- `python3 -m venv .venv`
- `.venv/bin/pip install -r requirements.txt` — succeeded (fastapi, uvicorn,
  streamlit, plotly, pandas, matplotlib, seaborn, python-jose, passlib, ...)

### Validation
- `run_tests.py` — 97/97 unit tests pass
- `system_test.py` — 10/10 modules pass
- `.cursor/install.sh` — runs idempotently (2x)
- `v2_tests/test_integration.py` — 3/4 (pre-existing stale assertion: expects
  `modules_active == 23`, actual is 29; standalone script, not part of the
  canonical `run_tests.py` suite). App code left unchanged.

### End-to-end runs
- FastAPI `api_server.py` on :8000 — WORKING
  - `GET /health` -> healthy; `GET /` -> operational
  - unauthenticated `GET /api/profile` -> 401 (auth enforced); bad key -> 401
  - `POST /auth/login` with dev key -> JWT issued
  - `GET /api/profile`, `/api/drills/scenarios`, `/api/knowledge/categories`,
    `/api/knowledge/search?q=water`, `POST /api/backup/create` -> 200 OK
  - Known pre-existing app bug (not env): `POST /api/risk/calculate` -> 500
    "SQLite objects created in a thread can only be used in that same thread"
    (advanced_risk_engine opens a connection without check_same_thread across
    the uvicorn threadpool). App code left unchanged.
- Streamlit `streamlit_gui.py` on :8501 — WORKING (verified in browser)
  - Dashboard, Risk Assessment, Supply Management, Knowledge Base, Training &
    Drills all render.
  - Knowledge Base search "water" -> 15 results.
  - Training & Drills -> Earthquake/Fire/Tornado scenarios listed; ran an
    Earthquake drill to completion (scored + saved to history).

### Auth configuration (env, not app code)
- GUI embeds `Authorization: Bearer gui_key`; the security module otherwise
  generates random dev keys, so the GUI got 401s.
- Fix: `install.sh` generates `dev_api_keys.json` with the documented keys
  (admin_key / user_key / gui_key, sha256-hashed) and `run-api.sh` points the
  server at it via `EMERGENCY_API_KEYS_FILE`, with a fixed
  `EMERGENCY_API_SECRET_KEY` for stable JWTs. Dev-only.

### Environment config (this repo)
- `.cursor/environment.json` — user ubuntu; repositoryDependency
  emergency-preparedness; install `.cursor/install.sh`; terminals api +
  streamlit; ports 8000 / 8501.
- `.cursor/app_env.sh` — locates the app dir (sibling repo) from any cwd.
- `.cursor/install.sh`, `.cursor/run-api.sh`, `.cursor/run-streamlit.sh`.
