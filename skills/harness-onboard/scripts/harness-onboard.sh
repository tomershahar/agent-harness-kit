#!/usr/bin/env bash
# harness-onboard.sh — 5-minute harness walkthrough for new team members.
# Run from your project root: bash /path/to/harness-onboard.sh
set -euo pipefail

PROJECT_ROOT="$(pwd)"
DATE=$(date +%Y-%m-%d)

echo "=== harness-onboard — $DATE ==="
echo "Project: $PROJECT_ROOT"
echo ""

# ── Check harness exists ──────────────────────────────────────────────────────

AGENTS_FILE=""
[ -f "$PROJECT_ROOT/AGENTS.md" ] && AGENTS_FILE="$PROJECT_ROOT/AGENTS.md"
[ -f "$PROJECT_ROOT/CLAUDE.md" ] && AGENTS_FILE="$PROJECT_ROOT/CLAUDE.md"

if [ -z "$AGENTS_FILE" ]; then
  echo "No harness found in this repo."
  echo ""
  echo "This repo has no AGENTS.md or CLAUDE.md — the harness has not been set up yet."
  echo "To create one, run:"
  echo "  bash /path/to/harness-init.sh"
  echo ""
  echo "Or install agent-harness-kit: https://github.com/walkinglabs/agent-harness-kit"
  exit 0
fi

# ── Section 1: What is this project? ─────────────────────────────────────────

echo "## 1. What is this project?"
echo ""

PROJECT_NAME=$(basename "$PROJECT_ROOT")
HEADER_NAME=$(grep -m1 "^# AGENTS.md" "$AGENTS_FILE" 2>/dev/null | sed 's/^# AGENTS.md[[:space:]]*—[[:space:]]*//' | sed 's/^# AGENTS.md//' | xargs 2>/dev/null || echo "")
[ -n "$HEADER_NAME" ] && PROJECT_NAME="$HEADER_NAME"

echo "Project: $PROJECT_NAME"
echo ""

OVERVIEW=$(awk '/^## Overview/{found=1; next} found && /^##/{exit} found{print}' "$AGENTS_FILE" | head -5 | sed 's/^/  /')
if [ -n "$OVERVIEW" ]; then
  echo "$OVERVIEW"
else
  # Fallback: first non-empty lines of README.md
  if [ -f "$PROJECT_ROOT/README.md" ]; then
    README_SUMMARY=$(grep -v '^#' "$PROJECT_ROOT/README.md" 2>/dev/null | grep -v '^$' | head -3 | sed 's/^/  /' || true)
    if [ -n "$README_SUMMARY" ]; then
      echo "  (from README.md — add ## Overview to $(basename "$AGENTS_FILE") for better context)"
      echo "$README_SUMMARY"
    else
      echo "  (No overview found — add ## Overview to $(basename "$AGENTS_FILE"))"
    fi
  else
    echo "  (No overview found — add ## Overview to $(basename "$AGENTS_FILE"))"
  fi
fi
echo ""

# ── Section 2: How do I start? ───────────────────────────────────────────────

echo "## 2. How do I start?"
echo ""

if [ -f "$PROJECT_ROOT/init.sh" ]; then
  echo "  Run: bash init.sh"
else
  echo "  [MISSING] No init.sh found"
fi
echo ""

RUN_CMDS=$(awk '/^## Run Commands/{found=1; next} found && /^##/{exit} found{print}' "$AGENTS_FILE" | grep -v '^$' | head -8 | sed 's/^/  /' || true)
if [ -n "$RUN_CMDS" ]; then
  echo "  Run commands:"
  echo "$RUN_CMDS"
elif [ -f "$PROJECT_ROOT/package.json" ] && command -v python3 >/dev/null 2>&1; then
  # Fallback: read scripts from package.json
  PKG_SCRIPTS=$(python3 -c "
import json
try:
  scripts = json.load(open('$PROJECT_ROOT/package.json')).get('scripts', {})
  for k, v in list(scripts.items())[:6]:
    print('  ' + k + ': ' + v)
except: pass
" 2>/dev/null)
  if [ -n "$PKG_SCRIPTS" ]; then
    echo "  (from package.json scripts — add ## Run Commands to $(basename "$AGENTS_FILE") for agent context)"
    echo "$PKG_SCRIPTS"
  else
    echo "  [MISSING] No run commands — add ## Run Commands to $(basename "$AGENTS_FILE")"
  fi
else
  echo "  [MISSING] No run commands — add ## Run Commands to $(basename "$AGENTS_FILE")"
fi
echo ""

# ── Section 3: What's in progress? ───────────────────────────────────────────

echo "## 3. What's in progress?"
echo ""

if [ -f "$PROJECT_ROOT/feature_list.json" ] && command -v python3 >/dev/null 2>&1; then
  python3 -c "
import json, sys
try:
  data = json.load(open('$PROJECT_ROOT/feature_list.json'))
  features = data.get('features', [])
  active = [f for f in features if f.get('status') in ('active', 'in_progress', 'not_started')]
  passing = [f for f in features if f.get('status') == 'passing']
  if active:
    print('  In progress:')
    for f in active[:5]:
      print('    [' + f['status'] + '] ' + f['name'])
  if passing:
    print('  Done (' + str(len(passing)) + ' features passing):')
    for f in passing[:3]:
      print('    [passing] ' + f['name'])
    if len(passing) > 3:
      print('    ... and ' + str(len(passing)-3) + ' more')
  if not active and not passing:
    print('  No features defined yet — open feature_list.json and add your features')
except Exception as e:
  print('  (Could not parse feature_list.json: ' + str(e) + ')')
" 2>/dev/null || echo "  (error reading feature_list.json)"
elif [ -f "$PROJECT_ROOT/feature_list.json" ]; then
  echo "  feature_list.json exists — install python3 to see parsed status"
else
  echo "  [MISSING] No feature_list.json"
fi
echo ""

# ── Section 4: What do I do first? ───────────────────────────────────────────

echo "## 4. What do I do first?"
echo ""

if [ -f "$PROJECT_ROOT/PROGRESS.md" ]; then
  NEXT=$(awk '/^## Next Steps/{found=1; next} found && /^##/{exit} found && /^[0-9]/{print}' "$PROJECT_ROOT/PROGRESS.md" | head -5 | sed 's/^/  /')
  if [ -n "$NEXT" ]; then
    echo "  From PROGRESS.md:"
    echo "$NEXT"
  else
    echo "  PROGRESS.md exists — open it and read the latest session entry"
  fi
else
  echo "  [MISSING] No PROGRESS.md — check recent git commits:"
  git -C "$PROJECT_ROOT" log --oneline -5 2>/dev/null | sed 's/^/    /' || echo "    (no commits yet)"
fi
echo ""

# ── Section 5: Hard constraints ───────────────────────────────────────────────

echo "## 5. Hard constraints (do not violate these)"
echo ""
CONSTRAINTS=$(awk '/^## Hard Constraints/{found=1; next} found && /^##/{exit} found && /^-/{print}' "$AGENTS_FILE" | head -5 | grep -v "HARNESS-GAP" | sed 's/^/  /' || true)
if [ -n "$CONSTRAINTS" ]; then
  echo "$CONSTRAINTS"
else
  echo "  (No hard constraints in $(basename "$AGENTS_FILE"))"
fi
echo ""

echo "---"
echo "Onboarding complete. Read $(basename "$AGENTS_FILE") for full context, then run: bash init.sh"
echo ""
echo "Based on: Learn Harness Engineering — https://github.com/walkinglabs/learn-harness-engineering"
