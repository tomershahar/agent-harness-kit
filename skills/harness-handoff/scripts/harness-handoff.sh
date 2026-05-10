#!/usr/bin/env bash
# harness-handoff.sh — Clean session exit with auto-generated handoff artifacts.
# Run from your project root: bash /path/to/harness-handoff.sh
set -euo pipefail

PROJECT_ROOT="$(pwd)"
DATE=$(date +%Y-%m-%d)
BLOCKED=false

echo "=== harness-handoff — $DATE ==="
echo ""

# ── Detect commands ───────────────────────────────────────────────────────────

BUILD_COMMAND="echo 'no build step'"
TEST_COMMAND="echo 'no tests configured'"

if [ -f "$PROJECT_ROOT/package.json" ]; then
  if grep -q '"check"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
    BUILD_COMMAND="npm run check"
  else
    BUILD_COMMAND="npm run build"
  fi
  TEST_COMMAND="npm test"
elif [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/requirements.txt" ]; then
  BUILD_COMMAND="echo 'no build step'"
  TEST_COMMAND="pytest"
elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
  BUILD_COMMAND="cargo build"
  TEST_COMMAND="cargo test"
fi

# ── Step 1: Clean-state checklist ────────────────────────────────────────────

echo "=== Step 1: Clean-state checklist ==="
echo ""

echo "[1/5] Build..."
if $BUILD_COMMAND > /tmp/harness-handoff-build.log 2>&1; then
  echo "  ✓ Build passes"
else
  echo "  ✗ Build FAILED"
  head -5 /tmp/harness-handoff-build.log | sed 's/^/    /'
  BLOCKED=true
fi

echo "[2/5] Tests..."
if $TEST_COMMAND > /tmp/harness-handoff-test.log 2>&1; then
  echo "  ✓ Tests pass"
else
  echo "  ✗ Tests FAILED"
  head -5 /tmp/harness-handoff-test.log | sed 's/^/    /'
  BLOCKED=true
fi

echo "[3/5] Debug artifacts in src/..."
if [ -d "$PROJECT_ROOT/src" ]; then
  DEBUG_FOUND=$(grep -rn "console\.log\|debugger" "$PROJECT_ROOT/src" 2>/dev/null | grep -v "\.test\.\|\.spec\." | wc -l | tr -d ' ' || echo "0")
  if [ "$DEBUG_FOUND" -eq 0 ]; then
    echo "  ✓ No debug artifacts"
  else
    echo "  ⚠ $DEBUG_FOUND debug statements found (review before committing):"
    grep -rn "console\.log\|debugger" "$PROJECT_ROOT/src" 2>/dev/null | grep -v "\.test\.\|\.spec\." | head -3 | sed 's/^/    /' || true
  fi
else
  echo "  ✓ No src/ directory to check"
fi

echo "[4/5] feature_list.json..."
if [ -f "$PROJECT_ROOT/feature_list.json" ]; then
  echo "  ✓ feature_list.json exists"
else
  echo "  ⚠ feature_list.json not found — run harness-init first"
fi

echo "[5/5] PROGRESS.md..."
if [ -f "$PROJECT_ROOT/PROGRESS.md" ]; then
  echo "  ✓ PROGRESS.md exists"
else
  echo "  ⚠ PROGRESS.md not found — will be created"
fi

echo ""

if $BLOCKED; then
  echo "HANDOFF BLOCKED: Fix build and test failures before proceeding."
  echo "Re-run this script after fixing the issues above."
  exit 1
fi

# ── Step 2: Gather session data ───────────────────────────────────────────────

echo "=== Step 2: Gathering session data ==="

CHANGED_FILES=$(git -C "$PROJECT_ROOT" diff --name-only HEAD 2>/dev/null || echo "(no uncommitted changes)")
RECENT_COMMITS=$(git -C "$PROJECT_ROOT" log --oneline -5 2>/dev/null || echo "(no commits yet)")

DECISIONS=$(git -C "$PROJECT_ROOT" log --oneline -20 2>/dev/null \
  | grep -iE "decided:|chose:|reason:|because|decision:" \
  | sed 's/^[a-f0-9]* //' \
  | head -5 \
  || true)

BLOCKERS=$(git -C "$PROJECT_ROOT" grep -i "BLOCKED" -- "*.md" "*.sh" "*.js" "*.ts" "*.py" 2>/dev/null \
  | head -5 \
  || true)

echo ""

# ── Step 3: Write session-handoff.md ─────────────────────────────────────────

echo "=== Step 3: Writing session-handoff.md ==="

{
  echo "# Session Handoff — $DATE"
  echo ""
  echo "## What Was Accomplished"
  echo ""
  echo "(Fill in: what features were completed this session, with evidence)"
  echo ""
  echo "## What Remains"
  echo ""
  echo "(Fill in: features still at not_started or active status)"
  echo ""
  echo "## Decisions Made"
  echo ""
  if [ -n "$DECISIONS" ]; then
    echo "$DECISIONS" | while IFS= read -r line; do echo "- $line"; done
  else
    echo "(No decision-pattern commits found — fill in manually: decided X because Y)"
  fi
  echo ""
  echo "## Unresolved Blockers"
  echo ""
  if [ -n "$BLOCKERS" ]; then
    echo "$BLOCKERS" | while IFS= read -r line; do echo "- $line"; done
  else
    echo "None"
  fi
  echo ""
  echo "## Files Modified"
  echo ""
  echo "$CHANGED_FILES"
  echo ""
  echo "## Recent Commits"
  echo ""
  echo "$RECENT_COMMITS"
  echo ""
  echo "## Next Steps"
  echo ""
  echo "1. (Fill in: first action for next session)"
  echo "2. (Fill in: second action)"
} > "$PROJECT_ROOT/session-handoff.md"

echo "  ✓ session-handoff.md written"

# ── Step 4: Update PROGRESS.md ───────────────────────────────────────────────

echo "=== Step 4: Updating PROGRESS.md ==="

if [ ! -f "$PROJECT_ROOT/PROGRESS.md" ]; then
  echo "# PROGRESS.md" > "$PROJECT_ROOT/PROGRESS.md"
  echo "" >> "$PROJECT_ROOT/PROGRESS.md"
fi

cat >> "$PROJECT_ROOT/PROGRESS.md" << EOF

### Session $DATE
**Goal**: (describe what this session aimed to do)
**Done**: (summarize what got done)
**Next**: (what comes next session)
EOF

echo "  ✓ PROGRESS.md updated"

PROGRESS_DIFF=$(git -C "$PROJECT_ROOT" diff HEAD -- PROGRESS.md 2>/dev/null | grep '^+[^+]' | head -8 | sed 's/^+/  + /' || true)
if [ -n "$PROGRESS_DIFF" ]; then
  echo ""
  echo "  Changes to PROGRESS.md this session:"
  echo "$PROGRESS_DIFF"
fi

# ── Step 5: Commit ───────────────────────────────────────────────────────────

echo "=== Step 5: Committing ==="

COMMIT_FILES="session-handoff.md PROGRESS.md"
if [ -f "$PROJECT_ROOT/feature_list.json" ]; then
  COMMIT_FILES="$COMMIT_FILES feature_list.json"
fi

git -C "$PROJECT_ROOT" add $COMMIT_FILES
git -C "$PROJECT_ROOT" commit -m "chore: session handoff $DATE" || echo "  (nothing new to commit)"

echo "  ✓ Committed"

# ── Step 6: Confirm ───────────────────────────────────────────────────────────

echo ""
echo "=== Handoff complete ==="
echo ""
echo "Next session starts with:"
echo "  1. Read PROGRESS.md"
echo "  2. Read session-handoff.md"
echo "  3. Run: bash init.sh"
echo "  4. Continue from the Next Steps in session-handoff.md"
echo ""
echo "NOTE: Open session-handoff.md and fill in the (Fill in:) sections with actual detail."
echo ""
echo "Based on: Learn Harness Engineering — https://github.com/walkinglabs/learn-harness-engineering"
