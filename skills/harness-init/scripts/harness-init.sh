#!/usr/bin/env bash
# harness-init.sh — Generate a complete agent harness from an existing repo.
# Run from your project root: bash /path/to/harness-init.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
PROJECT_ROOT="$(pwd)"
DATE=$(date +%Y-%m-%d)

echo "=== harness-init ==="
echo "Generating harness for: $PROJECT_ROOT"
echo ""

# ── Detect tech stack ────────────────────────────────────────────────────────

INSTALL_COMMAND="npm install"
DEV_COMMAND="npm run dev"
TEST_COMMAND="npm test"
TYPECHECK_COMMAND="npx tsc --noEmit"
BUILD_COMMAND="npm run build"
CHECK_COMMAND="npm test"

if [ -f "$PROJECT_ROOT/package.json" ]; then
  echo "[detected] Node.js project (package.json)"
  if [ -f "$PROJECT_ROOT/yarn.lock" ]; then
    INSTALL_COMMAND="yarn install"
    TEST_COMMAND="yarn test"
    CHECK_COMMAND="yarn test"
  fi
  if grep -q '"check"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
    CHECK_COMMAND="npm run check"
  fi
elif [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/requirements.txt" ]; then
  echo "[detected] Python project"
  INSTALL_COMMAND="pip install -r requirements.txt"
  DEV_COMMAND="python -m uvicorn main:app --reload"
  TEST_COMMAND="pytest"
  TYPECHECK_COMMAND="mypy src/ --strict"
  BUILD_COMMAND="echo 'no build step'"
  CHECK_COMMAND="pytest && mypy src/ --strict"
elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
  echo "[detected] Rust project"
  INSTALL_COMMAND="cargo fetch"
  DEV_COMMAND="cargo run"
  TEST_COMMAND="cargo test"
  TYPECHECK_COMMAND="cargo check"
  BUILD_COMMAND="cargo build"
  CHECK_COMMAND="cargo test && cargo clippy"
fi

# ── Detect project name ──────────────────────────────────────────────────────

PROJECT_NAME="$(basename "$PROJECT_ROOT")"
if [ -f "$PROJECT_ROOT/package.json" ]; then
  PKG_NAME=$(python3 -c "import json,sys; d=json.load(open('$PROJECT_ROOT/package.json')); print(d.get('name',''))" 2>/dev/null || echo "")
  if [ -n "$PKG_NAME" ]; then
    PROJECT_NAME="$PKG_NAME"
  fi
fi

echo "[detected] Project name: $PROJECT_NAME"
echo ""

# ── Repo readiness check ──────────────────────────────────────────────────────
echo "[checking] Repo readiness..."

READINESS_WARNINGS=""

HAS_TESTS=false
if [ -f "$PROJECT_ROOT/package.json" ] && grep -qE '"test"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
  HAS_TESTS=true
elif find "$PROJECT_ROOT" -maxdepth 3 \( -name "*.test.*" -o -name "test_*.py" -o -name "*.spec.*" -o -name "test-*.sh" \) 2>/dev/null | grep -q .; then
  HAS_TESTS=true
elif [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
  HAS_TESTS=true
fi

if ! $HAS_TESTS; then
  echo "  [WARN] No test runner detected"
  READINESS_WARNINGS="${READINESS_WARNINGS}# HARNESS-GAP: No test runner found. Add a test script to package.json or create test files before relying on this harness.
"
fi

HAS_MANIFEST=false
for f in package.json pyproject.toml requirements.txt Cargo.toml go.mod; do
  [ -f "$PROJECT_ROOT/$f" ] && HAS_MANIFEST=true && break
done
if ! $HAS_MANIFEST; then
  echo "  [WARN] No package manifest found"
  READINESS_WARNINGS="${READINESS_WARNINGS}# HARNESS-GAP: No package manifest (package.json, pyproject.toml, Cargo.toml, etc). Confirm tech stack and add one.
"
fi

HAS_ENTRY=false
for entry in src/index.js src/main.js src/main.ts src/main.py main.py src/main.rs index.js; do
  [ -f "$PROJECT_ROOT/$entry" ] && HAS_ENTRY=true && break
done
if ! $HAS_ENTRY && [ -d "$PROJECT_ROOT/src" ] && find "$PROJECT_ROOT/src" -maxdepth 1 -type f 2>/dev/null | grep -q .; then
  HAS_ENTRY=true
fi
if ! $HAS_ENTRY; then
  echo "  [WARN] No clear entry point found"
  READINESS_WARNINGS="${READINESS_WARNINGS}# HARNESS-GAP: No entry point found (src/index.js, main.py, etc). Document the project entry point in ARCHITECTURE.md.
"
fi

if [ -n "$READINESS_WARNINGS" ]; then
  echo ""
  echo "  Gaps detected — HARNESS-GAP comments will be embedded in generated files."
  echo "  Search for 'HARNESS-GAP' after init to see what needs filling in."
fi
echo ""

# ── Ask three questions ──────────────────────────────────────────────────────

echo "Question 1/3: Tech stack detected above. Press Enter to confirm, or type correction:"
read -r TECH_CORRECTION
TECH_STACK="${TECH_CORRECTION:-auto-detected}"

echo ""
echo "Question 2/3: Team size? [1] Just me  [2] Small (2-5)  [3] Larger"
read -r TEAM_SIZE_INPUT
case "$TEAM_SIZE_INPUT" in
  2) TEAM_SIZE="small team (2-5)" ;;
  3) TEAM_SIZE="larger team" ;;
  *) TEAM_SIZE="solo" ;;
esac

echo ""
echo "Question 3/3: Which agent tools? (e.g. claude-code, cursor, codex, gemini)"
read -r TOOLS_INPUT
AGENT_TOOLS="${TOOLS_INPUT:-claude-code}"

echo ""
echo "=== Generating harness files... ==="
echo ""

# ── Generate init.sh ─────────────────────────────────────────────────────────

if [ ! -f "$PROJECT_ROOT/init.sh" ]; then
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{INSTALL_COMMAND}}|$INSTALL_COMMAND|g" \
    -e "s|{{TYPECHECK_COMMAND}}|$TYPECHECK_COMMAND|g" \
    -e "s|{{BUILD_COMMAND}}|$BUILD_COMMAND|g" \
    -e "s|{{DEV_COMMAND}}|$DEV_COMMAND|g" \
    "$TEMPLATES_DIR/init.sh.tpl" > "$PROJECT_ROOT/init.sh"
  chmod +x "$PROJECT_ROOT/init.sh"
  echo "[created] init.sh"
else
  echo "[skipped] init.sh already exists"
fi

# ── Generate PROGRESS.md ─────────────────────────────────────────────────────

if [ ! -f "$PROJECT_ROOT/PROGRESS.md" ]; then
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{TEST_COMMAND}}|$TEST_COMMAND|g" \
    -e "s|{{BUILD_COMMAND}}|$BUILD_COMMAND|g" \
    -e "s|{{DATE}}|$DATE|g" \
    "$TEMPLATES_DIR/PROGRESS.md.tpl" > "$PROJECT_ROOT/PROGRESS.md"
  echo "[created] PROGRESS.md"
else
  echo "[skipped] PROGRESS.md already exists"
fi

# ── Generate feature_list.json ───────────────────────────────────────────────

if [ ! -f "$PROJECT_ROOT/feature_list.json" ]; then
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{PROJECT_DESCRIPTION}}|Add project description here|g" \
    -e "s|{{FEATURE_1_NAME}}|First feature|g" \
    -e "s|{{FEATURE_1_BEHAVIOR}}|Describe what the user sees or gets|g" \
    -e "s|{{FEATURE_1_VERIFICATION_COMMAND}}|$TEST_COMMAND|g" \
    "$TEMPLATES_DIR/feature_list.json.tpl" > "$PROJECT_ROOT/feature_list.json"
  echo "[created] feature_list.json"
else
  echo "[skipped] feature_list.json already exists"
fi

# ── Generate AGENTS.md ───────────────────────────────────────────────────────

if [ ! -f "$PROJECT_ROOT/AGENTS.md" ]; then
  printf '%s' "$READINESS_WARNINGS" > /tmp/harness-rw.txt
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{PROJECT_DESCRIPTION}}|Add one-sentence project description here.|g" \
    -e "s|{{TECH_STACK}}|$TECH_STACK|g" \
    -e "s|{{INSTALL_COMMAND}}|$INSTALL_COMMAND|g" \
    -e "s|{{DEV_COMMAND}}|$DEV_COMMAND|g" \
    -e "s|{{TEST_COMMAND}}|$TEST_COMMAND|g" \
    -e "s|{{TYPECHECK_COMMAND}}|$TYPECHECK_COMMAND|g" \
    -e "s|{{CHECK_COMMAND}}|$CHECK_COMMAND|g" \
    -e "s|{{CONSTRAINT_1}}|All code must pass type checking before commit|g" \
    -e "s|{{CONSTRAINT_2}}|Do not commit broken builds|g" \
    "$TEMPLATES_DIR/AGENTS.md.tpl" > /tmp/harness-agents-pre.md
  python3 -c "
warnings = open('/tmp/harness-rw.txt').read()
content = open('/tmp/harness-agents-pre.md').read()
print(content.replace('{{READINESS_WARNINGS}}', warnings), end='')
" > "$PROJECT_ROOT/AGENTS.md"
  echo "[created] AGENTS.md"
else
  echo "[skipped] AGENTS.md already exists"
fi

# ── Generate ARCHITECTURE.md ─────────────────────────────────────────────────

if [ ! -f "$PROJECT_ROOT/ARCHITECTURE.md" ]; then
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{SYSTEM_DESCRIPTION}}|Describe the system in 2-3 sentences.|g" \
    -e "s|{{LAYER_DIAGRAM}}|Add ASCII layer diagram here|g" \
    -e "s|{{DATA_FLOW_STEPS}}|1. User action -> 2. Handler -> 3. Service -> 4. Response|g" \
    -e "s|{{STORAGE_LAYOUT}}|Describe where data lives|g" \
    "$TEMPLATES_DIR/ARCHITECTURE.md.tpl" > "$PROJECT_ROOT/ARCHITECTURE.md"
  echo "[created] ARCHITECTURE.md"
else
  echo "[skipped] ARCHITECTURE.md already exists"
fi

# ── Commit ───────────────────────────────────────────────────────────────────

echo ""
echo "=== Committing harness files... ==="
FILES_TO_ADD=""
for f in AGENTS.md ARCHITECTURE.md feature_list.json init.sh PROGRESS.md; do
  if [ -f "$PROJECT_ROOT/$f" ]; then
    FILES_TO_ADD="$FILES_TO_ADD $f"
  fi
done
git -C "$PROJECT_ROOT" add $FILES_TO_ADD
git -C "$PROJECT_ROOT" commit -m "harness: initialize project harness (harness-init)" || echo "(nothing new to commit)"

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "=== harness-init complete ==="
echo ""
echo "Files created:"
echo "  AGENTS.md          — project overview, run commands, hard constraints"
echo "  ARCHITECTURE.md    — layer structure (FILL IN the diagram and invariants)"
echo "  feature_list.json  — feature tracker (ADD your features)"
echo "  init.sh            — environment verification script"
echo "  PROGRESS.md        — session log template"
echo ""
echo "Next steps for your team:"
echo "  1. Open AGENTS.md and fill in your hard constraints"
echo "  2. Open ARCHITECTURE.md and draw your layer diagram"
echo "  3. Open feature_list.json and add your top 3-5 features"
echo "  4. Commit and share with your team — everyone works from the same harness"
echo ""
echo "Based on: Learn Harness Engineering — https://github.com/walkinglabs/learn-harness-engineering"
