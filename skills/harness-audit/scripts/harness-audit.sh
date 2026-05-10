#!/usr/bin/env bash
# harness-audit.sh — Score harness health across 5 subsystems.
# Run from your project root: bash /path/to/harness-audit.sh
set -euo pipefail

PROJECT_ROOT="$(pwd)"
DATE=$(date +%Y-%m-%d)

echo "=== harness-audit — $DATE ==="
echo "Project: $PROJECT_ROOT"
echo ""

SCORE_INSTRUCTIONS=0
SCORE_TOOLS=0
SCORE_ENVIRONMENT=0
SCORE_STATE=0
SCORE_FEEDBACK=0

FINDINGS=()
DRIFT=()
FIXES=()
FIX_NUM=1

# ── Subsystem 1: Instructions ─────────────────────────────────────────────────

AGENTS_FILE=""
if [ -f "$PROJECT_ROOT/AGENTS.md" ]; then
  AGENTS_FILE="$PROJECT_ROOT/AGENTS.md"
elif [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  AGENTS_FILE="$PROJECT_ROOT/CLAUDE.md"
fi

if [ -n "$AGENTS_FILE" ]; then
  LINE_COUNT=$(wc -l < "$AGENTS_FILE")
  if [ "$LINE_COUNT" -le 200 ]; then
    SCORE_INSTRUCTIONS=5
    FINDINGS+=("Instructions|5/5|$(basename $AGENTS_FILE) is $LINE_COUNT lines — healthy")
  elif [ "$LINE_COUNT" -le 300 ]; then
    SCORE_INSTRUCTIONS=4
    FINDINGS+=("Instructions|4/5|$(basename $AGENTS_FILE) is $LINE_COUNT lines — minor bloat")
    FIXES+=("$FIX_NUM. [Instructions] Trim $(basename $AGENTS_FILE) from $LINE_COUNT to under 200 lines — move topic-specific rules to docs/ (Lecture 04)")
    FIX_NUM=$((FIX_NUM + 1))
  else
    SCORE_INSTRUCTIONS=2
    FINDINGS+=("Instructions|2/5|$(basename $AGENTS_FILE) is $LINE_COUNT lines — severe bloat")
    FIXES+=("$FIX_NUM. [Instructions] CRITICAL: $(basename $AGENTS_FILE) is $LINE_COUNT lines. Split into router + topic docs (Lecture 04)")
    FIX_NUM=$((FIX_NUM + 1))
  fi
else
  SCORE_INSTRUCTIONS=1
  FINDINGS+=("Instructions|1/5|No AGENTS.md or CLAUDE.md found")
  FIXES+=("$FIX_NUM. [Instructions] CRITICAL: Create AGENTS.md — run harness-init first")
  FIX_NUM=$((FIX_NUM + 1))
fi

# ── Subsystem 2: Tools ────────────────────────────────────────────────────────

if [ -n "$AGENTS_FILE" ] && grep -qE "npm test|pytest|cargo test|yarn test|npm run check" "$AGENTS_FILE" 2>/dev/null; then
  SCORE_TOOLS=3
  FINDINGS+=("Tools|3/5|Verification commands found in $(basename $AGENTS_FILE) — not run-tested")
  FIXES+=("$FIX_NUM. [Tools] Run each verification command in $(basename $AGENTS_FILE) and confirm they exit 0")
  FIX_NUM=$((FIX_NUM + 1))
else
  SCORE_TOOLS=1
  FINDINGS+=("Tools|1/5|No verification commands found")
  FIXES+=("$FIX_NUM. [Tools] CRITICAL: Add verification commands to AGENTS.md (Lecture 09)")
  FIX_NUM=$((FIX_NUM + 1))
fi

# ── Subsystem 3: Environment ──────────────────────────────────────────────────

if [ -f "$PROJECT_ROOT/init.sh" ]; then
  echo "[checking] Running init.sh..."
  if bash "$PROJECT_ROOT/init.sh" > /tmp/harness-audit-init.log 2>&1; then
    SCORE_ENVIRONMENT=5
    FINDINGS+=("Environment|5/5|init.sh passes")
  else
    SCORE_ENVIRONMENT=3
    FINDINGS+=("Environment|3/5|init.sh exists but has errors")
    DRIFT+=("init.sh failed — check /tmp/harness-audit-init.log")
    FIXES+=("$FIX_NUM. [Environment] Fix init.sh errors (see /tmp/harness-audit-init.log)")
    FIX_NUM=$((FIX_NUM + 1))
  fi
else
  SCORE_ENVIRONMENT=1
  FINDINGS+=("Environment|1/5|No init.sh found")
  FIXES+=("$FIX_NUM. [Environment] CRITICAL: Create init.sh (Lecture 06)")
  FIX_NUM=$((FIX_NUM + 1))
fi

# ── Subsystem 4: State ────────────────────────────────────────────────────────

STATE_SCORE=0

if [ -f "$PROJECT_ROOT/PROGRESS.md" ]; then
  LAST_MODIFIED=$(git -C "$PROJECT_ROOT" log --follow --format="%at" -- PROGRESS.md 2>/dev/null | head -1 | tr -d '[:space:]' || echo "0")
  if [ -z "$LAST_MODIFIED" ] || [ "$LAST_MODIFIED" = "0" ]; then
    LAST_MODIFIED=$(date +%s)
  fi
  NOW=$(date +%s)
  DAYS_OLD=$(( ( NOW - LAST_MODIFIED ) / 86400 ))
  if [ "$DAYS_OLD" -le 3 ]; then
    STATE_SCORE=$((STATE_SCORE + 3))
  else
    STATE_SCORE=$((STATE_SCORE + 1))
    DRIFT+=("PROGRESS.md last updated $DAYS_OLD days ago")
    FIXES+=("$FIX_NUM. [State] Update PROGRESS.md — $DAYS_OLD days stale (Lecture 05)")
    FIX_NUM=$((FIX_NUM + 1))
  fi
fi

if [ -f "$PROJECT_ROOT/feature_list.json" ]; then
  STATE_SCORE=$((STATE_SCORE + 2))
fi

if [ "$STATE_SCORE" -eq 0 ]; then
  SCORE_STATE=1
  FINDINGS+=("State|1/5|No PROGRESS.md or feature_list.json")
  FIXES+=("$FIX_NUM. [State] CRITICAL: Create PROGRESS.md and feature_list.json (Lecture 08)")
  FIX_NUM=$((FIX_NUM + 1))
else
  SCORE_STATE=$STATE_SCORE
  if [ "$STATE_SCORE" -ge 5 ]; then
    FINDINGS+=("State|5/5|Both state files present and current")
  elif [ "$STATE_SCORE" -ge 3 ]; then
    FINDINGS+=("State|$STATE_SCORE/5|State files present")
  else
    FINDINGS+=("State|$STATE_SCORE/5|State files partially present or stale")
  fi
fi

# ── Subsystem 5: Feedback ─────────────────────────────────────────────────────

TEST_FILES=0
if find "$PROJECT_ROOT/src" -name "*.test.*" 2>/dev/null | grep -q .; then
  TEST_FILES=$(find "$PROJECT_ROOT/src" -name "*.test.*" 2>/dev/null | wc -l | tr -d ' ')
fi
if find "$PROJECT_ROOT" -maxdepth 3 -name "test_*.py" 2>/dev/null | grep -q .; then
  TEST_FILES=$((TEST_FILES + $(find "$PROJECT_ROOT" -maxdepth 3 -name "test_*.py" 2>/dev/null | wc -l | tr -d ' ')))
fi
if find "$PROJECT_ROOT" -maxdepth 3 -name "*.spec.*" 2>/dev/null | grep -q .; then
  TEST_FILES=$((TEST_FILES + $(find "$PROJECT_ROOT" -maxdepth 3 -name "*.spec.*" 2>/dev/null | wc -l | tr -d ' ')))
fi

if [ "$TEST_FILES" -ge 5 ]; then
  SCORE_FEEDBACK=3
  FINDINGS+=("Feedback|3/5|$TEST_FILES test files found — no E2E detected")
  FIXES+=("$FIX_NUM. [Feedback] Add E2E tests for 3-layer verification (Lecture 10)")
  FIX_NUM=$((FIX_NUM + 1))
elif [ "$TEST_FILES" -ge 1 ]; then
  SCORE_FEEDBACK=2
  FINDINGS+=("Feedback|2/5|$TEST_FILES test files found — coverage may be low")
  FIXES+=("$FIX_NUM. [Feedback] Expand test coverage — add integration and E2E tests (Lecture 10)")
  FIX_NUM=$((FIX_NUM + 1))
else
  SCORE_FEEDBACK=1
  FINDINGS+=("Feedback|1/5|No test files detected")
  FIXES+=("$FIX_NUM. [Feedback] CRITICAL: No tests — agents will declare victory too early (Lecture 09)")
  FIX_NUM=$((FIX_NUM + 1))
fi

# ── Report ────────────────────────────────────────────────────────────────────

TOTAL=$((SCORE_INSTRUCTIONS + SCORE_TOOLS + SCORE_ENVIRONMENT + SCORE_STATE + SCORE_FEEDBACK))
PERCENT=$(( TOTAL * 100 / 25 ))

echo "## Harness Audit Report — $DATE"
echo ""
echo "### Scores"
printf "| %-14s | %-5s | %s\n" "Subsystem" "Score" "Key finding"
printf "|---|---|---\n"
for finding in "${FINDINGS[@]}"; do
  IFS='|' read -r subsystem score finding_text <<< "$finding"
  printf "| %-14s | %-5s | %s\n" "$subsystem" "$score" "$finding_text"
done
printf "| %-14s | %-5s | %s\n" "**Total**" "$TOTAL/25" "$PERCENT% health"
echo ""

if [ ${#DRIFT[@]} -gt 0 ]; then
  echo "### Drift Detected"
  for d in "${DRIFT[@]}"; do
    echo "- $d"
  done
  echo ""
fi

if [ ${#FIXES[@]} -gt 0 ]; then
  echo "### Priority Fix List"
  for fix in "${FIXES[@]}"; do
    echo "$fix"
  done
  echo ""
fi

if [ "$PERCENT" -ge 90 ]; then
  echo "Status: HEALTHY — maintain with weekly audits"
elif [ "$PERCENT" -ge 70 ]; then
  echo "Status: NEEDS ATTENTION — fix lowest subsystem this week"
elif [ "$PERCENT" -ge 50 ]; then
  echo "Status: AT RISK — schedule a harness repair session"
else
  echo "Status: CRITICAL — agent reliability severely impacted"
fi

echo ""
echo "Based on: Learn Harness Engineering — https://github.com/walkinglabs/learn-harness-engineering"
