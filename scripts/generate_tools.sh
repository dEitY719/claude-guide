#!/usr/bin/env bash
# scripts/generate_tools.sh
# Auto-generates tools/*.sh based on project detection
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="$ROOT_DIR/tools"
mkdir -p "$TOOLS_DIR"

# --- Auto-detects ---
has() { command -v "$1" >/dev/null 2>&1; }

PY_RUN=""
if [ -f "$ROOT_DIR/poetry.lock" ] || has poetry; then
  PY_RUN="poetry run"
elif [ -f "$ROOT_DIR/uv.lock" ] || has uv; then
  PY_RUN="uv run"
else
  PY_RUN="python"
fi

PY_TEST="$PY_RUN pytest -q"
if [ -f "$ROOT_DIR/pytest.ini" ] || grep -q "tool.pytest" "$ROOT_DIR/pyproject.toml" 2>/dev/null || [ -f "$ROOT_DIR/tests/__init__.py" ]; then
  : # keep default
else
  PY_TEST="$PY_RUN python -m unittest"
fi

# Guess framework / app entry
UVICORN_ENTRY="src.backend.main:app"
if grep -R "FastAPI(" "$ROOT_DIR/src" 2>/dev/null | head -n1 >/dev/null; then
  : # keep uvicorn default
elif grep -R "Flask(__name__" "$ROOT_DIR/src" 2>/dev/null | head -n1 >/dev/null; then
  UVICORN_ENTRY="app:app"
fi

RUNS_UVICORN=false
if grep -R "uvicorn\|FastAPI" "$ROOT_DIR" 2>/dev/null | grep -v ".git\|.tox\|__pycache__" | head -n1 >/dev/null; then
  RUNS_UVICORN=true
fi

# Alembic?
USE_ALEMBIC=false
if [ -d "$ROOT_DIR/alembic" ] && [ -f "$ROOT_DIR/alembic.ini" ]; then
  USE_ALEMBIC=true
fi

# Django?
IS_DJANGO=false
if [ -f "$ROOT_DIR/manage.py" ] || grep -R "django" "$ROOT_DIR/pyproject.toml" 2>/dev/null | head -n1 >/dev/null; then
  IS_DJANGO=true
fi

# Data defaults
DEFAULT_DATASET="${DEFAULT_DATASET:-"./data"}"
DEFAULT_S3="${DEFAULT_S3:-"s3://example-bucket/path"}"

# --- Ask interactively for overrides (hit Enter to accept defaults) ---
echo "========== Project Detection =========="
echo "Python runner: $PY_RUN"
echo "Test command: $PY_TEST"
$RUNS_UVICORN && echo "Uvicorn entry: $UVICORN_ENTRY"
$USE_ALEMBIC && echo "Using Alembic: true"
$IS_DJANGO && echo "Is Django: true"
echo "Data path: $DEFAULT_DATASET"
echo "S3 path: $DEFAULT_S3"
echo "========================================"
echo ""

read -r -p "Accept defaults? (y/N) " -t 5 ans || ans="y"
case "${ans:-y}" in
  y|Y)
    echo "✅ Using detected defaults"
    ;;
  *)
    read -r -p "Python runner [$PY_RUN]: " ans || true
    PY_RUN="${ans:-$PY_RUN}"
    read -r -p "Test command [$PY_TEST]: " ans || true
    PY_TEST="${ans:-$PY_TEST}"
    if $RUNS_UVICORN; then
      read -r -p "Uvicorn entry (module:app) [$UVICORN_ENTRY]: " ans || true
      UVICORN_ENTRY="${ans:-$UVICORN_ENTRY}"
    fi
    read -r -p "Data path [$DEFAULT_DATASET]: " ans || true
    DEFAULT_DATASET="${ans:-$DEFAULT_DATASET}"
    read -r -p "S3 path [$DEFAULT_S3]: " ans || true
    DEFAULT_S3="${ans:-$DEFAULT_S3}"
    ;;
esac

# --- Write tools/dev.sh ---
cat > "$TOOLS_DIR/dev.sh" <<'DEVEOF'
#!/usr/bin/env bash
set -euo pipefail

# Auto-filled by generator (editable)
PY_RUN="uv run"
PY_TEST="uv run pytest -q"
UVICORN_ENTRY="src.backend.main:app"
USE_ALEMBIC=false
IS_DJANGO=false
MANAGE_PY="manage.py"
DEFAULT_DATASET="./data"

cmd="${1:-help}"

case "$cmd" in
  up)
    echo "🔧 Starting dev server..."
    if $IS_DJANGO; then
      export DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE:-"config.settings.dev"}
      $PY_RUN python "$MANAGE_PY" migrate
      $PY_RUN python "$MANAGE_PY" runserver 0.0.0.0:8000
    else
      if $USE_ALEMBIC; then
        $PY_RUN alembic upgrade head
      fi
      if [ -n "$UVICORN_ENTRY" ]; then
        APP_ENV=${APP_ENV:-dev} DATASET=${DATASET:-"$DEFAULT_DATASET"} \
        $PY_RUN uvicorn "$UVICORN_ENTRY" --reload --host 0.0.0.0 --port 8000
      else
        echo "❌ No dev server configured. Edit tools/dev.sh to add your start command."
        exit 1
      fi
    fi
    ;;

  test)
    echo "🧪 Running tests..."
    $PY_TEST
    ;;

  lint)
    echo "🔎 Running linters..."
    if command -v ruff >/dev/null 2>&1; then
      echo "  → ruff check..."
      $PY_RUN ruff check . || true
    fi
    if command -v mypy >/dev/null 2>&1; then
      echo "  → mypy..."
      $PY_RUN mypy src || true
    fi
    ;;

  fmt|format)
    echo "🖤 Formatting code..."
    if command -v ruff >/dev/null 2>&1; then
      $PY_RUN ruff format .
    elif command -v black >/dev/null 2>&1; then
      $PY_RUN black .
    else
      echo "❌ No formatter (ruff/black). Skipping."
      exit 1
    fi
    ;;

  style|lint-fix)
    echo "✨ Running full style pipeline..."
    if command -v tox >/dev/null 2>&1; then
      tox -e style
    else
      echo "ruff format..."
      $PY_RUN ruff format .
      echo "isort..."
      $PY_RUN isort .
      echo "ruff check --fix..."
      $PY_RUN ruff check . --fix
    fi
    ;;

  shell)
    echo "🐚 Entering project shell..."
    if command -v uv >/dev/null 2>&1; then
      exec uv run bash
    else
      echo "❌ uv not found. Activate virtualenv manually."
      exit 1
    fi
    ;;

  *)
    cat <<'HELP'
Usage: ./tools/dev.sh <command>

Commands:
  up           Start dev server (uvicorn on :8000)
  test         Run tests (pytest)
  lint         Run linters (ruff, mypy)
  format       Format code (ruff/black)
  style        Full style pipeline (format → lint)
  shell        Enter project shell

Tips:
  - Override dataset: DATASET=/path ./tools/dev.sh up
  - Set APP_ENV=dev|staging|prod as needed
  - Edit this file to customize for your stack

See CLAUDE.md for more.
HELP
    ;;
esac
DEVEOF

# --- Write tools/data.sh ---
cat > "$TOOLS_DIR/data.sh" <<'DATAEOF'
#!/usr/bin/env bash
set -euo pipefail

PY_RUN="uv run"
DEFAULT_DATASET="./data"
DEFAULT_S3="s3://example-bucket/path"

cmd="${1:-help}"

case "$cmd" in
  pull-local)
    src="${2:-$DEFAULT_S3}"
    dest="${3:-$DEFAULT_DATASET}"
    echo "⬇️  Syncing $src → $dest (parquet only)..."
    if command -v aws >/dev/null 2>&1; then
      aws s3 sync "$src" "$dest" --exclude "*" --include "*.parquet" --only-show-errors
      echo "✅ Sync complete"
    else
      echo "❌ aws CLI not found. Install awscli or edit tools/data.sh"
      exit 1
    fi
    ;;

  validate)
    path="${2:-$DEFAULT_DATASET}"
    if [ -f "scripts/validate_dataset.py" ]; then
      $PY_RUN python scripts/validate_dataset.py "$path"
    else
      echo "❌ scripts/validate_dataset.py not found"
      echo "Create this script or customize tools/data.sh"
      exit 1
    fi
    ;;

  *)
    cat <<'HELP'
Usage: ./tools/data.sh <command> [args]

Commands:
  pull-local [s3://...] [./data]  Sync parquet data from S3
  validate [./data]               Validate dataset

Tips:
  - Edit DEFAULT_S3 and DEFAULT_DATASET in this file
  - Create scripts/validate_dataset.py for your validation logic

See CLAUDE.md for more.
HELP
    ;;
esac
DATAEOF

# --- Write tools/release.sh ---
cat > "$TOOLS_DIR/release.sh" <<'RELEASEEOF'
#!/usr/bin/env bash
set -euo pipefail

# Simple semver release: tag, optional build
# Usage: ./tools/release.sh patch|minor|major

bump="${1:-}"
[ -z "$bump" ] && { echo "Usage: $0 {patch|minor|major}"; exit 1; }

# Check clean tree
if ! git diff --quiet 2>/dev/null; then
  echo "❌ Uncommitted changes. Commit or stash first."
  exit 1
fi

# Get current semver tag (fallback to 0.0.0)
current="$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")"
IFS='.' read -r MAJ MIN PAT <<<"$current"
MAJ=${MAJ:-0}
MIN=${MIN:-0}
PAT=${PAT:-0}

case "$bump" in
  patch) PAT=$((PAT+1));;
  minor) MIN=$((MIN+1)); PAT=0;;
  major) MAJ=$((MAJ+1)); MIN=0; PAT=0;;
  *) echo "❌ Unknown bump: $bump"; exit 1;;
esac

new="$MAJ.$MIN.$PAT"

echo "📝 Tagging $current → $new"
git tag -a "$new" -m "Release $new"
git push --follow-tags

echo "✅ Release $new complete"
echo "Next: Verify build/deployment pipelines"
RELEASEEOF

chmod +x "$TOOLS_DIR/dev.sh" "$TOOLS_DIR/data.sh" "$TOOLS_DIR/release.sh"

echo ""
echo "✅ Generated tools:"
echo "  - $TOOLS_DIR/dev.sh"
echo "  - $TOOLS_DIR/data.sh"
echo "  - $TOOLS_DIR/release.sh"
echo ""
echo "Quick start:"
echo "  ./tools/dev.sh help"
echo "  ./tools/dev.sh up      # Start dev server"
echo "  ./tools/dev.sh test    # Run tests"
echo ""
echo "Next: Review and customize tools/*.sh, then update CLAUDE.md"
echo ""

# WSL: ensure LF endings
if command -v git >/dev/null 2>&1; then
  git config core.autocrlf input || true
fi
